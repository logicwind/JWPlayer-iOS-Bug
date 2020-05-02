//
//  AnalyticsObserver.swift
//  ConvivaDemo
//
//  Created by Kateryna Obertynska on 3/6/19.
//  Copyright © 2019 JWPlayer. All rights reserved.
//

import Foundation
import AVFoundation
import ConvivaSDK

let TEST_CUSTOMER_KEY = "CUSTOMER_KEY"
let TOUCHSTONE_SERVICE_URL = "SERVICE_URL"

class AnalyticsObserver: NSObject {
    
    let player: JWPlayerController
    
    var avPlayerStatus: AVPlayer.Status?
    var currentItem: AVPlayerItem?
    var playerVideoRect: CGRect?
    
    var playerRate: CGFloat? {
        didSet {
            client?.sendCustomEvent(videoSessionID, eventname: "New playback rate", withAttributes: ["playback rate" : "\(playerRate!)"])
        }
    }
    
    var currentPlaylistItem: JWPlaylistItem? {
        didSet {
            createVideoSession()
            attachVideoPlayer()
        }
    }
    
    var client: CISClientProtocol?
    var psmVideoInstance: CISPlayerStateManagerProtocol?
    var contentMetaData: CISContentMetadata?
    var videoSessionID: Int32 = NO_SESSION_KEY

