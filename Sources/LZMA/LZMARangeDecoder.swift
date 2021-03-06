// Copyright (c) 2017 Timofey Solomko
// Licensed under MIT License
//
// See LICENSE for license information

import Foundation

class LZMARangeDecoder {

    private var pointerData: DataWithPointer

    private var range: UInt32 = 0xFFFFFFFF
    private var code: UInt32 = 0
    private(set) var isCorrupted: Bool = false

    var isFinishedOK: Bool {
        return self.code == 0
    }

    init?(_ pointerData: DataWithPointer) {
        self.pointerData = pointerData

        let byte = self.pointerData.byte()
        for _ in 0..<4 {
            self.code = (self.code << 8) | UInt32(self.pointerData.byte())
        }
        if byte != 0 || self.code == self.range {
            self.isCorrupted = true
            return nil
        }
    }

    init() {
        self.pointerData = DataWithPointer(data: Data())
        self.range = 0xFFFFFFFF
        self.code = 0
        self.isCorrupted = false
    }

    /// `range` property cannot be smaller than `(1 << 24)`. This function keeps it bigger.
    func normalize() {
        if self.range < UInt32(LZMAConstants.topValue) {
            self.range <<= 8
            self.code = (self.code << 8) | UInt32(pointerData.byte())
        }
    }

    /// Decodes sequence of direct bits (binary symbols with fixed and equal probabilities).
    func decode(directBits: Int) -> Int {
        var res: UInt32 = 0
        var count = directBits
        repeat {
            self.range >>= 1
            self.code = self.code &- self.range
            let t = 0 &- (self.code >> 31)
            self.code = self.code &+ (self.range & t)

            if self.code == self.range {
                self.isCorrupted = true
            }

            self.normalize()

            res <<= 1
            res = res &+ (t &+ 1)
            count -= 1
        } while count > 0
        return Int(res)
    }

    /// Decodes binary symbol (bit) with predicted (estimated) probability.
    func decode(bitWithProb prob: inout Int) -> Int {
        let bound = (self.range >> UInt32(LZMAConstants.numBitModelTotalBits)) * UInt32(prob)
        let symbol: Int
        if self.code < bound {
            prob += ((1 << LZMAConstants.numBitModelTotalBits) - prob) >> LZMAConstants.numMoveBits
            self.range = bound
            symbol = 0
        } else {
            prob -= prob >> LZMAConstants.numMoveBits
            self.code -= bound
            self.range -= bound
            symbol = 1
        }
        self.normalize()
        return symbol
    }

}
