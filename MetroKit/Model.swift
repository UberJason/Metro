//
//  Model.swift
//  Metro
//
//  Created by Jason Ji on 2/25/17.
//  Copyright © 2017 Jason Ji. All rights reserved.
//

import Foundation

public enum Station: String {
    case clarendon = "Clarendon",
    wiehle = "Wiehle Reston-East",
    largo = "Largo Town Center",
    westFalls = "West Falls Church",
    newCarrollton = "New Carrollton",
    vienna = "Vienna/Fairfax-GMU"
    
    public var code: String {
        switch self {
        case .clarendon: return "K02"
        case .wiehle: return "N06"
        case .largo: return "G05"
        case .westFalls: return "K06"
        case .newCarrollton: return "D13"
        case .vienna: return "K08"
        }
    }
    public init?(index: Int) {
        switch index {
        case 0: self = .clarendon
        case 1: self = .wiehle
        default: return nil
        }
    }
    public init?(code: String) {
        switch code {
        case "K02": self = .clarendon
        case "N06": self = .wiehle
        case "G05": self = .largo
        case "K06": self = .westFalls
        case "D13": self = .newCarrollton
        case "K08": self = .vienna
        default: return nil
        }
    }
}

public enum TrainLine: String {
    case orange = "OR", silver = "SV"
    
    public var lineColor: UIColor {
        switch self {
        case .orange: return UIColor.orange
        case .silver: return UIColor.lightGray
        }
    }
}
//
//public enum Destination: String {
//    case wiehle = "Wiehle", largo = "Largo", westFalls = "W Fls Ch", newCarrollton = "NewCrltn"
//    
//    public func destinationName() -> String {
//        switch self {
//        case .wiehle: return "Wiehle Reston-East"
//        case .largo: return "Largo Town Center"
//        case .westFalls: return "West Falls Church"
//        case .newCarrollton: return "New Carrollton"
//        }
//    }
//}

public enum Status {
    case away(Int)
    case arriving
    case boarding
    
    public init?(string: String) {
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
    
    public var displayString: String {
        switch self {
        case .away(let minutes): return minutes == 1 ? "\(minutes) minute" : "\(minutes) minutes"
        case .arriving: return "ARRIVING"
        case .boarding: return "BOARDING"
        }
    }
}

public class Prediction {
    public var destination: Station
    public var line: TrainLine
    public var status: Status
    
    public init(destination: Station, line: TrainLine, status: Status) {
        self.destination = destination
        self.line = line
        self.status = status
    }
    
    convenience init?(dictionary: [String:Any]) {
        guard let dest = dictionary["DestinationCode"] as? String,
            let lineString = dictionary["Line"] as? String,
            let minutes = dictionary["Min"] as? String
            else {
                print("Error with that dictionary"); return nil
        }
        
        let destination = Station(code: dest)
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

public class Fetcher {
    public static func fetchLines(for station: Station, completion: @escaping (_ predictions: [Prediction]?) -> ()) {
        let code = station.code
        let url = URL(string: "https://api.wmata.com/StationPrediction.svc/json/GetPrediction/\(code)")!
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
