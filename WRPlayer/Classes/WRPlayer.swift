//
//  WRPlayer.swift
//  Pods
//
//  Created by 项辉 on 2021/2/3.
//

import UIKit
import AVFoundation

//let WRPlayer_PlayerItemStatusNotification

/// 多媒体播放器
open class WRPlayer: NSObject {
            
    //MARK:- Property
    //MARK: Private
    fileprivate lazy var _avPlayer: AVPlayer = {
        let avplayer = AVPlayer()
        avplayer.actionAtItemEnd = .pause
        return avplayer
    }()

    fileprivate var _avplayerItem: AVPlayerItem?
    fileprivate var _lastBufferTime: Double = 0 // 缓冲的最后时间点
    fileprivate var _playerView: WRPlayerView = WRPlayerView(frame: .zero)

    //MARK: Observe
    fileprivate var _playerItemObservers = [NSKeyValueObservation]()
    fileprivate var _playerTimeObserver: Any?
    fileprivate var _playerObservers     = [NSKeyValueObservation]()

    //MARK: Public
    /// 委托
    open weak var delegate: WRPlayerDeletate? {
        didSet {
            _addPlayerObservers()
        }
    }

    /// 播放器URL
    open var url: URL? {
        didSet {
            guard let _ = self.url else { return }
            _setup()
        }
    }
    
    /// 播放器状态
    open private(set) var status: WRPlayer.PlayStatus = .none {
        didSet {
            guard status != oldValue else { return }
            
            WRPlayer.ExecuteClosureOnMainQueueIfNecessary {
                self.delegate?.playerPlayStatusDidChange(self)
            }
        }
    }
    
    /// 循环播放
    open var playLoops: Bool = false
    
    //MARK:- Life Cycle
    deinit {
        _removePlayerObservers()
    }
    
}

//MARK:-
fileprivate typealias Info = WRPlayer
public extension Info {
    /// 播放时长
    var duration: TimeInterval {
        get {
            guard let item = _avplayerItem else { return CMTimeGetSeconds(.indefinite) }
            return CMTimeGetSeconds(item.currentTime())
        }
    }
    
    var currentTime: TimeInterval {
        get {
            guard let item = _avplayerItem else { return CMTimeGetSeconds(.indefinite) }
            return CMTimeGetSeconds(item.currentTime())
        }
    }
    
    var naturalSize: CGSize {
        get {
            if let playerItem = _avplayerItem,
                let track = playerItem.asset.tracks(withMediaType: .video).first {

                let size = track.naturalSize.applying(track.preferredTransform)
                return CGSize(width: abs(size.width), height: abs(size.height))
            } else {
                return CGSize.zero
            }
        }
    }
    
    var playerView: WRPlayerView {
        get {
            return _playerView
        }
    }
}
//MARK:-
fileprivate typealias Private = WRPlayer
fileprivate extension Private {
    func _setup() {
        guard let url = self.url else {
            return
        }
        
        _setupItem(url)

    }
    
    func _setupItem(_ url: URL) {
        _removePlayerItemObservers()
        let avplayerItem = AVPlayerItem.init(url: url)
        
        _addPlayerItemObservers(avplayerItem)
        
        _avplayerItem = avplayerItem
        _avPlayer.replaceCurrentItem(with: _avplayerItem)
        if _avplayerItem?.asset.assetType == .video {
            _playerView.player = _avPlayer
        }
    }
    

}

//MARK:-
fileprivate typealias Public = WRPlayer
public extension Public {
    func play() {
        guard status != .playing else { return }
        _avPlayer.play()
    }
    
    func pause() {
        guard status == .playing else { return }
        _avPlayer.pause()
    }
    
    func stop() {
        guard status != .stop else { return }
        
        _avPlayer.pause()
        status = .stop
    }
}


