import Foundation
import zlib

nonisolated enum ArchiveGzip {
    static func compress(_ bytes:Data)throws->Data {
        // Empty cloud statistics still need a valid gzip stream.
        guard bytes.count<=ProgressArchive.maximumBytes else {throw ProgressError.invalidArchive}
        var stream=z_stream()
        guard deflateInit2_(&stream,Z_DEFAULT_COMPRESSION,Z_DEFLATED,15+16,8,Z_DEFAULT_STRATEGY,ZLIB_VERSION,Int32(MemoryLayout<z_stream>.size))==Z_OK else {throw ProgressError.invalidArchive}
        defer{deflateEnd(&stream)}
        return try bytes.withUnsafeBytes {input in
            stream.next_in=UnsafeMutablePointer(mutating:input.bindMemory(to:Bytef.self).baseAddress);stream.avail_in=uInt(bytes.count)
            var output=Data();var buffer=[UInt8](repeating:0,count:32*1024)
            while true {
                let status=buffer.withUnsafeMutableBytes {chunk->Int32 in
                    stream.next_out=chunk.bindMemory(to:Bytef.self).baseAddress;stream.avail_out=uInt(chunk.count)
                    return deflate(&stream,Z_FINISH)
                }
                let count=buffer.count-Int(stream.avail_out)
                guard output.count<=ProgressArchive.maximumBytes-count else {throw ProgressError.invalidArchive}
                output.append(contentsOf:buffer.prefix(count))
                if status==Z_STREAM_END {return output}
                guard status==Z_OK,count>0 else {throw ProgressError.invalidArchive}
            }
        }
    }
    static func decompress(_ bytes:Data) throws -> Data {
        guard !bytes.isEmpty,bytes.count<=ProgressArchive.maximumBytes else {throw ProgressError.invalidArchive}
        var stream=z_stream()
        guard inflateInit2_(&stream,15+16,ZLIB_VERSION,Int32(MemoryLayout<z_stream>.size))==Z_OK else {throw ProgressError.invalidArchive}
        defer {inflateEnd(&stream)}
        return try bytes.withUnsafeBytes { input in
            stream.next_in=UnsafeMutablePointer(mutating:input.bindMemory(to:Bytef.self).baseAddress)
            stream.avail_in=uInt(bytes.count)
            var output=Data();var buffer=[UInt8](repeating:0,count:32*1024)
            while true {
                let status=buffer.withUnsafeMutableBytes { chunk -> Int32 in
                    stream.next_out=chunk.bindMemory(to:Bytef.self).baseAddress;stream.avail_out=uInt(chunk.count)
                    return inflate(&stream,Z_NO_FLUSH)
                }
                let count=buffer.count-Int(stream.avail_out)
                guard output.count<=ProgressArchive.maximumBytes-count else {throw ProgressError.invalidArchive}
                output.append(contentsOf:buffer.prefix(count))
                if status==Z_STREAM_END {
                    guard stream.avail_in==0 else {throw ProgressError.invalidArchive}
                    return output
                }
                guard status==Z_OK,count>0 else {throw ProgressError.invalidArchive}
            }
        }
    }
}