    init(player: JWPlayerController) {
        self.player = player
        super.init()
        self.player.delegate = self;
        self.setupSDKAndClient()
        
        NotificationCenter.default.addObserver(self,
                                               selector:#selector(accessLogChanged(_:)),
                                               name: NSNotification.Name.AVPlayerItemNewAccessLogEntry,
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func accessLogChanged(_ notification: Notification) {
        if let event: AVPlayerItemAccessLogEvent = currentItem?.accessLog()?.events.last {
            psmVideoInstance?.setBitrateKbps!(Int(event.indicatedBitrate / 1000))
        }
    }
    
    func setupSDKAndClient() {
        
        let systemInterFactory: CISSystemInterfaceProtocol = IOSSystemInterfaceFactory.initializeWithSystemInterface()
        let setting = CISSystemSettings()
        setting.logLevel = .LOGLEVEL_NONE
        let factory : CISSystemFactoryProtocol = CISSystemFactoryCreator.create(withCISSystemInterface: systemInterFactory, setting: setting)
        
        let settingError: Error? = nil
        let clientError: Error? = nil
        
        var clientSetting : CISClientSettingProtocol
        do {
            clientSetting = try CISClientSettingCreator.create(withCustomerKey: TEST_CUSTOMER_KEY)
            clientSetting.setGatewayUrl(TOUCHSTONE_SERVICE_URL)
            
            do {
                client = try CISClientCreator.create(withClientSettings: clientSetting, factory: factory)
            } catch {
                print(clientError!)
            }
        } catch {
            print(settingError!)
        }
        
        if (clientError != nil) {
            print("[SAMPLE APP] [clientError] [ \(clientError!) ]")
        } else if (settingError != nil){
            NSLog("[SAMPLE APP] [settingError] [ \(settingError!) ]")
        } else {
            print("[SAMPLE APP] [SUCCESS] [INIT SUCCESS]")
        }
    }
    
    func createVideoSession() {
        if client != nil, let metadata = createVideoMetadataObject() {
            videoSessionID = client!.createSession(with: metadata)
            print(videoSessionID)
        }
    }
    
    func cleanupVideoSession() {
        if (client != nil && videoSessionID != NO_SESSION_KEY) {
            client!.cleanupSession(videoSessionID)
            videoSessionID = NO_SESSION_KEY
            cleanupVideoPsm()
        }
    }
    
    func createVideoMetadataObject() -> CISContentMetadata? {
        contentMetaData = CISContentMetadata()
        contentMetaData?.assetName = currentPlaylistItem?.title ?? "None"
        contentMetaData?.streamUrl = currentPlaylistItem?.file
        contentMetaData?.applicationName = "Conviva_Demo"
        contentMetaData?.custom["tag1"] = "value1"
        contentMetaData?.custom["tag2"] = "value2"
        contentMetaData?.viewerId = "Conviva-QE"
        contentMetaData?.defaultResource = "LEVEL3"
        contentMetaData?.streamType = .CONVIVA_STREAM_VOD
        return contentMetaData
    }
    
    func cleanupVideoPsm() {
        guard let client = self.client, let psmVideoInstance = self.psmVideoInstance else { return }
        client.releasePlayerStateManager(psmVideoInstance)
        self.psmVideoInstance = nil
    }
    
    func attachVideoPlayer() {
        guard let client = self.client else { return }
            
        if (psmVideoInstance == nil) {
            psmVideoInstance = client.getPlayerStateManager()
            psmVideoInstance?.setPlayerVersion!(JWPlayerController.sdkVersion())
            psmVideoInstance?.setPlayerType!("JWPlayer")
        }
        
        if (psmVideoInstance != nil && videoSessionID != NO_SESSION_KEY && !client.isPlayerAttached(videoSessionID)) {
            client.attachPlayer(videoSessionID, playerStateManager: psmVideoInstance)
        }
    }
    
    func detachVideoPlayer()  {
        if (client != nil && videoSessionID != NO_SESSION_KEY) {
            client!.detachPlayer(videoSessionID)
        }
    }
}

// MARK: - JWAVPlayerAnalyticsDelegate
extension AnalyticsObserver: JWAVPlayerAnalyticsDelegate {
    
    func playbackRateDidChange(_ rate: CGFloat) {
        if playerRate != rate {
            playerRate = rate
        }
    }
    
    func playerStatusDidChange(_ status: AVPlayer.Status) {
        avPlayerStatus = status
    }
    
    func playerItemDidChange(_ item: AVPlayerItem?) {
        if currentItem != item {
            if let oldItem = currentItem {
                removeObservers(for: oldItem)
            }
            
            currentItem = item
            addObservers(for: currentItem)
        }
    }
    
    func playerErrorDidChange(_ error: Error?) {
        if (client != nil && videoSessionID != NO_SESSION_KEY) {
            psmVideoInstance?.setPlayerState!(PlayerState.CONVIVA_STOPPED);
            client!.reportError(videoSessionID, errorMessage: error?.localizedDescription, errorSeverity: .ERROR_FATAL)
        }
    }
    
    func playerLayerVideoRectDidChange(_ videoRect: CGRect) {
        playerVideoRect = videoRect
    }
    
    func addObservers(for item: AVPlayerItem?) {
        item?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        item?.addObserver(self, forKeyPath: "duration", options: .new, context: nil)
    }
    
    func removeObservers(for item: AVPlayerItem?) {
        item?.removeObserver(self, forKeyPath: "status", context: nil)
        item?.removeObserver(self, forKeyPath: "duration", context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if let item = object as? AVPlayerItem, item == currentItem {
            if let key = keyPath, key == "duration", let duration = currentItem?.duration.seconds {
                client?.sendCustomEvent(videoSessionID, eventname: "Current Item Duration", withAttributes: ["duration" : "\(duration)"])
            }
        }
    }
}

// MARK: - JWPlayerDelegate
extension AnalyticsObserver: JWPlayerDelegate {
    func onSeek(_ event: JWEvent & JWSeekEvent) {
        let offset = Int64(event.offset)
        psmVideoInstance?.setSeekStart?(offset)
    }
    
    func onSeeked() {
        psmVideoInstance?.setSeekEnd!(Int64(player.position))
    }
    
    func onPlaylistItem(_ event: JWEvent & JWPlaylistItemEvent) {
        if currentPlaylistItem != event.item {
            detachVideoPlayer()
            cleanupVideoSession()
            currentPlaylistItem = event.item
        }
    }
    
    func onBuffer(_ event: JWEvent & JWBufferEvent) {
        psmVideoInstance?.setPlayerState!(PlayerState.CONVIVA_BUFFERING)
    }
    
    func onPlay(_ event: JWEvent & JWStateChangeEvent) {
        psmVideoInstance?.setPlayerState!(PlayerState.CONVIVA_PLAYING)
    }
    
    func onPause(_ event: JWEvent & JWStateChangeEvent) {
        psmVideoInstance?.setPlayerState!(PlayerState.CONVIVA_PAUSED)
    }
    
    func onComplete() {
        psmVideoInstance?.setPlayerState!(PlayerState.CONVIVA_STOPPED)
    }
    
    func onError(_ event: JWEvent & JWErrorEvent) {
        client!.reportError(videoSessionID, errorMessage: event.error.localizedDescription, errorSeverity: .ERROR_FATAL)
    }
    
    func onSetupError(_ event: JWEvent & JWErrorEvent) {
        client!.reportError(videoSessionID, errorMessage: event.error.localizedDescription, errorSeverity: .ERROR_FATAL)
    }
    
    // MARK: - Advertizing
    func onAdImpression(_ event: JWAdEvent & JWAdImpressionEvent) {
        
        var adPos: AdPosition!
        switch event.adPosition.lowercased() {
        case "pre":
            adPos = .ADPOSITION_PREROLL
            break
            
        case "post":
            adPos = .ADPOSITION_POSTROLL
            break
            
        default:
            adPos = .ADPOSITION_MIDROLL
        }
        
        client?.adStart(videoSessionID, adStream: .ADSTREAM_SEPARATE, adPlayer: .ADPLAYER_CONTENT, adPosition: adPos)
    }
    
    func onAdComplete(_ event: JWAdEvent & JWAdDetailEvent) {
        client?.adEnd(videoSessionID)
    }
}
