//
//  ScheduledLocationManager.swift
//  ABScheduledLocationManager
//
//  Created by Asif Bilal on 11/08/2017.
//  Copyright © 2017 Asif Bilal. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

private let kMaxBGTime: UInt = 170 // 3 min - 10 seconds (as bg task is killed faster)
private let kTimeToGetLocations: UInt = 3 // time to wait for locations

@objc protocol ScheduledLocationManagerDelegate : class {
    func scheduledLocationManage(_ manager: ScheduledLocationManager, didFailWithError error: Error)
    func scheduledLocationManage(_ manager: ScheduledLocationManager, didUpdateLocation newLocation: CLLocation)
    @objc optional func scheduledLocationManageDidNotAuthorized(_ manager: ScheduledLocationManager)
}


public class ScheduledLocationManager : NSObject {
    
    weak var delegate: ScheduledLocationManagerDelegate?
    
    //private variables
    
    private var bgTask = UIBackgroundTaskInvalid
    private let locationManager = CLLocationManager()
    fileprivate var checkLocationTimer: Timer?
    private var checkLocationInterval: UInt = 0
    fileprivate var waitForLocationUpdatesTimer : Timer?
    
    private var isLocationUpdated = false
    
    private let notifCenter = NotificationCenter.default
    private let application = UIApplication.shared
    
    
    override init() {
        
        super.init()
        
        // configurations
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        
        notifCenter.addObserver(self, selector: #selector(applicationDidEnterBackground), name: .UIApplicationDidEnterBackground, object: nil)
        notifCenter.addObserver(self, selector: #selector(applicationDidBecomeActive), name: .UIApplicationDidBecomeActive, object: nil)
        
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        }
        
    }
    
    deinit {
        
    }
    
    // MARK: Added Methods
    
    fileprivate func startUpdatingLocation() {
        
        isLocationUpdated = true
        locationManager.allowsBackgroundLocationUpdates = true
        
        locationManager.startUpdatingLocation()
        
    }
    
    fileprivate func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    fileprivate func updatedLocation(newLocation: CLLocation) {
        
        if !isLocationUpdated { return}
        
        isLocationUpdated = false
        
        delegate?.scheduledLocationManage(self, didUpdateLocation: newLocation)
        
    }
    
    
    // MARK: Public Available Methods
    
    public func getUserLocationWithMaxInterval() {
        getUserLocationWithInterval(interval: kMaxBGTime)
    }
    
    public func getUserLocationWithInterval(interval: UInt) {
        
        if CLLocationManager.authorizationStatus() != .authorizedAlways { return}
        
        checkLocationInterval = (interval > kMaxBGTime) ? kMaxBGTime : interval
        if checkLocationInterval > kTimeToGetLocations {checkLocationInterval = checkLocationInterval - kTimeToGetLocations}
        
        startUpdatingLocation()
        
    }
    
    public func stopGettingUserLocation() {
        
        stopUpdatingLocation()
        stopBackgroundTask()
        stopCheckLocationTimer()
        stopWaitForLocationUpdatesTimer()
        delegate = nil
        
        notifCenter.removeObserver(self, name: .UIApplicationDidEnterBackground, object: nil)
        notifCenter.removeObserver(self, name: .UIApplicationDidBecomeActive, object: nil)
        
    }
    
    // MARK: Timer Methods
    
    func timerEvent(timer: Timer?) {
        
        stopCheckLocationTimer()
        startUpdatingLocation()
        
        perform(#selector(stopBackgroundTask), with: nil, afterDelay: 1)
        
    }
    
    private func startCheckLocationTimer() {
        
        stopCheckLocationTimer()
        
        checkLocationTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(checkLocationInterval), repeats: false, block: { timer in
            self.timerEvent(timer: timer)
        })
        
    }
    
    private func stopCheckLocationTimer() {
        
        checkLocationTimer?.invalidate()
        checkLocationTimer = nil
        
    }
    
    fileprivate func startWaitForLocationUpdatesTimer() {
        stopWaitForLocationUpdatesTimer()
        
        waitForLocationUpdatesTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(kTimeToGetLocations), repeats: false, block: { timer in
            
            self.stopWaitForLocationUpdatesTimer()
            
            if self.application.applicationState == .background || self.application.applicationState == .inactive && self.bgTask == UIBackgroundTaskInvalid {
                self.startBackgroundTask()
            }
            
            self.startCheckLocationTimer()
            self.stopUpdatingLocation()
            
        })
    }
    
    private func stopWaitForLocationUpdatesTimer() {
        
        waitForLocationUpdatesTimer?.invalidate()
        waitForLocationUpdatesTimer = nil
        
    }
    
    // MARK: Background Methods
    
    private func startBackgroundTask() {
        
        
        stopBackgroundTask()
        
        bgTask = application.beginBackgroundTask(expirationHandler: {
            
            //in case bg task is killed faster than expected, try to start Location Service
            self.timerEvent(timer: self.checkLocationTimer)
        })
        
        
    }
    
    @objc private func stopBackgroundTask() {
        
        if bgTask != UIBackgroundTaskInvalid {
            
            application.endBackgroundTask(bgTask)
            bgTask = UIBackgroundTaskInvalid;
            
        }
        
    }
    
    
    // MARK: Notifications Observers Methods
    
    @objc func applicationDidEnterBackground(notification: NSNotification) {
        
        if isLocationServiceAvailable() {
            startBackgroundTask()
        }
        
    }
    
    @objc func applicationDidBecomeActive(notification: NSNotification) {
        
        stopBackgroundTask()
        
        if !isLocationServiceAvailable() {
            
            let error = NSError(domain: "your.domain", code: 1, userInfo: [NSLocalizedDescriptionKey : "Authorization status denied"])
            delegate?.scheduledLocationManage(self, didFailWithError: error)
            
        }
        
        
    }
    
    // MARK: Helper Methods
    
    private func isLocationServiceAvailable() -> Bool {
        
        if !CLLocationManager.locationServicesEnabled() || CLLocationManager.authorizationStatus() == .denied || CLLocationManager.authorizationStatus() == .restricted {
            return false
        }
        
        return true
        
    }
    
}

extension ScheduledLocationManager: CLLocationManagerDelegate {
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard checkLocationTimer == nil else {
            //sometimes it happens that location manager does not stop even after stopUpdationLocations
            return
        }

        let newLocation = locations.first
        updatedLocation(newLocation: newLocation!)
        
        if waitForLocationUpdatesTimer == nil {
            startWaitForLocationUpdatesTimer()
        }
        
        
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        delegate?.scheduledLocationManage(self, didFailWithError: error)
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .denied {
            delegate?.scheduledLocationManageDidNotAuthorized?(self)
        }
        
    }
    
}

