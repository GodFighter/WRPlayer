//
//  ViewController.swift
//  WRPlayer
//
//  Created by God_Fighter on 02/03/2021.
//  Copyright (c) 2021 God_Fighter. All rights reserved.
//

import UIKit
import WRPlayer

class ViewController: UIViewController {
    
    var player: WRPlayer = WRPlayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        player.delegate = self
//        player.url = URL(string: "http://satellitepull.cnr.cn/live/wx32nmgyygb/playlist.m3u8")!
        player.url = Bundle.main.url(forResource: "放牛歌", withExtension: "mp3")
//        player.url = Bundle.main.url(forResource: "IMG_1140", withExtension: "MOV")
        player.playerView.frame = view.bounds
        view.insertSubview(player.playerView, at: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func action_play(_ sender: Any) {
        switch player.status {
        case .playing:
            player.pause()
        default:
            player.play()
        }
    }
}

//MARK:-
fileprivate typealias PlayerDelegate = ViewController
extension PlayerDelegate : WRPlayerDeletate{
    func playerPlayStatusDidChange(_ player: WRPlayer) {
        print(player.status)
    }
    
    func playerPlayTimeDidChange(_ player: WRPlayer) {
        print(player.currentTime)
    }
}


