//
//  RTP+Error.swift
//
//
//  Created by Jaehong Kang on 7/28/24.
//

extension RTP {
    public enum Error: Swift.Error {
        case unknown
        case invalidHeader
        case invalidRTPVersion
        case maximumCSRCCountExceeded
    }
}
