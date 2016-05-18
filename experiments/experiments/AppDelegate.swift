//
//  AppDelegate.swift
//  experiments
//
//  Created by John Auger on 24/02/2016.
//  Copyright © 2016 johnauger. All rights reserved.
//

import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    // TEST
    // TEST

    var window: UIWindow?
    var lastRegion: CLRegion?
    
    let locationManager = CLLocationManager()
    var beaconRegion: CLBeaconRegion!
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        beaconRegion = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!, identifier: "Estimotes")
        beaconRegion.notifyEntryStateOnDisplay = true
        
        let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        
        return true
    }
    
    func startBeaconTracking() {
        locationManager.delegate = self;
        locationManager.requestAlwaysAuthorization()
        locationManager.startMonitoringForRegion(beaconRegion)
        locationManager.startRangingBeaconsInRegion(beaconRegion)
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        let defaults = NSUserDefaults.standardUserDefaults()
        let lastClosestBeacon: NSNumber? = defaults.objectForKey("LAST_CLOSEST_BEACON") as? NSNumber
        let lastExitDate: NSDate? = defaults.objectForKey("EXIT_DATE_\(region.identifier)") as? NSDate
        let intervalSeconds: NSTimeInterval = 30
        let beenAwayForLong = lastExitDate != nil && lastExitDate?.timeIntervalSinceNow < 0-intervalSeconds
        
        let knownBeacons = beacons.filter{ $0.proximity != CLProximity.Unknown }
        if (knownBeacons.count > 0) {
            let closestBeacon = knownBeacons[0] as CLBeacon
            
            if (closestBeacon.minor != lastClosestBeacon || beenAwayForLong) {
                // New closest beacon or returning after being away from all beacons for long enough
                
                defaults.setObject(closestBeacon.minor, forKey: "LAST_CLOSEST_BEACON")
                
                if (closestBeacon.minor == 64471) {
                    NSNotificationCenter.defaultCenter().postNotificationName("LOCATION_UPDATE", object:nil, userInfo:["message":"Home", "direction":"enter"])
                    
                } else if (closestBeacon.minor == 53918) {
                    NSNotificationCenter.defaultCenter().postNotificationName("LOCATION_UPDATE", object:nil, userInfo:["message":"Office", "direction":"enter"])
                }
                
                locationManager.stopRangingBeaconsInRegion(beaconRegion)
            } else {
                locationManager.stopRangingBeaconsInRegion(beaconRegion)
            }
        }
    }
    
    
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        locationManager.startRangingBeaconsInRegion(beaconRegion)
    }
    
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        defaults.setObject(NSDate(), forKey: "EXIT_DATE_\(region.identifier)")
        
        locationManager.stopRangingBeaconsInRegion(beaconRegion)
        NSNotificationCenter.defaultCenter().postNotificationName("LOCATION_UPDATE", object:nil, userInfo:["message":"Goodbye!","direction":"exit"])
    }
    
    func locationManager(manager: CLLocationManager, didStartMonitoringForRegion region: CLRegion) {
        print (region)
    }
    
    
}

