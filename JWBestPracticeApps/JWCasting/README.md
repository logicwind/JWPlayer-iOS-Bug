The JWCasting target presents the code necessary to cast video from our JW Player to a Google Cast device.

To enable casting to Google Cast with the JW Player iOS SDK, you must import the Google Cast Framework and its dependent frameworks. For a list of necessary frameworks, please visit [https://developers.google.com/cast/docs/ios_sender#setup](https://developers.google.com/cast/docs/ios_sender#setup) and follow the steps under the "Xcode setup" subsection of the "Setup" section.

The JWPlayerController API controls the playback of the video being casted, and the JWPlayerDelegate will provide you with the playback callbacks while casting.

Please note that Google Cast support is still in beta. The JW Player SDK supports casting to the Default Media Receiver and to Styled Media Receivers. Custom Receivers are not yet officially supported, but may work if the video playback implements the same interface as the Default Media Receiver. To specify a receiver, set the receiver's app ID to the `chromeCastReceiverAppID` property of the JWCastController.

# Known issues with Google Cast:

* Google IMA ads are not supported when casting.
* Multiple AudioTracks or AudioTrack switching is not supported when casting.
* Only WebVTT captions are supported; support for other caption formats will be added in the future

# Discovery Troubleshooting:

Per Google's [Cast Discovery documentation](https://developers.google.com/cast/docs/discovery), Youtube and Netflix should not be used to test discovery:
> Do not use the Netflix or YouTube apps to test discovery, as these use some specialized discovery mechanisms.

Instead, we recommend using Google's Cast sample app https://github.com/googlecast/CastHelloVideo-ios
