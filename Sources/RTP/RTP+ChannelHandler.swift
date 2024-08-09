//
//  RTP+ChannelHandler.swift
//
//
//  Created by Jaehong Kang on 7/28/24.
//

import NIOCore

extension RTP {
    class ChannelHandler: ChannelDuplexHandler {
        typealias InboundIn = AddressedEnvelope<ByteBuffer>
        typealias InboundOut = AddressedEnvelope<RTPPacket>
        typealias OutboundIn = AddressedEnvelope<RTPPacket>
        typealias OutboundOut = AddressedEnvelope<ByteBuffer>

        func channelRead(context: ChannelHandlerContext, data _data: NIOAny) {
            let data = unwrapInboundIn(_data)

            do {
                let packet = try RTPPacket(data.data.readableBytesView)

                context.fireChannelRead(wrapInboundOut(.init(
                    remoteAddress: data.remoteAddress,
                    data: packet,
                    metadata: data.metadata.flatMap { .init(ecnState: $0.ecnState, packetInfo: $0.packetInfo) }
                )))
            } catch {
                context.fireErrorCaught(error)
            }
        }

        func write(context: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {
            let data = unwrapOutboundIn(data)

            do {
                context.writeAndFlush(
                    wrapOutboundOut(
                        .init(
                            remoteAddress: data.remoteAddress,
                            data: try context.channel.allocator.buffer(bytes: data.data.data),
                            metadata: data.metadata.flatMap { .init(ecnState: $0.ecnState, packetInfo: $0.packetInfo) }
                        )
                    ),
                    promise: promise
                )
            } catch {
                context.fireErrorCaught(error)
            }
        }
    }
}
