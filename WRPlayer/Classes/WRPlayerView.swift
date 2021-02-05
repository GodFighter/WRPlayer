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
    
    var playButton = UIButton.init(type : .custom)
    var toolView   = WRPlayerToolView()
    
    var bufferProgress: Float = 0 {
        didSet {
            self.toolView.bufferProgress = bufferProgress
        }
    }

    //MARK:- Life Cycle
    deinit {
        self.player?.pause()
        self.player = nil
    }

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
        playButton.setImage(UIImage(named: "WRPlayer_play", in: Bundle.init(for: self.classForCoder), compatibleWith: nil), for: .normal)
        playButton.setImage(UIImage(named: "WRPlayer_pause", in: Bundle.init(for: self.classForCoder), compatibleWith: nil), for: .selected)
        playButton.addTarget(self, action: #selector(action_play(_:)), for: .touchUpInside)
        toolView.playButton.addTarget(self, action: #selector(action_play(_:)), for: .touchUpInside)

        addSubview(playButton)
        playButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            playButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            playButton.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        addSubview(toolView)
        toolView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            toolView.leadingAnchor.constraint(equalTo: leadingAnchor),
            toolView.trailingAnchor.constraint(equalTo: trailingAnchor),
            toolView.heightAnchor.constraint(equalToConstant: 64)
        ])
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                toolView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
            ])
        } else {
            NSLayoutConstraint.activate([
                toolView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        }
    }

    func refresh(playerStatus status: WRPlayer.PlayStatus) {
        switch status {
        case .playing:
            playButton.isSelected = true
        default:
            playButton.isSelected = false
        }
        toolView.refresh(playerStatus: status)
    }
        
    @objc fileprivate func action_play(_ sender: UIButton) {
        sender.isSelected ? player?.pause() : player?.play()
    }

}

//MARK:-
open class WRPlayerToolView: UIView {
    
    //MARK: Property
    var bgView            = UIView()
    var playButton        = UIButton.init(type: .custom)
    var propressSlider    = UISlider.init()
    var currentTimeLabel  = UILabel()
    var totalTimeLabel    = UILabel()
    var fulllScreenButton = UIButton.init(type : .custom)
    var progressView      = UIProgressView()
    
    private var timeWidth: NSLayoutConstraint?
    
    var bufferProgress: Float = 0 {
        didSet {
            progressView.setProgress(bufferProgress, animated: true)
        }
    }

    //MARK:- Life Cycle
    deinit {

    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        initUI()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        initUI()
    }

