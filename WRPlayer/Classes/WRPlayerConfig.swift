//
//  WRPlayerConfig.swift
//  Pods
//
//  Created by 项辉 on 2021/2/3.
//

import UIKit
import AVFoundation

//MARK:-
/// 播放器委托
@objc public protocol WRPlayerDeletate: AnyObject {
    /// AVPlayerItem 状态改变回调
    ///
    /// - parameter player: 播放器
    /// - parameter status: AVPlayerItem 状态
    /// - parameter error: 错误
    @objc optional func player(_ player: WRPlayer, didChangedItemStatus status: AVPlayerItem.Status, _ error: Error?)
    
    /// AVPlayerItem buffer时间改变
    ///
    /// - parameter player: 播放器
    /// - parameter time: buffer时间
    @objc optional func player(_ player: WRPlayer, didChangedBufferTime time: Double)

    /// 播放器播放状态改变
    ///
    /// - parameter player: 播放器
    @objc func playerPlayStatusDidChange(_ player: WRPlayer)

    /// 播放器播放时间改变
    ///
    /// - parameter player: 播放器
    @objc optional func playerPlayTimeDidChange(_ player: WRPlayer)

}


//MARK:-
fileprivate typealias Enum = WRPlayer
public extension Enum {
    /// 播放器错误枚举
    enum PlayerError: Error {
        /// AVPlayerItem 错误枚举
        enum Item: Error, CustomStringConvertible
        {
            case failed
            case unknown
            
            var description: String {
                get {
                    switch self {
                    case .failed:   return "item error"
                    case .unknown:  return "unknown error"
                    }
                }
            }
        }
    }
    
    /// 播放器状态枚举
    @objc enum PlayStatus: Int, CustomStringConvertible {
        case none   = 0
        case playing
        case paused
        case stop
        case failed
        
        public var description: String {
            get {
                switch self {
                case .none    : return "None"
                case .playing : return "Playing"
                case .paused  : return "Paused"
                case .stop    : return "Stop"
                case .failed  : return "Failed"
                }
            }
        }
    }
}

//MARK:-
fileprivate typealias MainQueue = WRPlayer
internal extension Enum {
    static func ExecuteClosureOnMainQueueIfNecessary(withClosure closure: @escaping () -> Void) {
        if Thread.isMainThread {
            closure()
        } else {
            DispatchQueue.main.async(execute: closure)
        }
    }

}

