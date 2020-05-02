//
//  ViewController.swift
//  NativeControls
//
//  Created by David Almaguer on 8/21/19.
//  Copyright © 2019 Karim Mourra. All rights reserved.
//

import UIKit

let LIVEString = "LIVE"
let DefaultTimeString = "00:00"

class ViewController: JWBasicVideoViewController {
    
    @IBOutlet weak var controlsView: UIView!
    @IBOutlet weak var rewindButton: UIButton!
    @IBOutlet weak var playbackButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var audioButton: UIButton!
    @IBOutlet weak var fullscreenButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeSlider: UISlider!
    
    let indicatorView = UIActivityIndicatorView(style: .whiteLarge)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Verify instance of JWPlayerController
        if let player = self.player {
            // Hide JWPlayer's controls to use your own native contorls
            player.config.controls = false
            
            // Add an observer for JWPlayerStateChangedNotification
            NotificationCenter.default.addObserver(self, selector: #selector(stateChangedNotification(_:)), name: NSNotification.Name(rawValue: JWPlayerStateChangedNotification), object: nil)
            
            if let playerView = player.view {
                // Setup indicator view
                indicatorView.color = UIColor(red: 234/255, green: 52/255, blue: 76/255, alpha: 1)
                playerView.addSubview(indicatorView)
                playerView.bringSubviewToFront(indicatorView)
                indicatorView.constraintToCenter()
            }
        }
        
        // Set button images
        playbackButton.setImage(UIImage.init(named: "icons8-play-100"), for: .normal)
        playbackButton.setImage(UIImage.init(named: "icons8-pause-100"), for: .selected)
        rewindButton.setImage(UIImage.init(named: "icons8-rewind-10-100"), for: .normal)
        forwardButton.setImage(UIImage.init(named: "icons8-forward-10-100"), for: .normal)
        audioButton.setImage(UIImage.init(named: "icons8-audio-100"), for: .normal)
        audioButton.setImage(UIImage.init(named: "icons8-mute-100"), for: .selected)
        fullscreenButton.setImage(UIImage.init(named: "icons8-full-screen-100"), for: .normal)
        fullscreenButton.setImage(UIImage.init(named: "icons8-normal-screen-100"), for: .selected)
    }
    
    deinit {
        // Remove observers in this view controller
        NotificationCenter.default.removeObserver(self)
    }
    
// MARK: - Internal methods
    
    fileprivate func resetPlayerUI() {
        self.playbackButton.isSelected = false
        self.timeLabel.text = DefaultTimeString
        self.timeSlider.value = 0
    }
    
    fileprivate func toggleControlsViewVisible(_ visible: Bool) {
        self.controlsView.alpha = visible ? 1 : 0
    }
    
    fileprivate func toggleControlsView(_ enabled: Bool) {
        rewindButton.isEnabled = enabled
        playbackButton.isEnabled = enabled
        forwardButton.isEnabled = enabled
        fullscreenButton.isEnabled = enabled
    }
    
    fileprivate func timeFormatted(_ input: Int) -> String {
        let absInput = abs(input)
        let seconds: Int = absInput % 60
        let minutes: Int = (absInput / 60) % 60
        return String(format: "%02d:%02d", minutes, seconds)
        /* ** Remove this comment if you want to calculate hours **
        let hours: Int = absInput / 3600
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)*/
    }

// MARK: - IBActions

    @IBAction func playbackButtonTapped(_ sender: UIButton) {
        guard let player = self.player else { return }
        
        // Check the current state of player for play or pause the current video
        switch player.state {
        case .playing:
            player.pause()
        case .complete, .idle, .paused:
            player.play()
        default:
            break
        }
    }
    
    @IBAction func rewindButtonTapped(_ sender: Any) {
        guard let player = self.player else { return }
        
        // max function used to avoid negative values
        let newPosition = max(0, Int(player.position) - 10)
        player.seek(newPosition)
    }
    
    @IBAction func forwardButtonTapped(_ sender: Any) {
        guard let player = self.player else { return }
        
        let newPosition = Int(player.position) + 10
        player.seek(newPosition)
    }
    
    @IBAction func toggleMuteButtonTapped(_ sender: UIButton) {
        guard let player = self.player else { return }
        
        // Mute/unmute video
        if player.volume > 0 {
            player.volume = 0
            audioButton.isSelected = true
        } else {
            player.volume = 1
            audioButton.isSelected = false
        }
    }
    
    @IBAction func timeSliderValueChanged(_ sender: UISlider) {
        guard let player = self.player else { return }
        
        // Get video's duration (seconds)
        let videoDuration = player.duration
        // Calculate slider input to get the position in seconds
        let newPosition = Int(round(CGFloat(sender.value) * videoDuration))
        
        // Check for live streming (videoDuration < 0) = Live streming
        if videoDuration < 0 {
            // Seek video to input position
            player.seek(max(0, abs(newPosition)))
            // Update time label text with LIVE string
            timeLabel.text = String.init(format: "%@-%@", LIVEString, timeFormatted(newPosition))
        } else {
            // Seek video to input position
            player.seek(newPosition)
            // Update time label text
            timeLabel.text = timeFormatted(newPosition)
        }
    }
    
