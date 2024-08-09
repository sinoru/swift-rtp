//
//  RTP+Inbound.swift
//
//
//  Created by Jaehong Kang on 7/28/24.
//

import NIOCore

extension RTP {
    public struct Inbound: AsyncSequence {
        public typealias AsyncIterator = AsyncMapSequence<NIOAsyncChannelInboundStream<AddressedEnvelope<RTPPacket>>, RTPPacket>.AsyncIterator
        public typealias Element = RTPPacket

        let asyncChannelInboundStream: NIOAsyncChannelInboundStream<AddressedEnvelope<RTPPacket>>

        public func makeAsyncIterator() -> AsyncIterator {
            asyncChannelInboundStream
                .map(\.data)
                .makeAsyncIterator()
        }
    }
}
