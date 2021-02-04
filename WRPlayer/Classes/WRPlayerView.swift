//
//  WRPlayerView.swift
//  Pods
//
//  Created by 项辉 on 2021/2/4.
//

import UIKit
import AVFoundation

open class WRPlayerView: UIView {

    // MARK: - overrides
    public override class var layerClass: AnyClass {
        get {
            return AVPlayerLayer.self
        }
    }
    
    //MARK:- Property
    var playerLayer: AVPlayerLayer {
        get {
            return self.layer as! AVPlayerLayer
        }
    }

    var player: AVPlayer? {
        get {
            return self.playerLayer.player
        }
        set {
            self.playerLayer.player = newValue
            self.playerLayer.isHidden = (self.playerLayer.player == nil)
        }
    }
    
    var playButton: UIButton = UIButton.init(type: .custom)
    
    //MARK:- Life Cycle
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.playerLayer.isHidden = true
//        self.playerFillMode = .resizeAspect
        
        initUI()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.playerLayer.isHidden = true
//        self.playerFillMode = .resizeAspect
        initUI()
    }
    
    private func initUI() {
        playButton.setImage(UIImage(named: "play", in: Bundle.init(for: self.classForCoder), compatibleWith: nil), for: .normal)
        addSubview(playButton)
        playButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            playButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            playButton.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    deinit {
        self.player?.pause()
        self.player = nil
    }

}