    @IBAction func fullscreenButtonTapped(_ sender: Any) {
        guard let player = self.player else { return }
        
        // Enter/exit of fullscreen mode
        let fullscreenEnabled = !player.fullscreen
        player.fullscreen = fullscreenEnabled
        fullscreenButton.isSelected = fullscreenEnabled
    }
    
// MARK: - JWPlayer Notifications
    
    @objc fileprivate func stateChangedNotification(_ notification: Notification) {
        guard let stateInfo = notification.userInfo else { return }
        
        if let oldStateRaw: Int = stateInfo["oldstate"] as? Int,
            let newStateRaw: Int = stateInfo["newstate"] as? Int,
            let oldState: JWPlayerState = JWPlayerState(rawValue: oldStateRaw),
            let newState: JWPlayerState = JWPlayerState(rawValue: newStateRaw) {
            
            // Evaluate new state to modify UI
            if newState == .complete {
                resetPlayerUI()
            } else if (newState == .playing) {
                playbackButton.isSelected = true
            } else if (newState == .paused) {
                playbackButton.isSelected = false
            } else if newState == .buffering {
                self.indicatorView.startAnimating()
            }
            
            // In all cases where the old state is .buffering or .complete
            // the indicator view will stop animating and show the controls view
            if oldState == .buffering ||
                newState == .complete {
                self.indicatorView.stopAnimating()
            }
        }
    }
    
// MARK: - JWPlayerDelegate implementation
    
    override func onTime(_ event: JWEvent & JWTimeEvent) {
        guard let player = self.player else { return }
        
        if player.duration > 0 {
            // Enable controls used for normal streaming
            timeSlider.isEnabled = true
            rewindButton.isHidden = false
            forwardButton.isHidden = false
            
            // Calculate progress(float) from position(seconds)
            let progress = Float(event.position / event.duration)
            self.timeSlider.value = progress
            timeLabel.text = timeFormatted(Int(event.position))
        } else {
            // Hide controls not used for live streaming
            rewindButton.isHidden = true
            forwardButton.isHidden = true
            
            if player.duration == 0 {
                // Hide slider for live streming
                timeSlider.isHidden = true
                timeLabel.text = LIVEString
            } else {
                // Show slider
                timeSlider.isHidden = false
                
                // Calculate progress(float) from position(seconds)
                let absPosition = abs(event.position)
                let absDuration = abs(player.duration)
                let progress = Float(absPosition / absDuration)
                self.timeSlider.value = progress
                timeLabel.text = String.init(format: "%@-%@", LIVEString, timeFormatted(Int(absPosition)))
            }
        }
    }
    
    override func onFullscreen(_ event: JWEvent & JWFullscreenEvent) {
        guard let player = self.player else { return }
        
        if event.fullscreen {
            // Check for the current key window view in fullscreen mode
            if let fullscreenView = UIApplication.shared.keyWindow {
                // Remove the controls view from its current superview
                // and add it to the new fullscreen window view
                controlsView.removeFromSuperview()
                fullscreenView.addSubview(controlsView)
                controlsView.constraintToFlexibleBottom()
                // Same happens with the indicator view
                indicatorView.removeFromSuperview()
                fullscreenView.addSubview(indicatorView)
                indicatorView.constraintToCenter()
            }
        } else {
            // Once the fullscreen mode is deactivated
            // the controls view should be removed from the fullscreen window view
            controlsView.removeFromSuperview()
            view.addSubview(controlsView)
            controlsView.constraintToFlexibleBottom()
            
            if let playerView = player.view {
                // Same happens with the indicator view
                indicatorView.removeFromSuperview()
                playerView.addSubview(indicatorView)
                indicatorView.constraintToCenter()
            }
        }
    }
    
}


// MARK: - Helper method

extension UIView {
    
    public func constraintToSuperview() {
        translatesAutoresizingMaskIntoConstraints = false
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[thisView]|",
                                                                   options: [],
                                                                   metrics: nil,
                                                                   views: ["thisView": self])
        
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[thisView]|",
                                                                   options: [],
                                                                   metrics: nil,
                                                                   views: ["thisView": self])
        
        NSLayoutConstraint.activate(horizontalConstraints + verticalConstraints)
    }
    
    public func constraintToCenter() {
        translatesAutoresizingMaskIntoConstraints = false
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[thisView]|",
                                                                   options: [.alignAllCenterX],
                                                                   metrics: nil,
                                                                   views: ["thisView": self])
        
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[thisView]|",
                                                                   options: [.alignAllCenterY],
                                                                   metrics: nil,
                                                                   views: ["thisView": self])
        
        NSLayoutConstraint.activate(horizontalConstraints + verticalConstraints)
    }
    
    public func constraintToFlexibleBottom() {
        translatesAutoresizingMaskIntoConstraints = false
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[thisView]|",
                                                                   options: [],
                                                                   metrics: nil,
                                                                   views: ["thisView" : self])
        
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[thisView]|",
                                                                   options: [.alignAllBottom],
                                                                   metrics: nil,
                                                                   views: ["thisView" : self])

        NSLayoutConstraint.activate(horizontalConstraints + verticalConstraints)
    }
    
}
