//
//  VoicerViewController.swift
//  JWBestPracticeApps
//
//  Created by Karim Mourra on 9/21/16.
//  Copyright © 2016 Karim Mourra. All rights reserved.
//

import UIKit
import Intents

class VoicerViewController: JWRemoteCastPlayerViewController {
    
    let userDefaults = UserDefaults.init(suiteName: "group.com.jwplayer.wormhole")
    let playerSynonyms = ["player", "play", "playing", "playback", "video", "movie"]
    let seekingSynonyms = ["seeking", "seek"]
    let castingSynonyms = ["casting", "chrome cast", "cast"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        INPreferences.requestSiriAuthorization { (authorizationStatus) in
        }
        self.prepareCustomVocabulary()
    }
    
    public func handle(intent: INIntent) {
        if intent is INPauseWorkoutIntent {
            let pauseIntent = intent as! INPauseWorkoutIntent
            self.handlePause(command: pauseIntent.workoutName?.spokenPhrase)
        } else if intent is INResumeWorkoutIntent {
            let resumeIntent = intent as! INResumeWorkoutIntent
            self.handleResume(command: resumeIntent.workoutName?.spokenPhrase)
        } else if intent is INStartWorkoutIntent {
            let startIntent = intent as! INStartWorkoutIntent
            let startGoal = startIntent.goalValue != nil ? UInt(startIntent.goalValue!) : 0
            self.handleStart(command: (startIntent.workoutName?.spokenPhrase), quantity: startGoal)
        } else if intent is INEndWorkoutIntent {
            let endCastingIntent = intent as! INEndWorkoutIntent
            self.handleEnd(command: endCastingIntent.workoutName?.spokenPhrase)
        }
    }
    
    func handleResume(command: String?) {
        if self.keywordFrom(synonym: command!) == "player" {
            self.player.play()
        }
    }
    
    func handlePause(command: String?) {
        if self.keywordFrom(synonym: command!) == "player" {
            self.player.pause()
        }
    }
    
    func handleStart(command: String?, quantity: UInt?) {
        if self.keywordFrom(synonym: command!) == "seeking" {
            self.player.seek(Int(quantity!))
        } else if self.keywordFrom(synonym: command!) == "player" {
            self.player.play()
        } else {
            self.castTo(deviceName: command!)
        }
    }
    
    func handleEnd(command: String?) {
        if self.keywordFrom(synonym: command!) == "casting" {
            self.castController.disconnect()
        }
    }
    
    // MARK: Helper Methods
    
    func prepareCustomVocabulary() {
        let workoutNames = NSOrderedSet(array: self.playerSynonyms + self.seekingSynonyms + self.castingSynonyms)
        let vocabulary = INVocabulary.shared()
        vocabulary.setVocabularyStrings(workoutNames, of: .workoutActivityName)
    }
    
    func keywordFrom(synonym: String)-> String? {
        if self.playerSynonyms.contains(synonym) {
            return "player"
        } else if self.seekingSynonyms.contains(synonym) {
            return "seeking"
        } else if self.castingSynonyms.contains(synonym) {
            return "casting"
        }
        return nil
    }
    
    func castTo(deviceName: String) {
        if let castingDevice = self.obtainCastingDevice(name: deviceName) {
            self.castController.connect(to: castingDevice)
        }
    }
    
    func obtainCastingDevice(name: String) -> JWCastingDevice? {
        return self.castController.availableDevices.filter { (castingDevice) -> Bool in
            return castingDevice.name.elementsEqual(name)
            }.first
    }
    
    // MARK: Cast Delegate Methods
    
    override func onCastingDevicesAvailable(_ devices: [JWCastingDevice]) {
        super.onCastingDevicesAvailable(devices)
        self.prepareCastingDevices()
    }
    
    func prepareCastingDevices() {
        let castingDevices = self.castController.availableDevices.compactMap { return $0.name }
        if castingDevices.count > 0 {
            self.userDefaults?.set(castingDevices, forKey: "castingDevices")
            self.userDefaults?.synchronize()
        }
    }
}
