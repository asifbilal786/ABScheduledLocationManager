//
//  ExampleTableViewController.swift
//  ABScheduledLocationManager
//
//  Created by Asif Bilal on 15/08/2017.
//  Copyright © 2017 Asif Bilal. All rights reserved.
//

import UIKit
import MapKit

class ExampleTableViewController: UITableViewController {

    var locations = [(time: String, location: CLLocation)]()
    
    lazy var scheduleLocationManager = ScheduledLocationManager()
    
    private let startUpdatingLocationsTitle = "Start Updating Locations"
    private let stopUpdatingLocationsTitle = "Stop Updating Locations"
    
    @IBAction func rightBarButtonTapped(_ sender: UIBarButtonItem) {
        
        if sender.title == startUpdatingLocationsTitle {
            
            scheduleLocationManager.getUserLocationWithInterval(interval: 10)
            scheduleLocationManager.delegate = self
            
            sender.title = stopUpdatingLocationsTitle
        } else {
            scheduleLocationManager.stopGettingUserLocation()
            sender.title = startUpdatingLocationsTitle
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath)

        let (time, location) = locations[indexPath.row]
        
        let decimalPlaces = 5.0
        
        let divisor = pow(10.0, decimalPlaces)
        
        cell.textLabel?.text = "\((location.coordinate.latitude * divisor).rounded() / divisor), \((location.coordinate.latitude * divisor).rounded() / divisor) updated"
        cell.detailTextLabel?.text = "at \(time)"

        return cell
    }

}

extension ExampleTableViewController: ScheduledLocationManagerDelegate {
    
    func scheduledLocationManage(_ manager: ScheduledLocationManager, didUpdateLocation newLocation: CLLocation) {
        
        
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        let seconds = calendar.component(.second, from: date)
        
        let time = "\(hour): \(minutes) : \(seconds)"
        
        let location = newLocation
        
        let locationAtTime = (time, location)
        
        locations.insert(locationAtTime, at: 0)
        tableView.reloadData()
    }
    
    
    func scheduledLocationManage(_ manager: ScheduledLocationManager, didFailWithError error: Error) {
        UIAlertView(title: "", message: error.localizedDescription, delegate: nil, cancelButtonTitle: "Okay").show()
    }
    
}
