//
//  ConvivaViewController.swift
//  JWConviva
//
//  Created by Kateryna Obertynska on 3/18/19.
//  Copyright © 2019 Karim Mourra. All rights reserved.
//

import UIKit

class ConvivaViewController: JWBasicVideoViewController {
    
    var analyticsObserver: AnalyticsObserver?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        analyticsObserver = AnalyticsObserver(player: player)
        player.analyticsDelegate = analyticsObserver
        
    }
    
}
