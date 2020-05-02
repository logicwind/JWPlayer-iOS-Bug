//
//  CastingViewController.swift
//  Casting
//
//  Created by David Almaguer on 9/3/19.
//  Copyright © 2019 Karim Mourra. All rights reserved.
//

import UIKit
import GoogleCast

class CastingViewController: BasicVideoViewController {
    
    var avilableDevices: [JWCastingDevice] = []
    var castController: JWCastController? = nil
    
    var castingButton: UIButton? = nil
    var barButtonItem: UIBarButtonItem? = nil
    
    var casting = false {
        didSet {
            castingButton?.tintColor = casting ? UIColor.green : UIColor.blue
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barTintColor = UIColor.gray
        
        // Setup JWCastController object
        setupCastController()
    }
    
    func setupCastController() {
        guard let player = self.player else { return }
        
        let castController = JWCastController(player: player)
        castController.chromeCastReceiverAppID = kGCKDefaultMediaReceiverApplicationID
        castController.delegate = self
        castController.scanForDevices()
        self.castController = castController
    }
    
    func setupCastingButton() {
        let buttonFrame = CGRect(x: 0, y: 0, width: 22, height: 22)
        let castingButton = UIButton(frame: buttonFrame)
        castingButton.addTarget(self, action: #selector(castButtonTapped(sender:)), for: .touchUpInside)
        
        // Load images for button's animation
        let connectingImages = [UIImage(named: "cast_connecting0")?.withRenderingMode(.alwaysTemplate),
                                UIImage(named: "cast_connecting1")?.withRenderingMode(.alwaysTemplate),
                                UIImage(named: "cast_connecting2")?.withRenderingMode(.alwaysTemplate),
                                UIImage(named: "cast_connecting1")?.withRenderingMode(.alwaysTemplate)]
        // Compact map to avoid nil UIImage objects
        castingButton.imageView?.animationImages = connectingImages.compactMap {$0}
        castingButton.imageView?.animationDuration = 2
        
        let barButtonItem = UIBarButtonItem(customView: castingButton)
        self.navigationItem.rightBarButtonItem = barButtonItem
        
        castingButton.heightAnchor.constraint(equalToConstant: 22).isActive = true
        castingButton.widthAnchor.constraint(equalToConstant: 22).isActive = true
        
        self.castingButton = castingButton
        self.barButtonItem = barButtonItem
        
        self.casting = false
    }
    
    
// pragma MARK: - Casting Status Helpers
    
    func startConnectingAnimation() {
        castingButton?.tintColor = UIColor.white
        castingButton?.imageView?.startAnimating()
    }
    
    func stopConnectingAnimation(connected: Bool) {
        castingButton?.imageView?.stopAnimating()
        let castingImage = connected ? "cast_on" : "cast_off"
        castingButton?.setImage(UIImage(named: castingImage)?.withRenderingMode(.alwaysTemplate), for: .normal)
        castingButton?.tintColor = UIColor.blue
    }

    @objc func castButtonTapped(sender: UIButton) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if let device = castController?.connectedDevice {
            alertController.title = device.name
            alertController.message = "Select an action"
            
            let disconnetAction = UIAlertAction(title: "Disconnect", style: .destructive) { [weak self] (action) in
                guard let self = self else { return }
                self.castController?.disconnect()
            }
            
            if self.casting {
                alertController.addAction(UIAlertAction(title: "Stop casting", style: .default, handler: { [weak self] (action) in
                    guard let self = self else { return }
                    self.castController?.stopCasting()
                }))
            } else {
                alertController.addAction(UIAlertAction(title: "Cast", style: .default, handler: { [weak self] (action) in
                    guard let self = self else { return }
                    self.castController?.cast()
                }))
            }
            alertController.addAction(disconnetAction)
        } else {
            alertController.title = "Connect to"
            self.castController?.availableDevices.forEach({ (castingDevice) in
                let deviceSelection = UIAlertAction(title: castingDevice.name, style: .default, handler: { [weak self] (action) in
                    guard let self = self else { return }
                    self.castController?.connect(to: castingDevice)
                    self.startConnectingAnimation()
                })
                alertController.addAction(deviceSelection)
            })
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

}


// MARK: JWCastingDelegate implementation

extension CastingViewController: JWCastingDelegate {
    
    func onCastingDevicesAvailable(_ devices: [JWCastingDevice]) {
        self.avilableDevices = devices
        if devices.isEmpty {
            self.navigationItem.rightBarButtonItem = nil
        } else if barButtonItem == nil {
            self.setupCastingButton()
            self.stopConnectingAnimation(connected: false)
        }
    }
    
    func onConnected(to device: JWCastingDevice) {
        self.stopConnectingAnimation(connected: true)
    }
    
    func onDisconnected(fromCastingDevice error: Error?) {
        if let error = error { print("Casting error: ", error) }
        self.stopConnectingAnimation(connected: false)
    }
    
    func onConnectionTemporarilySuspended() {
        self.startConnectingAnimation()
    }
    
    func onConnectionRecovered() {
        self.stopConnectingAnimation(connected: true)
    }
    
    func onConnectionFailed(_ error: Error) {
        print("Casting error: ", error)
        self.stopConnectingAnimation(connected: false)
    }
    
    func onCasting() {
        self.casting = true
    }
    
    func onCastingEnded(_ error: Error?) {
        if let error = error { print("Casting error: ", error) }
        self.casting = false
    }
    
    func onCastingFailed(_ error: Error) {
        print("Casting error: ", error)
        self.casting = false
    }
    
    
}
