//
//  ViewController.swift
//  BackgroundModeDemo
//
//  Created by sotsys-236 on 30/08/19.
//  Copyright © 2019 sotsys-236. All rights reserved.
//

import UIKit
import Reachability

class ViewController: UIViewController {
    
    @IBOutlet weak var networkStatus: UILabel!
    @IBOutlet weak var hostNameLabel: UILabel!
    
    var reachability: Reachability?
    let hostNames = [nil, "google.com", "invalidhost"]
    var hostIndex = 0
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var starTaskButton: UIButton!
    @IBOutlet weak var stopTaskButton: UIButton!
    
    var timer = Timer()

    override func viewDidLoad() {
        super.viewDidLoad()
        startHost(at: 0)
    }
    @objc func timerAction() {
        let date = Date()
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([ .hour, .minute, .second], from: date)
        let hour = components.hour
        let minutes = components.minute
        let seconds = components.second
        
        label.text = "\(hour ?? 0):\(minutes ?? 0):\(seconds ?? 0)"
        print("Task is Running...\(label.text!)")
    }
    
    func startBackgroundTask() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        starTaskButton.alpha = 0.5
        starTaskButton.isEnabled = false
        
        stopTaskButton.alpha = 1
        stopTaskButton.isEnabled = true
    }
    
    func stopBackgroundTask() {
        starTaskButton.alpha = 1
        starTaskButton.isEnabled = true
        stopTaskButton.alpha = 0.5
        stopTaskButton.isEnabled = false
        timer.invalidate()
        label.text = ""
    }
    func startHost(at index: Int) {
        stopNotifier()
        setupReachability(hostNames[index], useClosures: true)
        startNotifier()
//        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//            self.startHost(at: (index + 1) % 3)
//        }
    }
    
    func setupReachability(_ hostName: String?, useClosures: Bool) {
        let reachability: Reachability?
        if let hostName = hostName {
            reachability = try? Reachability(hostname: hostName)
            hostNameLabel.text = hostName
        } else {
            reachability = try? Reachability()
            hostNameLabel.text = "No host name"
        }
        self.reachability = reachability
//        print("--- set up with host name: \(hostNameLabel.text!)")
        
        if useClosures {
            reachability?.whenReachable = { reachability in
                self.updateLabelColourWhenReachable(reachability)
            }
            reachability?.whenUnreachable = { reachability in
                self.updateLabelColourWhenNotReachable(reachability)
            }
        } else {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(reachabilityChanged(_:)),
                name: .reachabilityChanged,
                object: reachability
            )
        }
    }
    
    func startNotifier() {
        print("--- start notifier")
        do {
            try reachability?.startNotifier()
        } catch {
            networkStatus.textColor = .red
            networkStatus.text = "Unable to start\nnotifier"
            return
        }
    }
    
    func stopNotifier() {
        print("--- stop notifier")
        reachability?.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: nil)
        reachability = nil
    }
    
    func updateLabelColourWhenReachable(_ reachability: Reachability) {
        print("\(reachability.connection)")
        print("wifi connected")
        
        if reachability.connection == .wifi {
            self.networkStatus.textColor = .green
        } else {
            self.networkStatus.textColor = .blue
        }
        
        self.networkStatus.text = "\(reachability.connection)"
    }
    
    func updateLabelColourWhenNotReachable(_ reachability: Reachability) {
//        print("\(reachability.description) - \(reachability.connection)")
        print("\(reachability.connection)")
        print("wifi disconnected")
        self.networkStatus.textColor = .red
        
        self.networkStatus.text = "\(reachability.connection)"
    }
    
    @objc func reachabilityChanged(_ note: Notification) {
        let reachability = note.object as! Reachability
        
        if reachability.connection != .none {
            updateLabelColourWhenReachable(reachability)
        } else {
            updateLabelColourWhenNotReachable(reachability)
        }
    }
    
    deinit {
        stopNotifier()
    }
}
