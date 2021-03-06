// Copyright (c) 2017 Timofey Solomko
// Licensed under MIT License
//
// See LICENSE for license information

import Foundation

/// Provides functions for compression and decompression for Deflate algorithm.
public class Deflate: DecompressionAlgorithm {

    /**
     Decompresses `data` using Deflate algortihm.

     If `data` is not actually compressed with Deflate, `DeflateError` will be thrown.

     - Note: This function is specification compliant.

     - Parameter data: Data compressed with Deflate.

     - Throws: `DeflateError` if unexpected byte (bit) sequence was encountered in `data`.
     It may indicate that either data is damaged or it might not be compressed with Deflate at all.

     - Returns: Decompressed data.
     */
    public static func decompress(data: Data) throws -> Data {
        /// Object with input data which supports convenient work with bit shifts.
        let bitReader = BitReader(data: data, bitOrder: .reversed)
        return Data(bytes: try decompress(bitReader))
    }

    static func decompress(_ bitReader: BitReader) throws -> [UInt8] {
        /// An array for storing output data
        var out: [UInt8] = []

        while true {
            /// Is this a last block?
            let isLastBit = bitReader.bit()
            /// Type of the current block.
            let blockType = bitReader.intFromBits(count: 2)

            if blockType == 0 { // Uncompressed block.
                bitReader.align()
                /// Length of the uncompressed data.
                let length = bitReader.uint16()
                /// 1-complement of the length.
                let nlength = bitReader.uint16()
                // Check if lengths are OK (nlength should be a 1-complement of length).
                guard length & nlength == 0 else { throw DeflateError.wrongUncompressedBlockLengths }
                // Process uncompressed data into the output
                for _ in 0..<length {
                    out.append(bitReader.byte())
                }
            } else if blockType == 1 || blockType == 2 {
                // Block with Huffman coding (either static or dynamic)

                // Declaration of Huffman trees which will be populated and used later.
                // There are two alphabets in use and each one needs a Huffman tree.

                /// Huffman tree for literal and length symbols/codes.
                var mainLiterals: DecodingHuffmanTree
                /// Huffman tree for backward distance symbols/codes.
                var mainDistances: DecodingHuffmanTree

                if blockType == 1 { // Static Huffman
                    // In this case codes for literals and distances are fixed.
                    // Initialize trees from bootstraps.
                    mainLiterals = DecodingHuffmanTree(lengths: Constants.staticHuffmanBootstrap, bitReader)
                    mainDistances = DecodingHuffmanTree(lengths: Constants.staticHuffmanDistancesBootstrap, bitReader)
                } else { // Dynamic Huffman
                    // In this case there are Huffman codes for two alphabets in data right after block header.
                    // Each code defined by a sequence of code lengths (which are compressed themselves with Huffman).

                    /// Number of literals codes.
                    let literals = bitReader.intFromBits(count: 5) + 257
                    /// Number of distances codes.
                    let distances = bitReader.intFromBits(count: 5) + 1
                    /// Number of code lengths codes.
                    let codeLengthsLength = bitReader.intFromBits(count: 4) + 4

                    // Read code lengths codes.
                    // Moreover, they are stored in a very specific order,
                    //  defined by HuffmanTree.Constants.codeLengthOrders.
                    var lengthsForOrder = Array(repeating: 0, count: 19)
                    for i in 0..<codeLengthsLength {
                        lengthsForOrder[Constants.codeLengthOrders[i]] = bitReader.intFromBits(count: 3)
                    }
                    /// Huffman tree for code lengths. Each code in the main alphabets is coded with this tree.
                    let dynamicCodes = DecodingHuffmanTree(lengths: Deflate.lengths(from: lengthsForOrder), bitReader)

                    // Now we need to read codes (code lengths) for two main alphabets (trees).
                    var codeLengths: [Int] = []
                    var n = 0
                    while n < (literals + distances) {
                        // Finding next Huffman tree's symbol in data.
                        let symbol = dynamicCodes.findNextSymbol()
                        guard symbol != -1 else { throw DeflateError.symbolNotFound }

                        let count: Int
                        let what: Int
                        if symbol >= 0 && symbol <= 15 {
                            // It is a raw code length.
                            count = 1
                            what = symbol
                        } else if symbol == 16 {
                            // Copy previous code length 3 to 6 times.
                            // Next two bits show how many times we need to copy.
                            count = bitReader.intFromBits(count: 2) + 3
                            what = codeLengths.last!
                        } else if symbol == 17 {
                            // Repeat code length 0 for from 3 to 10 times.
                            // Next three bits show how many times we need to copy.
                            count = bitReader.intFromBits(count: 3) + 3
                            what = 0
                        } else if symbol == 18 {
                            // Repeat code length 0 for from 11 to 138 times.
                            // Next seven bits show how many times we need to do this.
                            count = bitReader.intFromBits(count: 7) + 11
                            what = 0
                        } else {
                            throw DeflateError.wrongSymbol
                        }
                        for _ in 0..<count {
                            codeLengths.append(what)
                        }
                        n += count
                    }
                    // We have read codeLengths for both trees at once.
                    // Now we need to split them and make corresponding trees.
                    mainLiterals = DecodingHuffmanTree(lengths:
                        Deflate.lengths(from: Array(codeLengths[0..<literals])), bitReader)
                    mainDistances = DecodingHuffmanTree(lengths:
                        Deflate.lengths(from: Array(codeLengths[literals..<codeLengths.count])), bitReader)
                }

                // Main loop of data decompression.
                while true {
                    // Read next symbol from data.
                    // It will be either literal symbol or a length of (previous) data we will need to copy.
                    let nextSymbol = mainLiterals.findNextSymbol()
                    guard nextSymbol != -1 else { throw DeflateError.symbolNotFound }

                    if nextSymbol >= 0 && nextSymbol <= 255 {
                        // It is a literal symbol so we add it straight to the output data.
                        out.append(nextSymbol.toUInt8())
                    } else if nextSymbol == 256 {
                        // It is a symbol indicating the end of data.
                        break
                    } else if nextSymbol >= 257 && nextSymbol <= 285 {
                        // It is a length symbol.
                        // Depending on the value of nextSymbol there might be additional bits in data,
                        // which we need to add to nextSymbol to get the full length.
                        let extraLength = (257 <= nextSymbol && nextSymbol <= 260) || nextSymbol == 285 ?
                            0 : (((nextSymbol - 257) >> 2) - 1)
                        // Actually, nextSymbol is not a starting value of length,
                        //  but an index for special array of starting values.
                        let length = Constants.lengthBase[nextSymbol - 257] +
                            bitReader.intFromBits(count: extraLength)

                        // Then we need to get distance code.
                        let distanceCode = mainDistances.findNextSymbol()
                        guard distanceCode != -1 else { throw DeflateError.symbolNotFound }
                        guard distanceCode >= 0 && distanceCode <= 29
                            else { throw DeflateError.wrongSymbol }

                        // Again, depending on the distanceCode's value there might be additional bits in data,
                        // which we need to combine with distanceCode to get the actual distance.
                        let extraDistance = distanceCode == 0 || distanceCode == 1 ? 0 : ((distanceCode >> 1) - 1)
                        // And yes, distanceCode is not a first part of distance but rather an index for special array.
                        let distance = Constants.distanceBase[distanceCode] +
                            bitReader.intFromBits(count: extraDistance)

                        // We should repeat last 'distance' amount of data.
                        // The amount of times we do this is round(length / distance).
                        // length actually indicates the amount of data we get from this nextSymbol.
                        let repeatCount: Int = length / distance
                        let count = out.count
                        for _ in 0..<repeatCount {
                            for i in count - distance..<count {
                                out.append(out[i])
                            }
                        }
                        // Now we deal with the remainings.
                        if length - distance * repeatCount == distance {
                            for i in out.count - distance..<out.count {
                                out.append(out[i])
                            }
                        } else {
                            for i in out.count - distance..<out.count + length - distance * (repeatCount + 1) {
                                out.append(out[i])
                            }
                        }
                    } else {
                        throw DeflateError.wrongSymbol
                    }
                }

            } else {
                throw DeflateError.wrongBlockType
            }

            // End the cycle if it was the last block.
            if isLastBit == 1 {
                break
            }
        }

        return out
    }

}
