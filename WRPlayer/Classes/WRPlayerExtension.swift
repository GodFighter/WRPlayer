//
//  WRPlayerExtension.swift
//  Pods
//
//  Created by 项辉 on 2021/2/4.
//

import UIKit
import CoreServices
import AVFoundation

//MARK:-
extension AVAsset {
    enum AssetType: Int, CustomStringConvertible {
        case unknown = 0
        case audio
        case video
        case stream
        
        var description: String {
            get {
                switch self {
                case .unknown :  return "asset type is unknown"
                case .audio   :  return "asset type is audio"
                case .video   :  return "asset type is video"
                case .stream  :  return "asset type is stream"
                }
            }
        }

    }
    
    var assetType: AssetType {
        guard let urlAsset = self as? AVURLAsset else { return .unknown }
        
        let type = urlAsset.url.wr_mineType()
        guard let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, type as CFString, nil)?.takeRetainedValue() else {
            return .unknown
        }

        if UTTypeConformsTo(uti, kUTTypeAudio) {
            return .audio
        } else if UTTypeConformsTo(uti, kUTTypeVideo) || UTTypeConformsTo(uti, kUTTypeMovie)  {
            return .video
        } else if UTTypeConformsTo(uti, kUTTypeM3UPlaylist) {
            return .stream
        } else {
            return .unknown
        }
    }
}

//MARK:-
extension URL {
    func wr_mineType() -> String {
        let pathExtension = self.pathExtension
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as NSString, nil)?.takeRetainedValue() {
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimetype as String
            }
        }
        return "application/octet-stream"
    }
    
    var wr_containsImage: Bool {
        let mimeType = self.wr_mineType()
        guard let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeType as CFString, nil)?.takeRetainedValue() else {
            return false
        }
        return UTTypeConformsTo(uti, kUTTypeImage)
    }

    var wr_containsAudio: Bool {
        let mimeType = self.wr_mineType()
        guard let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeType as CFString, nil)?.takeRetainedValue() else {
            return false
        }
        return UTTypeConformsTo(uti, kUTTypeAudio)
    }
    
    var wr_containsVideo: Bool {
        let mimeType = self.wr_mineType()
        guard  let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeType as CFString, nil)?.takeRetainedValue() else {
            return false
        }
        return UTTypeConformsTo(uti, kUTTypeVideo)
    }

}
