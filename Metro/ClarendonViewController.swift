//
//  ViewController.swift
//  Metro
//
//  Created by Jason Ji on 10/8/16.
//  Copyright © 2016 Jason Ji. All rights reserved.
//

import UIKit
import MetroKit

class ClarendonViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    public var dataSource = MetroDataSource(withTitles: true)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.dataSource = dataSource
        tableView.register(UINib(nibName: "MetroCell", bundle: Bundle(for: MetroCell.self)), forCellReuseIdentifier: "trainCell")
        tableView.refreshControl = {
            let refresh = UIRefreshControl()
            refresh.addTarget(self, action: #selector(refreshData), for: .valueChanged)
            return refresh
        }()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshData()
    }
    
    func refreshData() {
        Fetcher.fetchLines(for: .clarendon) { (predictions) in
            self.tableView.refreshControl?.endRefreshing()
            guard let predictions = predictions else {
                let alert = UIAlertController(title: "Error", message: "Couldn't fetch lines for Clarendon.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            self.dataSource.predictions = predictions
            DispatchQueue.main.async {
                self.updateTableView()
            }
        }
    }
    
    func updateTableView() {
        self.dataSource.lastUpdated = Date()
        self.tableView.reloadData()
    }
}
