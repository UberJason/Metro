//
//  TodayViewController.swift
//  Clarendon
//
//  Created by Jason Ji on 10/8/16.
//  Copyright © 2016 Jason Ji. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdate(completionHandler: @escaping (NCUpdateResult) -> Void) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        let url = URL(string: "https://api.wmata.com/StationPrediction.svc/json/GetPrediction/N01")!
        var request = URLRequest(url: url)
        request.setValue("198e27cd2440473a9d36c0bd3b08e41b", forHTTPHeaderField:"api_key")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            print(String(data: data!, encoding: .utf8)!)
            completionHandler(NCUpdateResult.newData)
        }
        task.resume()
        

    }
    
}
