//
//  InterfaceController.swift
//  Metro Watch Extension
//
//  Created by Jason Ji on 9/20/17.
//  Copyright © 2017 Jason Ji. All rights reserved.
//

import WatchKit
import Foundation
import MetroKitWatch

class ClarendonInterfaceController: WKInterfaceController {

    @IBOutlet var loadingContainerGroup: WKInterfaceGroup!
    @IBOutlet var dataContainerGroup: WKInterfaceGroup!
    
    @IBOutlet var table: WKInterfaceTable!
    @IBOutlet var lastUpdatedLabel: WKInterfaceLabel!
    
    var predictions: [Prediction]?
    var lastUpdateManager = LastUpdateManager(displayStyle: .short)
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        refresh()
    }
    
    override func willActivate() {
        super.willActivate()
    }
    
    override func didDeactivate() {
        super.didDeactivate()
    }

    @IBAction func refresh() {
        // TODO: spinner
        dataContainerGroup.setHidden(true)
        loadingContainerGroup.setHidden(false)
        
        fetchLines()
    }
    
    func fetchLines() {
        MetroFetcher.fetchLines(for: .clarendon) { (predictions) in
            DispatchQueue.main.async {
                guard let predictions = predictions else {
                    print("Something's wrong with the predictions")
                    // TODO: display an error icon
                    return
                }
                self.predictions = predictions/*.filter { $0.destination == .wiehle || $0.destination == .westFalls }*/
                self.lastUpdateManager.lastUpdated = Date()
                self.reloadInterfaceTable()
                
                self.dataContainerGroup.setHidden(false)
                self.loadingContainerGroup.setHidden(true)
            }
        }
    }
    
    func reloadInterfaceTable() {
        guard let predictions = predictions else {
            table.setNumberOfRows(0, withRowType: "metroRow")
            return
        }
        
        table.setNumberOfRows(predictions.count, withRowType: "metroRow")
        for (i, prediction) in predictions.enumerated() {
            guard let row = table.rowController(at: i) as? MetroTableRowController else { return }
            
            row.lineView.setBackgroundColor(prediction.line.transparentLineColor)
            row.destinationLabel.setText(prediction.destination.rawValue)
            row.statusLabel.setText(prediction.status.displayString)
        }
        
        lastUpdatedLabel.setText(lastUpdateManager.lastUpdateString)
    }
}

