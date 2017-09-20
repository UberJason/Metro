//
//  MetroDataSource.swift
//  Metro
//
//  Created by Jason Ji on 3/20/17.
//  Copyright © 2017 Jason Ji. All rights reserved.
//

import UIKit

public class MetroDataSource: NSObject, UITableViewDataSource {
    
    public var predictions: [Prediction]?
    public var lastUpdated: Date?
    public let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()
    public var hasTitles: Bool = false
    
    public init(withTitles: Bool = false) {
        self.hasTitles = withTitles
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return predictions?.count ?? 0
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "trainCell", for: indexPath) as! MetroCell
        if let prediction = predictions?[indexPath.row] {
            cell.configure(with: prediction)
        }
        return cell
    }
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard hasTitles else { return nil }
        return "Upcoming Trains"
    }
    public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        guard hasTitles else { return nil }
        if let lastUpdated = lastUpdated {
            return "Last Updated: \(dateFormatter.string(from: lastUpdated))"
        }
        else {
            return "Last Updated: "
        }
    }
}
