//
//  RTP+Inbound.swift
//
//
//  Created by Jaehong Kang on 7/28/24.
//

import NIOCore

extension RTP {
    public struct Inbound: AsyncSequence {
        public typealias AsyncIterator = NIOAsyncChannelInboundStream<RTPPacket>.AsyncIterator
        public typealias Element = RTPPacket

        let asyncChannelInboundStream: NIOAsyncChannelInboundStream<RTPPacket>

        public func makeAsyncIterator() -> AsyncIterator {
            asyncChannelInboundStream
                .makeAsyncIterator()
        }
    }
}
