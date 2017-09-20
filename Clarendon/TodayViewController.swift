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

class TodayViewController: UIViewController {
    
    public var dataSource = MetroDataSource()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lastUpdatedLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        
        tableView.dataSource = dataSource
        tableView.register(UINib(nibName: "MetroCell", bundle: Bundle(for: MetroCell.self)), forCellReuseIdentifier: "trainCell")
        extensionContext?.widgetLargestAvailableDisplayMode = .expanded
    }
    
    @IBAction func stationChanged(_ sender: UISegmentedControl) {
        guard let station = Station(index: sender.selectedSegmentIndex) else { return }
        
        MetroFetcher.fetchLines(for: station) { (predictions) in
            guard let predictions = predictions else { return }
            if station == .clarendon {
                self.dataSource.predictions = predictions.filter { $0.destination == .wiehle || $0.destination == .westFalls }
            }
            else {
                self.dataSource.predictions = predictions.filter { $0.destination == .largo }
            }
            DispatchQueue.main.async {
                self.updateTableView()
            }
            
        }
    }
    
    func updateTableView() {
        self.dataSource.lastUpdated = Date()
        self.tableView.reloadData()
        self.lastUpdatedLabel.text = "Last Updated: \(self.dataSource.dateFormatter.string(from: self.dataSource.lastUpdated!))"
    }
}

extension TodayViewController: NCWidgetProviding {
    func widgetPerformUpdate(completionHandler: @escaping (NCUpdateResult) -> Void) {
        MetroFetcher.fetchLines(for: .clarendon) { (predictions) in
            guard let predictions = predictions else {
                completionHandler(.failed)
                return
            }
            
            self.dataSource.predictions = predictions.filter { $0.destination == .wiehle || $0.destination == .westFalls }
            DispatchQueue.main.async {
                self.updateTableView()
                completionHandler(.newData)
            }
        }
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if activeDisplayMode == .compact {
            preferredContentSize = maxSize
        }
        else {
            let size = CGSize(width: tableView.contentSize.width, height: 120.0)
            preferredContentSize = size
        }
    }   
}
