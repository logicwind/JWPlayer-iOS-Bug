The target named Voicer provides the code necessary to control the player's playback and casting with voice control using Siri.

This demo application uses SiriKit to provide voice control of the player. Since SiriKit offers control for only 6 types of activities, we trick Siri into thinking our commands are for workouts.

To call Siri hold the home button. You can command Siri to open the app by saying "open voicer".

**Example commands**:

- pause playback: "pause the movie". 
- resume playback: "resume the movie".
- seek to 15 seconds: "Start seeking to 15 seconds".
- start casting: "Start casting".
- disconnect casting: "Finish casting".

**Note**: 
- Only works on iOS 10 and above due to SiriKit dependency.
- Siri cannot be called on a simulator.
