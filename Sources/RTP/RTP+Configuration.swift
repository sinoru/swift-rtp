//
//  RTP+Configuration.swift
//
//
//  Created by Jaehong Kang on 7/28/24.
//

import NIOCore

extension RTP {
    public struct Configuration {
        public var eventLoopGroup: (any EventLoopGroup)?

        public init(
            eventLoopGroup: (any EventLoopGroup)? = nil
        ) {
            self.eventLoopGroup = eventLoopGroup
        }
    }
}
