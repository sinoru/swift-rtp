//
//  RTPHeader.swift
//
//
//  Created by Jaehong Kang on 7/28/24.
//

public struct RTPHeader: Equatable, Hashable, Sendable {
    public var version: UInt8
    public var padding: Bool
    public var `extension`: Bool
    public var marker: Bool
    public var payloadType: Int8
    public var sequenceNumber: UInt16
    public var timestamp: UInt32
    public var ssrc: UInt32
    public var csrcs: [UInt32]

    public init(
        version: UInt8 = 2,
        padding: Bool = false,
        `extension`: Bool = false,
        marker: Bool = false,
        payloadType: Int8,
        sequenceNumber: UInt16,
        timestamp: UInt32,
        ssrc: UInt32,
        csrcs: [UInt32]
    ) {
        self.version = version
        self.padding = padding
        self.extension = `extension`
        self.marker = marker
        self.payloadType = payloadType
        self.sequenceNumber = sequenceNumber
        self.timestamp = timestamp
        self.ssrc = ssrc
        self.csrcs = csrcs
    }
}

extension RTPHeader {
    public init(_ data: some Sequence<UInt8>, headerBytes: inout Int) throws {
        let data = data
        var totalHeaderBytes = 0

        let metadataBytes = Array(data.prefix(MemoryLayout<UInt16>.size))
        guard metadataBytes.count == MemoryLayout<UInt16>.size else {
            throw RTP.Error.invalidHeader
        }
        let metadataBits = metadataBytes.withUnsafeBytes({ $0.load(as: UInt16.self) })
        totalHeaderBytes += metadataBytes.count

        let version = UInt8(metadataBits >> 14)
        guard version == 2 else {
            throw RTP.Error.invalidRTPVersion
        }

        let padding = Bool(metadataBits >> 13 & 0x1 == 1)
        let `extension` = Bool(metadataBits >> 12 & 0x1 == 1)
        let csrcCount = UInt8(metadataBits >> 8 & 0xF)
        let marker = Bool(metadataBits >> 7 & 0x1 == 1)
        let payloadType = Int8(metadataBits & 0x7F)

        let sequenceBytes = Array(data.prefix(MemoryLayout<UInt16>.size))
        guard sequenceBytes.count == MemoryLayout<UInt16>.size else {
            throw RTP.Error.invalidHeader
        }
        let sequenceNumber = sequenceBytes.withUnsafeBytes({ $0.load(as: UInt16.self) })
        totalHeaderBytes += sequenceBytes.count

        let timestampBytes = Array(data.prefix(MemoryLayout<UInt32>.size))
        guard timestampBytes.count == MemoryLayout<UInt32>.size else {
            throw RTP.Error.invalidHeader
        }
        let timestamp = timestampBytes.withUnsafeBytes({ $0.load(as: UInt32.self) })
        totalHeaderBytes += timestampBytes.count

        let ssrcBytes = Array(data.prefix(MemoryLayout<UInt32>.size))
        guard ssrcBytes.count == MemoryLayout<UInt32>.size else {
            throw RTP.Error.invalidHeader
        }
        let ssrc = ssrcBytes.withUnsafeBytes({ $0.load(as: UInt32.self) })
        totalHeaderBytes += ssrcBytes.count

        let csrcs = try (0..<csrcCount).map { _ in
            let csrcBytes = Array(data.prefix(MemoryLayout<UInt32>.size))
            guard csrcBytes.count == MemoryLayout<UInt32>.size else {
                throw RTP.Error.invalidHeader
            }
            defer {
                totalHeaderBytes += csrcBytes.count
            }
            return csrcBytes.withUnsafeBytes({ $0.load(as: UInt32.self) })
        }

        headerBytes = totalHeaderBytes

        self.init(
            version: version,
            padding: padding,
            extension: `extension`,
            marker: marker,
            payloadType: payloadType,
            sequenceNumber: sequenceNumber,
            timestamp: timestamp,
            ssrc: ssrc,
            csrcs: csrcs
        )
    }
}

extension RTPHeader {
    public var data: some RandomAccessCollection<UInt8> {
        get throws {
            var metadataBits: UInt16 = ((UInt16(payloadType) << 1) >> 1)

            metadataBits = UInt16(version) << 14

            if padding {
                metadataBits = metadataBits | 0x2000
            }

            if `extension` {
                metadataBits = metadataBits | 0x1000
            }

            guard csrcs.count < 16 else {
                throw RTP.Error.maximumCSRCCountExceeded
            }
            metadataBits = metadataBits | UInt16(csrcs.count) << 12
            
            if marker {
                metadataBits = metadataBits | 0x80
            }

            let metadataBytes = withUnsafeBytes(of: &metadataBits) { bytes in
                Array(
                    bytes
                        .lazy
                        .prefix(MemoryLayout<UInt16>.size / MemoryLayout<UInt8>.size * MemoryLayout<UInt8>.size)
                        .reversed()
                )
            }

            var sequenceNumber = self.sequenceNumber
            let sequenceBytes = withUnsafeBytes(of: &sequenceNumber) { bytes in
                Array(
                    bytes
                        .lazy
                        .prefix(MemoryLayout<UInt16>.size / MemoryLayout<UInt8>.size * MemoryLayout<UInt8>.size)
                        .reversed()
                )
            }

            var timestamp = self.timestamp
            let timestampBytes = withUnsafeBytes(of: &timestamp) { bytes in
                Array(
                    bytes
                        .lazy
                        .prefix(MemoryLayout<UInt32>.size / MemoryLayout<UInt8>.size * MemoryLayout<UInt8>.size)
                        .reversed()
                )
            }

            var ssrc = self.ssrc
            let ssrcBytes = withUnsafeBytes(of: &ssrc) { bytes in
                Array(
                    bytes
                        .lazy
                        .prefix(MemoryLayout<UInt32>.size / MemoryLayout<UInt8>.size * MemoryLayout<UInt8>.size)
                        .reversed()
                )
            }

            let csrcsBytes = csrcs.map { csrc in
                var csrc = csrc
                return withUnsafeBytes(of: &csrc) { bytes in
                    Array(
                        bytes
                            .lazy
                            .prefix(MemoryLayout<UInt32>.size / MemoryLayout<UInt8>.size * MemoryLayout<UInt8>.size)
                            .reversed()
                    )
                }
            }

            return metadataBytes + sequenceBytes + timestampBytes + ssrcBytes + csrcsBytes.flatMap { $0 }
        }
    }
}
