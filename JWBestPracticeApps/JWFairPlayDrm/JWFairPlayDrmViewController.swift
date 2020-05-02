//
//  JWFairPlayDrmViewController.swift
//  JWBestPracticeApps
//
//  Created by Karim Mourra on 9/26/16.
//  Copyright © 2016 Karim Mourra. All rights reserved.
//

class JWFairPlayDrmViewController: JWBasicVideoViewController, JWDrmDataSource, URLSessionDelegate {

    let encryptedFile = "http://fps.ezdrm.com/demo/video/ezdrm.m3u8"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.player.drmDataSource = self
    }
    
    override func onReady(_ event: JWEvent & JWReadyEvent) {
        let item = JWPlaylistItem()
        item.file = encryptedFile
        self.player.load([item])
    }
    
    func fetchAppIdentifier(forRequest loadingRequestURL: URL, for encryption: JWEncryption, withCompletion completion: @escaping (Data) -> Void) {
        if encryption == .fairPlay {
            let request = NSMutableURLRequest.init()
            request.url = NSURL.init(string: "http://fps.ezdrm.com/demo/video/eleisure.cer") as URL?
            request.httpMethod = "GET"
            let configuration = URLSessionConfiguration.default
            let session = URLSession.init(configuration: configuration, delegate: self, delegateQueue: nil)
            let getDataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
                guard let data = data else {
                    session.invalidateAndCancel()
                    return
                }
                completion(data)
                session.finishTasksAndInvalidate()
            })
            getDataTask.resume()
        }
    }
    
    func fetchContentIdentifier(forRequest loadingRequestURL: URL, for encryption: JWEncryption, withCompletion completion: @escaping (Data) -> Void) {
        if encryption == .fairPlay {
            let assetPath = loadingRequestURL.path
            if let assetId = assetPath.components(separatedBy: ";").last {
                let assetIdData = Data(bytes: (assetId.cString(using: .utf8)!),
                                       count: (assetId.lengthOfBytes(using: .utf8)))
                completion(assetIdData)
            }
        }
    }
    
    func fetchContentKey(withRequest requestBytes: Data, for encryption: JWEncryption, withCompletion completion: @escaping (Data, Date?, String?) -> Void) {
        if encryption == .fairPlay {
            let currentTime = NSTimeIntervalSince1970 * 1000
            let keyServerAddress = String.init(format: "http://fps.ezdrm.com/api/licenses/09cc0377-6dd4-40cb-b09d-b582236e70fe?p1=\(currentTime)")
            let ksmURL = NSURL.init(string: keyServerAddress)
            let request = NSMutableURLRequest.init(url: ksmURL! as URL)
            request.httpMethod = "POST"
            request.setValue("application/octet-stream", forHTTPHeaderField: "Content-type")
            request.httpBody = requestBytes as Data?
            let configuration = URLSessionConfiguration.default
            let session = URLSession.init(configuration: configuration, delegate: self, delegateQueue: nil)
            let postDataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
                guard let data = data else {
                    session.invalidateAndCancel()
                    return
                }
                completion(data, Date.distantFuture, "application/octet-stream")
            })
            postDataTask.resume()
        }
    }
}
