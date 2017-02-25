//
//  TodayViewController.swift
//  Clarendon
//
//  Created by Jason Ji on 10/8/16.
//  Copyright © 2016 Jason Ji. All rights reserved.
//

import UIKit
import NotificationCenter
import MetroKit

class TodayViewController: UIViewController, NCWidgetProviding {
    
    var predictions: [Prediction]?
    var lastUpdated: Date?
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lastUpdatedLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        
        tableView.register(UINib(nibName: "MetroCell", bundle: Bundle(for: MetroCell.self)), forCellReuseIdentifier: "trainCell")
        extensionContext?.widgetLargestAvailableDisplayMode = .expanded
    }
    
    func widgetPerformUpdate(completionHandler: @escaping (NCUpdateResult) -> Void) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        Fetcher.fetchWiehleLines { (predictions) in
            guard let predictions = predictions else {
                completionHandler(.failed)
                return
            }
            
            self.predictions = predictions.filter { $0.destination == .wiehle || $0.destination == .westFalls }
            self.lastUpdated = Date()
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.lastUpdatedLabel.text = "Last Updated: \(self.lastUpdated!)"
                completionHandler(.newData)
            }
            
        }
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if activeDisplayMode == .compact {
            preferredContentSize = maxSize
        }
        else {
            let size = CGSize(width: tableView.contentSize.width, height: tableView.contentSize.height + 30.0)
            preferredContentSize = size
        }
    }
    
}

extension TodayViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return predictions?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "trainCell", for: indexPath) as! MetroCell
        if let prediction = predictions?[indexPath.row] {
            cell.lineView.backgroundColor = prediction.line.lineColor()
            cell.destinationLabel.text = prediction.destination.destinationName()
            cell.statusLabel.text = prediction.status.displayString()
        }
        return cell
    }
}
