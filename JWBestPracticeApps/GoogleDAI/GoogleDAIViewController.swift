//
//  ViewController.swift
//  GoogleDAI
//
//  Created by Stephen Seibert  on 3/30/20.
//  Copyright © 2020 Karim Mourra. All rights reserved.
//

import UIKit

class GoogleDAIViewController: BasicVideoViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func createConfig() -> JWConfig {
        let config = super.createConfig()

        // Create the DAI Config
        let daiConfig = JWGoogimaDaiConfig(assetKey: "sN_IYUG8STe1ZzhIIE_ksA")

        // Create the Ad Config
        let adConfig = JWAdConfig()
        adConfig.client = .googimaDAI
        adConfig.googimaDaiSettings = daiConfig

        config.advertising = adConfig
        return config
    }
}

