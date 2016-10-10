//
//  TodayViewController.swift
//  Clarendon
//
//  Created by Jason Ji on 10/8/16.
//  Copyright © 2016 Jason Ji. All rights reserved.
//

import UIKit
import NotificationCenter

enum TrainLine: String {
    case orange = "OR", silver = "SV"
    
    func lineColor() -> UIColor {
        switch self {
        case .orange: return UIColor.orange
        case .silver: return UIColor.lightGray
        }
    }
}

enum Destination: String {
    case wiehle = "Wiehle", largo = "Largo", westFalls = "W Fls Ch", newCarrollton = "NewCrltn"
    
    func destinationName() -> String {
        switch self {
        case .wiehle: return "Wiehle Reston-East"
        case .largo: return "Largo Town Center"
        case .westFalls: return "West Falls Church"
        case .newCarrollton: return "New Carrollton"
        }
    }
}

enum Status {
    case away(Int)
    case arriving
    case boarding
    
    init?(string: String) {
        if string == "ARR" {
            self = .arriving
        }
        else if string == "BRD" {
            self = .boarding
        }
        else if let minutes = Int(string) {
            self = .away(minutes)
        }
        else {
            return nil
        }
    }
    
    func displayString() -> String {
        switch self {
        case .away(let minutes): return minutes == 1 ? "\(minutes) minute" : "\(minutes) minutes"
        case .arriving: return "ARRIVING"
        case .boarding: return "BOARDING"
        }
    }
}

class Prediction {
    var destination: Destination
    var line: TrainLine
    var status: Status
    
    init(destination: Destination, line: TrainLine, status: Status) {
        self.destination = destination
        self.line = line
        self.status = status
    }
    
    convenience init?(dictionary: [String:Any]) {
        guard let dest = dictionary["Destination"] as? String,
            let lineString = dictionary["Line"] as? String,
            let minutes = dictionary["Min"] as? String
        else {
            print("Error with that dictionary"); return nil
        }
        
        let destination = Destination(rawValue: dest)
        let line = TrainLine(rawValue: lineString)
        let status = Status(string: minutes)
        
        if let destination = destination, let line = line, let status = status {
            self.init(destination: destination, line: line, status: status)
        }
        else {
            return nil
        }
    }
}

class Fetcher {
    static func fetchWiehleLines(completion: @escaping (_ predictions: [Prediction]?) -> ()) {
        let url = URL(string: "https://api.wmata.com/StationPrediction.svc/json/GetPrediction/K02")!
        var request = URLRequest(url: url)
        request.setValue("198e27cd2440473a9d36c0bd3b08e41b", forHTTPHeaderField:"api_key")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            guard let data = data,
                let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any],
            let predictionsDicts = json?["Trains"] as? [[String:Any]]
            else {
                completion(nil); return
            }
            print(String(data: data, encoding: .utf8)!)
            
            var predictions = [Prediction]()
            for dict in predictionsDicts {
                if let prediction = Prediction(dictionary: dict) {
                    predictions.append(prediction)
                }
            }
            completion(predictions)
        }
        task.resume()
    }
}

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
