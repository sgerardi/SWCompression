Pod::Spec.new do |s|

  s.name         = "SWCompression"
  s.version      = "3.4.0"
  s.summary      = "Framework with implementations in Swift of different (de)compression algorithms"

  s.description  = <<-DESC
  A framework which contains native (written in Swift) implementations of compression algorithms.
  Swift developers currently have access only to various wrappers written in Objective-C
  around system libraries if they want to decompress something. SWCompression allows to do this with pure Swift
  without relying on availability of system libraries.
                   DESC

  s.homepage     = "https://github.com/tsolomko/SWCompression"
  s.documentation_url = "http://tsolomko.github.io/SWCompression"

  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author       = { "Timofey Solomko" => "tsolomko@gmail.com" }

  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.10"
  s.tvos.deployment_target = "9.0"
  s.watchos.deployment_target = "2.0"

  s.source       = { :git => "https://github.com/tsolomko/SWCompression.git", :tag => "v#{s.version}" }

  s.subspec 'Deflate' do |sp|
    sp.source_files = 'Sources/{Deflate/*,Common/*}.swift'
    sp.pod_target_xcconfig = { 'OTHER_SWIFT_FLAGS' => '-DSWCOMPRESSION_POD_DEFLATE' }
  end

  s.subspec 'GZip' do |sp|
    sp.dependency 'SWCompression/Deflate'
    sp.source_files = 'Sources/{Gzip/*,Common/Checksums}.swift'
  end

  s.subspec 'Zlib' do |sp|
    sp.dependency 'SWCompression/Deflate'
    sp.source_files = 'Sources/{Zlib/*,Common/CheckSums}.swift'
  end

  s.subspec 'BZip2' do |sp|
    sp.source_files = 'Sources/{BZip2/*,Common/*}.swift'
    sp.pod_target_xcconfig = { 'OTHER_SWIFT_FLAGS' => '-DSWCOMPRESSION_POD_BZ2' }
  end

  s.subspec 'LZMA' do |sp|
    sp.source_files = 'Sources/{LZMA/*,Common/Extensions,Common/Protocols,Common/DataWithPointer}.swift'
    sp.pod_target_xcconfig = { 'OTHER_SWIFT_FLAGS' => '-DSWCOMPRESSION_POD_LZMA' }
  end

  s.subspec 'XZ' do |sp|
    sp.dependency 'SWCompression/LZMA'
    sp.source_files = 'Sources/{XZ/*,Common/CheckSums}.swift'
  end

  s.subspec 'ZIP' do |sp|
    sp.dependency 'SWCompression/Deflate'
    sp.source_files = 'Sources/{Zip/*,Common/CheckSums}.swift'
    sp.pod_target_xcconfig = { 'OTHER_SWIFT_FLAGS' => '-DSWCOMPRESSION_POD_ZIP' }
  end

  s.subspec 'TAR' do |sp|
    sp.source_files = 'Sources/{Tar/*,Common/Extensions,Common/Protocols,Common/DataWithPointer}.swift'
  end

  s.subspec 'SevenZip' do |sp|
    sp.dependency 'SWCompression/LZMA'
    sp.source_files = 'Sources/{7-Zip/*,Common/CheckSums,Common/BitReader}.swift'
    sp.pod_target_xcconfig = { 'OTHER_SWIFT_FLAGS' => '-DSWCOMPRESSION_POD_SEVENZIP' }
  end

end
