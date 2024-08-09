//
//  RTP+Outbound.swift
//
//
//  Created by Jaehong Kang on 7/28/24.
//

import NIOCore

extension RTP {
    public struct Outbound: Sendable {
        private let asyncChannelOutboundWriter: NIOAsyncChannelOutboundWriter<AddressedEnvelope<RTPPacket>>
        private let socketAddress: SocketAddress

        init(asyncChannelOutboundWriter: NIOAsyncChannelOutboundWriter<AddressedEnvelope<RTPPacket>>, socketAddress: SocketAddress) {
            self.asyncChannelOutboundWriter = asyncChannelOutboundWriter
            self.socketAddress = socketAddress
        }

        public func write(_ data: RTPPacket) async throws {
            try await asyncChannelOutboundWriter.write(AddressedEnvelope(remoteAddress: socketAddress, data: data))
        }

        public func write<Writes: Sequence>(contentsOf sequence: Writes) async throws where Writes.Element == RTPPacket {
            try await asyncChannelOutboundWriter.write(contentsOf: sequence.lazy.map { AddressedEnvelope(remoteAddress: socketAddress, data: $0) })
        }

        public func write<Writes: AsyncSequence>(contentsOf sequence: Writes) async throws where Writes.Element == RTPPacket {
            try await asyncChannelOutboundWriter.write(contentsOf: sequence.map { AddressedEnvelope(remoteAddress: socketAddress, data: $0) })
        }
    }
}
