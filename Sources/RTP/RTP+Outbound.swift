//
//  RTP+Outbound.swift
//
//
//  Created by Jaehong Kang on 7/28/24.
//

import NIOCore

extension RTP {
    public struct Outbound: Sendable {
        private let asyncChannelOutboundWriter: NIOAsyncChannelOutboundWriter<RTPPacket>

        init(asyncChannelOutboundWriter: NIOAsyncChannelOutboundWriter<RTPPacket>) {
            self.asyncChannelOutboundWriter = asyncChannelOutboundWriter
        }

        public func write(_ data: RTPPacket) async throws {
            try await asyncChannelOutboundWriter.write(data)
        }

        public func write<Writes: Sequence>(contentsOf sequence: Writes) async throws where Writes.Element == RTPPacket {
            try await asyncChannelOutboundWriter.write(contentsOf: sequence)
        }

        public func write<Writes: AsyncSequence>(contentsOf sequence: Writes) async throws where Writes.Element == RTPPacket {
            try await asyncChannelOutboundWriter.write(contentsOf: sequence)
        }
    }
}
