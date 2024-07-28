//
//  RTP.swift
//
//
//  Created by Jaehong Kang on 7/28/24.
//

import NIOCore
import NIOPosix
#if canImport(NIOTransportServices)
import NIOTransportServices
import Network
#endif

public struct RTP {
    public let configuration: Configuration
    #if canImport(NIOTransportServices)
    private let bootstrap: NIOTSDatagramBootstrap
    #else
    private let bootstrap: DatagramBootstrap
    #endif

    public init(
        configuration: Configuration = .init()
    ) {
        self.configuration = configuration

        self.bootstrap = {
            #if canImport(NIOTransportServices)
            NIOTSDatagramBootstrap(group: configuration.eventLoopGroup ?? NIOSingletons.transportServicesEventLoopGroup)
            #else
            DatagramBootstrap(group: configuration.eventLoopGroup ?? NIOSingletons.posixEventLoopGroup)
            #endif
        }()
            .channelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
            .channelInitializer { channel in
                channel.pipeline.addHandler(ChannelHandler())
            }
    }

    public func connect<Result>(
        host: String,
        port: Int,
        _ body: (_ inbound: Inbound, _ outbound: Outbound) async throws -> Result
    ) async throws -> Result {
        let channel = try await bootstrap.connect(host: host, port: port).get()

        let asyncChannel = try await channel.eventLoop.makeCompletedFuture {
            try NIOAsyncChannel<RTPPacket, RTPPacket>(wrappingChannelSynchronously: channel)
        }.get()

        return try await asyncChannel.executeThenClose { inbound, outbound in
            return try await body(
                Inbound(asyncChannelInboundStream: inbound),
                Outbound(asyncChannelOutboundWriter: outbound)
            )
        }
    }
}
