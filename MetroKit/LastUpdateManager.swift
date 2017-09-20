//
//  LastUpdateManager.swift
//  MetroKit
//
//  Created by Jason Ji on 9/20/17.
//  Copyright © 2017 Jason Ji. All rights reserved.
//

import Foundation

public enum DisplayStyle {
    case short, full
}

public struct LastUpdateManager {
    public var displayStyle: DisplayStyle
    public var lastUpdated: Date?
    public let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()
    
    public init(displayStyle: DisplayStyle = .full) {
        self.displayStyle = displayStyle
    }
    
    public var lastUpdateString: String {
        let prefixString = displayStyle == .short ? "Updated: " : "Last Updated: "
        if let lastUpdated = lastUpdated {
            return "\(prefixString)\(dateFormatter.string(from: lastUpdated))"
        }
        else {
            return prefixString
        }
    }
}
