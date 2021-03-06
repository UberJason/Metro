//
//  WiehleInterfaceController.swift
//  Metro Watch Extension
//
//  Created by Jason Ji on 9/20/17.
//  Copyright © 2017 Jason Ji. All rights reserved.
//

import WatchKit
import Foundation


class WiehleInterfaceController: WKInterfaceController {

    @IBOutlet var spinnerScene: WKInterfaceSKScene!
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
//        spinnerScene.presentScene(
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
