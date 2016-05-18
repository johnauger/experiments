//
//  ViewController.swift
//  experiments
//
//  Created by John Auger on 24/02/2016.
//  Copyright © 2016 johnauger. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var slackButton: UIButton!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var regionLabel: UILabel!
    
    let colors = [
        /*purple*/  53918: UIColor(red: 84/255, green: 77/255, blue: 160/255, alpha: 1),
        /*blue*/  64471: UIColor(red: 142/255, green: 212/255, blue: 220/255, alpha: 1),
        /*green*/  30812: UIColor(red: 162/255, green: 213/255, blue: 181/255, alpha: 1)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "locationUpdate:",
            name: "LOCATION_UPDATE",
            object: nil)
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        appDelegate.startBeaconTracking()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func locationUpdate(notification: NSNotification){
        
        let userInfo:Dictionary<String,String!> = notification.userInfo as! Dictionary<String,String!>
        let messageString = userInfo["message"]! as NSString
        
        slack(nil, message: messageString)
        
        let notification = UILocalNotification()
        notification.fireDate = NSDate(timeIntervalSinceNow: 5)
        notification.alertBody = messageString as String
        notification.alertAction = "OK"
        notification.soundName = UILocalNotificationDefaultSoundName
        //        notification.userInfo = ["CustomField1": "w00t"]
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        
    }
    
    @IBAction func slack(sender: UIButton?, message: NSString) {
        let slackUrl = "https://hooks.slack.com/services/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"
        let payload = "payload={\"channel\": \"#general\", \"username\": \"bot\", \"icon_emoji\":\":calling:\", \"text\": \"\(message)\"}"
        let data = (payload as NSString).dataUsingEncoding(NSUTF8StringEncoding)
        if let url = NSURL(string: slackUrl)
        {
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            request.HTTPBody = data
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(request){
                (data, response, error) -> Void in
                if (error != nil) {
                    print("error:\(error!.localizedDescription): \(error!.userInfo)")
                }
                else if (data != nil) {
                    if let str = NSString(data: data!, encoding: NSUTF8StringEncoding) {
                        print("\(str)")
                    }
                    else {
                        print("error")
                    }
                }
            }
            task.resume()
        }
        else {
            print("url invalid")
        }
        
    }
    
    
}