    private func initUI() {
        backgroundColor = UIColor(white: 0, alpha: 0.5)
        bgView.backgroundColor = .clear
        
        addSubview(bgView)
        bgView.addSubview(playButton)
        bgView.addSubview(propressSlider)
        propressSlider.insertSubview(progressView, at: 0)
        bgView.addSubview(currentTimeLabel)
        bgView.addSubview(totalTimeLabel)
        bgView.addSubview(fulllScreenButton)
        
        bgView.translatesAutoresizingMaskIntoConstraints            = false
        playButton.translatesAutoresizingMaskIntoConstraints        = false
        propressSlider.translatesAutoresizingMaskIntoConstraints    = false
        progressView.translatesAutoresizingMaskIntoConstraints      = false
        currentTimeLabel.translatesAutoresizingMaskIntoConstraints  = false
        totalTimeLabel.translatesAutoresizingMaskIntoConstraints    = false
        fulllScreenButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            bgView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            bgView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            bgView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            bgView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15)
        ])
        
        playButton.setImage(WRPlayer.Image(name: "WRPlayer_play"), for: .normal)
        playButton.setImage(WRPlayer.Image(name: "WRPlayer_pause"), for: .selected)
        NSLayoutConstraint.activate([
            playButton.leadingAnchor.constraint(equalTo: bgView.leadingAnchor),
            playButton.centerYAnchor.constraint(equalTo: bgView.centerYAnchor),
            playButton.widthAnchor.constraint(equalToConstant: 20),
            playButton.heightAnchor.constraint(equalTo: playButton.widthAnchor)
        ])
        
        let thumbImage = WRPlayer.Image(name: "WRPlayer_slider_thumb")
        propressSlider.setThumbImage(thumbImage, for: .normal)
        if let image = thumbImage {
            propressSlider.setThumbImage(WRPlayer.ImageSize(image: image, scaledToSize: CGSize(width: 30, height: 30)), for: .highlighted)
        }
        propressSlider.maximumTrackTintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.2964201627)
        propressSlider.minimumTrackTintColor = #colorLiteral(red: 1, green: 1, blue: 0.9307904925, alpha: 0.7988548801)

        NSLayoutConstraint.activate([
            propressSlider.centerYAnchor.constraint(equalTo: playButton.centerYAnchor),
            propressSlider.leadingAnchor.constraint(equalTo: currentTimeLabel.trailingAnchor, constant: 10),
            propressSlider.trailingAnchor.constraint(equalTo: totalTimeLabel.leadingAnchor, constant: -10)
        ])
        
        propressSlider.setContentHuggingPriority(UILayoutPriority.init(0), for: .horizontal)

        progressView.tintColor = #colorLiteral(red: 1, green: 1, blue: 0.9307904925, alpha: 0.7988548801)
        progressView.trackTintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.2964201627)
        NSLayoutConstraint.activate([
            progressView.centerYAnchor.constraint(equalTo: propressSlider.centerYAnchor),
            progressView.leadingAnchor.constraint(equalTo: propressSlider.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: propressSlider.trailingAnchor)
        ])

        
        let width: CGFloat = {
           let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 13)
            label.text = "99:99"
            label.sizeToFit()
            
            return ceil(label.bounds.width)
        }()
        
        timeWidth = NSLayoutConstraint(item: currentTimeLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: width)
        
        currentTimeLabel.font = UIFont.systemFont(ofSize: 13)
        currentTimeLabel.text = "--:--"
        currentTimeLabel.textColor = .white
        NSLayoutConstraint.activate([
            currentTimeLabel.leadingAnchor.constraint(equalTo: playButton.trailingAnchor, constant: 10),
            currentTimeLabel.centerYAnchor.constraint(equalTo: playButton.centerYAnchor),
        ])
        currentTimeLabel.addConstraint(timeWidth!)

        totalTimeLabel.font = UIFont.systemFont(ofSize: 13)
        totalTimeLabel.text = "--:--"
        totalTimeLabel.textColor = .white
        NSLayoutConstraint.activate([
            totalTimeLabel.trailingAnchor.constraint(equalTo: fulllScreenButton.leadingAnchor, constant: -10),
            totalTimeLabel.centerYAnchor.constraint(equalTo: fulllScreenButton.centerYAnchor),
            totalTimeLabel.widthAnchor.constraint(equalTo: currentTimeLabel.widthAnchor)
        ])

        fulllScreenButton.setImage(WRPlayer.Image(name: "WRPlayer_fullscreen"), for: .normal)
        fulllScreenButton.setImage(WRPlayer.Image(name: "WRPlayer_fullscreen_exit"), for: .selected)
        fulllScreenButton.addTarget(self, action: #selector(action_enterFullscreen(_ :)), for: .touchDown)
        
        NSLayoutConstraint.activate([
            fulllScreenButton.trailingAnchor.constraint(equalTo: bgView.trailingAnchor),
            fulllScreenButton.centerYAnchor.constraint(equalTo: bgView.centerYAnchor),
            fulllScreenButton.widthAnchor.constraint(equalToConstant: 20),
            fulllScreenButton.heightAnchor.constraint(equalTo: fulllScreenButton.widthAnchor)
        ])

    }
    
    func refresh(playerStatus status: WRPlayer.PlayStatus) {
        switch status {
        case .playing:
            playButton.isSelected = true
        default:
            playButton.isSelected = false
        }
    }
    
    func refresh(playTime time: TimeInterval, totalTime: TimeInterval) {
        let units : NSCalendar.Unit = time >= TimeInterval.init(3600) ? [.hour, .minute, .second] : [.minute, .second]
        currentTimeLabel.text = time.player_durationString(units)
        propressSlider.value = Float(time / totalTime)
    }

    func setDuration(_ duration: TimeInterval) {
        let units : NSCalendar.Unit = duration >= TimeInterval.init(3600) ? [.hour, .minute, .second] : [.minute, .second]
        let width: CGFloat = {
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 13)
            label.text = duration.player_durationString(units)
            label.sizeToFit()
            
            return ceil(label.bounds.width) + 10
        }()
        timeWidth?.constant = width
        totalTimeLabel.text = duration.player_durationString(units)
    }
    
    @objc fileprivate func action_enterFullscreen(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        let orientation: UIInterfaceOrientation = {
            return sender.isSelected ? .landscapeRight : .portrait
        }()
        UIDevice.current.setValue(orientation.rawValue, forKey: "orientation")
    }
}

//MARK:-
fileprivate typealias Image = WRPlayer
extension Image {
    static func Image(name: String) -> UIImage? {
        return UIImage(named: name, in: Bundle.init(for: self.classForCoder()), compatibleWith: nil)
    }
    
    static func ImageSize(image: UIImage, scaledToSize newSize: CGSize) -> UIImage? {
         UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
         image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
         let newImage = UIGraphicsGetImageFromCurrentImageContext()
         UIGraphicsEndImageContext()
         return newImage;
     }
}

//MARK:-
extension TimeInterval {
    func player_durationString(_ unit : NSCalendar.Unit) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = unit
        formatter.zeroFormattingBehavior = .pad
        if self.isNaN {
            return "--:--"
        }
        return formatter.string(from: self) ?? "00:00"
    }
}
