//
//  BasicVideoViewController.swift
//  BasicVideoViewController
//
//  Created by David Almaguer on 9/2/19.
//  Copyright © 2019 Karim Mourra. All rights reserved.
//

import UIKit

let videoUrl = "http://playertest.longtailvideo.com/adaptive/oceans/oceans.m3u8"
let thumbnailUrl = "http://d3el35u4qe4frz.cloudfront.net/bkaovAYt-480.jpg"

class BasicVideoViewController: UIViewController {
    
    var player: JWPlayerController? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Instance JWPlayerController object
        createPlayer()
        if let containerView = view,
            let playerView = player?.view {
            containerView.addSubview(playerView)
            // Turn off translatesAutoresizingMaskIntoConstraints property to use Auto Layout to dynamically calculate the size and position
            playerView.translatesAutoresizingMaskIntoConstraints = false
            // Add constraints to center the playerView
            playerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
            playerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
            playerView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
            playerView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        }
    }
    
// MARK: Internal methods

    func createPlayer() {
        if let player = JWPlayerController(config: createConfig(), delegate: self) {
            // Force fullscreen on landscape and vice versa
            player.forceFullScreenOnLandscape = true
            player.forceLandscapeOnFullScreen = true
            self.player = player
        }
    }
    
    func createConfig() -> JWConfig {
        // Instance JWConfig object to setup the video
        let config = JWConfig.init(contentUrl: videoUrl)
        config.image = thumbnailUrl
        config.autostart = true
        config.repeat = true
        return config;
    }

}

// MARK: JWPlayerDelegate implementation

extension BasicVideoViewController: JWPlayerDelegate {
    // Optionally implement methods to track the JWPlayerController behavior
}

