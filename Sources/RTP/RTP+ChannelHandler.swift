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
        typealias InboundOut = RTPPacket
        typealias OutboundIn = RTPPacket
        typealias OutboundOut = AddressedEnvelope<ByteBuffer>

        func channelRead(context: ChannelHandlerContext, data _data: NIOAny) {
            let data = unwrapInboundIn(_data)

            do {
                let packet = try RTPPacket(data.data.readableBytesView)

                context.fireChannelRead(wrapInboundOut(packet))
            } catch {
                context.fireErrorCaught(error)
            }
        }

        func write(context: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {
            let data = unwrapOutboundIn(data)

            do {
                guard let remoteAddress = context.remoteAddress else {
                    throw RTP.Error.unknown
                }

                context.writeAndFlush(
                    wrapOutboundOut(
                        AddressedEnvelope(
                            remoteAddress: remoteAddress,
                            data: try context.channel.allocator.buffer(bytes: data.data)
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
