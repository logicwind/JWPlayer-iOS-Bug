//
//  IntentHandler.swift
//  VoicerExtension
//
//  Created by Karim Mourra on 9/21/16.
//  Copyright © 2016 Karim Mourra. All rights reserved.
//

import Intents

class IntentHandler: INExtension, INStartWorkoutIntentHandling, INResumeWorkoutIntentHandling, INPauseWorkoutIntentHandling, INEndWorkoutIntentHandling {
    
    let userDefaults = UserDefaults.init(suiteName: "group.com.jwplayer.wormhole")
    
    override func handler(for intent: INIntent) -> Any {
        return self
    }
    
    func resolveWorkoutName(for intent: INStartWorkoutIntent, with completion: @escaping (INSpeakableStringResolutionResult) -> Void) {
        if intent.workoutName?.spokenPhrase == "casting" {
            var disambiguationOptions: [INSpeakableString]
            let castingDeviceNames = self.userDefaults?.value(forKey: "castingDevices") as? [String?]
            if (castingDeviceNames == nil || castingDeviceNames?.count == 0) {
                disambiguationOptions = self.standardDisambiguationOptions()
            } else {
                disambiguationOptions = self.convertToSpeakable(castingDeviceNames: castingDeviceNames!)
            }
            completion(INSpeakableStringResolutionResult.disambiguation(with: disambiguationOptions))
        } else if intent.workoutName != nil {
            completion(INSpeakableStringResolutionResult.success(with: intent.workoutName!))
        } else {
            completion(INSpeakableStringResolutionResult.disambiguation(with: self.standardDisambiguationOptions()))
        }
    }
    
    func resolveGoalValue(for intent: INStartWorkoutIntent, with completion: @escaping (INDoubleResolutionResult) -> Void) {
        let goalValue = (intent.goalValue != nil) ? intent.goalValue! : Double(0)
        completion(INDoubleResolutionResult.success(with: goalValue))
    }
    
    func resolveWorkoutGoalUnitType(for intent: INStartWorkoutIntent, with completion: @escaping (INWorkoutGoalUnitTypeResolutionResult) -> Void) {
        completion(INWorkoutGoalUnitTypeResolutionResult.success(with: intent.workoutGoalUnitType))
    }
    
    func handle(intent: INStartWorkoutIntent, completion: @escaping (INStartWorkoutIntentResponse) -> Void) {
        let userActivity = NSUserActivity.init(activityType: "start")
        completion(INStartWorkoutIntentResponse.init(code: INStartWorkoutIntentResponseCode.continueInApp, userActivity: userActivity))
    }
    
    func handle(intent: INResumeWorkoutIntent, completion: @escaping(INResumeWorkoutIntentResponse) -> Void) {
        let userActivity = NSUserActivity.init(activityType: "resume")
        completion(INResumeWorkoutIntentResponse.init(code: INResumeWorkoutIntentResponseCode.continueInApp, userActivity: userActivity))
    }
    
    func handle(intent: INPauseWorkoutIntent, completion: @escaping(INPauseWorkoutIntentResponse) -> Void) {
        let userActivity = NSUserActivity.init(activityType: "pause")
        completion(INPauseWorkoutIntentResponse.init(code: INPauseWorkoutIntentResponseCode.continueInApp, userActivity: userActivity))
    }
    
    func handle(intent: INEndWorkoutIntent, completion: @escaping (INEndWorkoutIntentResponse) -> Void) {
        let userActivity = NSUserActivity.init(activityType: "end")
        completion(INEndWorkoutIntentResponse.init(code: INEndWorkoutIntentResponseCode.continueInApp, userActivity: userActivity))
    }
    
    // MARK: Helpers
    
    func standardDisambiguationOptions() -> [INSpeakableString] {
        let seeking = INSpeakableString.init(identifier: "1", spokenPhrase: "seeking", pronunciationHint: "seec ing")
        let casting = INSpeakableString.init(identifier: "2", spokenPhrase: "casting", pronunciationHint: "cas ting")
        let playing = INSpeakableString.init(identifier: "3", spokenPhrase: "playing", pronunciationHint: "pley ing")
        return [playing, seeking, casting]
    }
    
    func convertToSpeakable(castingDeviceNames: [String?]) -> [INSpeakableString] {
        var speakableCastingDevices = [INSpeakableString]()
        for deviceName in castingDeviceNames {
            let speakableDeviceName = INSpeakableString.init(identifier: deviceName!, spokenPhrase: deviceName!, pronunciationHint: nil)
            speakableCastingDevices.append(speakableDeviceName)
        }
        return speakableCastingDevices
    }
}