//MARK:-
fileprivate typealias Observer = WRPlayer
fileprivate extension Observer {
    func _addPlayerItemObservers(_ item: AVPlayerItem) {
        // 状态
        _playerItemObservers.append(
            item.observe(\AVPlayerItem.status, options: [.old, .new], changeHandler: { [weak self] (item, _) in
                guard let `self` = self else { return }

                let error: Error? = {
                    switch item.status {
                    case .readyToPlay : return nil
                    case .failed      : return PlayerError.Item.failed
                    case .unknown     : return PlayerError.Item.unknown
                    @unknown default  : return PlayerError.Item.unknown
                    }
                }()
                self.delegate?.player?(self, didChangedItemStatus: item.status, error)
            })
        )
        
        // 最后缓存时间点
        _playerItemObservers.append(
            item.observe(\.loadedTimeRanges, options: [.new], changeHandler: { [weak self] (item, _) in
                guard let `self` = self else { return }
                
                if let timeRange = item.loadedTimeRanges.first?.timeRangeValue
                {
                    let bufferedTime = CMTimeGetSeconds(CMTimeAdd(timeRange.start, timeRange.duration))
                    if self._lastBufferTime != bufferedTime {
                        self._lastBufferTime = bufferedTime
                        WRPlayer.ExecuteClosureOnMainQueueIfNecessary {
                            self.delegate?.player?(self, didChangedBufferTime: bufferedTime)
                        }
                    }
                }
            })
        )
        
        _addPlayerItemNotify(item)
    }
    
    func _removePlayerItemObservers() {
        if let currentItem = _avplayerItem {
            _removePlayerItemNotify(currentItem)
        }

        _playerItemObservers.removeAll { (observer) -> Bool in
            observer.invalidate()
            return true
        }
    }
    
    func _addPlayerObservers() {
        _playerTimeObserver = _avPlayer.addPeriodicTimeObserver(forInterval: CMTime.init(value: 1, timescale: 1), queue: DispatchQueue.main, using: { [weak self] (time) in
            guard let `self` = self else { return }
            self.delegate?.playerPlayTimeDidChange?(self)
        })
        
        // 监听AVPlayer是否在播放状态
        // iOS 10.0以下通过监控 Rate 来判断是否正在播放
        if #available(iOS 10.0, tvOS 10.0, *) {
            _playerObservers.append(
                _avPlayer.observe(\.timeControlStatus, options: [.new, .old]) { [weak self] (object, change) in
                switch object.timeControlStatus
                {
                    case .paused:
                        self?.status = .paused
                    case .playing:
                        self?.status = .playing
                    case .waitingToPlayAtSpecifiedRate:
                        fallthrough
                    @unknown default:
                        break
                    }
                })
        } else {
            _playerObservers.append(
                _avPlayer.observe(\.rate, options: [.new, .old], changeHandler: { [weak self] (player, change) in
                    self?.status = player.rate > 0 ? .playing : .paused
                })
            )
        }

    }
    
    func _removePlayerObservers() {
        if let observer = _playerTimeObserver {
            _avPlayer.removeTimeObserver(observer)
        }
        _playerObservers.removeAll { (observer) -> Bool in
            observer.invalidate()
            return true
        }
    }
    
}

//MARK:-
fileprivate typealias Notify = WRPlayer
fileprivate extension Notify {
    func _addPlayerItemNotify(_ item: AVPlayerItem) {
        NotificationCenter.default.addObserver(self, selector: #selector(_notify_itemDidPlayToEndTime(_:)), name: .AVPlayerItemDidPlayToEndTime, object: item)
        NotificationCenter.default.addObserver(self, selector: #selector(_notify_itemDidPlayToEndTime(_:)), name: .AVPlayerItemFailedToPlayToEndTime, object: item)
    }
    
    func _removePlayerItemNotify(_ item: AVPlayerItem) {
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: item)
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemFailedToPlayToEndTime, object: item)
    }
    
    @objc func _notify_itemDidPlayToEndTime(_ notification: Notification) {
        switch notification.name {
        case .AVPlayerItemDidPlayToEndTime:
            if playLoops {
                _avPlayer.seek(to: CMTime.zero)
                _avPlayer.play()
            } else {
                _avPlayer.seek(to: .zero) { (_) in
                    self.stop()
                }
            }
        case .AVPlayerItemFailedToPlayToEndTime:
            status = .failed
        default: break
        }
    }
}
