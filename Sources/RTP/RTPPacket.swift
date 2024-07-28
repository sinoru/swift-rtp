//
//  RTPPacket.swift
//
//
//  Created by Jaehong Kang on 7/28/24.
//

public struct RTPPacket: Equatable, Hashable, Sendable {
    public var header: RTPHeader
    public var payload: [UInt8]

    public init(header: RTPHeader, payload: [UInt8]) {
        self.header = header
        self.payload = payload
    }
}

extension RTPPacket {
    public init(_ data: some Sequence<UInt8>) throws {
        var headerBytes = 0
        let header = try RTPHeader(data, headerBytes: &headerBytes)

        let payload = Array(data.dropFirst(headerBytes))

        self.init(
            header: header,
            payload: payload
        )
    }
}

extension RTPPacket {
    public var data: some RandomAccessCollection<UInt8> {
        get throws {
            try header.data + payload
        }
    }
}
