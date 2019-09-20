//
//  PushUpViewController.swift
//  nano
//
//  Created by Ilyasa Azmi on 19/09/19.
//  Copyright © 2019 Ilyasa Azmi. All rights reserved.
//

import UIKit
import AVFoundation
import HealthKit

class PushUpViewController: UIViewController {
    
    let healthStore = HKHealthStore()
    
    var seconds = 60
    var timer = Timer()
    var isTimerRunning = false
    
    var isProximity = false
    var pitchDegree = 0
    var intruksiInt = 0
    var hitung = 0
    
    @IBOutlet weak var pushUpCountLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    var player: AVAudioPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        doneButton.layer.cornerRadius = doneButton.frame.size.width/2
        otorisasiHealthKit()
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        activateProximitySensor(isOn: true)
    }
    
    func activateProximitySensor(isOn: Bool) {
        let device = UIDevice.current
        device.isProximityMonitoringEnabled = isOn
        if isOn {
            NotificationCenter.default.addObserver(self, selector: #selector(proximityStateDidChange), name: UIDevice.proximityStateDidChangeNotification, object: device)
        } else {
            NotificationCenter.default.removeObserver(self, name: UIDevice.proximityStateDidChangeNotification, object: device)
        }
    }
    
    @objc func proximityStateDidChange(notification: NSNotification) {
        if let device = notification.object as? UIDevice {
            isProximity = device.proximityState == true
            if (device.proximityState == true) {
                print("ok")
                hitung += 1
                print(hitung)
                
                self.pushUpCountLabel.text = String(hitung)
            } else if (device.proximityState == false) {
                print("oy")
            }
        }
    }
    
    @IBAction func done(_ sender: UIButton){
        savePushUpCount(value: Double(hitung))
    }
    
    func timeString(from timeInterval: TimeInterval) -> String {
        let seconds = Int(timeInterval.truncatingRemainder(dividingBy: 60))
        let minutes = Int(timeInterval.truncatingRemainder(dividingBy: 60 * 60) / 60)
//        let hours = Int(timeInterval / 3600)
        return String(format: "%.2d:%.2d", minutes, seconds)
    }
    
    func playSound() {
        guard let url = Bundle.main.url(forResource: "Success", withExtension: "m4a") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            /* iOS 10 and earlier require the following line:
             player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */
            
            guard let player = player else { return }
            
            player.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func otorisasiHealthKit(){
        let allTypes = Set([HKObjectType.quantityType(forIdentifier: .pushCount)!,
                            HKObjectType.quantityType(forIdentifier: .heartRate)!])
        
        healthStore.requestAuthorization(toShare: allTypes, read: allTypes) { (success, error) in
            if !success {
                print("Error")
            } else {
                print("Data Authorized")
            }
        }
    }
    
    func savePushUpCount(value: Double) {
        //quantityType
        let pushUpQuantityType = HKSampleType.quantityType(forIdentifier: .pushCount)!
        
        //unitnya
        let unit = HKUnit.count()
        
        //quantity
        let hkQuantity = HKQuantity(unit: unit, doubleValue: value)
        
        //start endDate
        let startDate = Date()
        let endDate = Date()
        
        //HKObject is the sample
        let pushUpQuantitySample = HKQuantitySample(type: pushUpQuantityType, quantity: hkQuantity, start: startDate, end: endDate)
        healthStore.save(pushUpQuantitySample) { (success, error) in
            if !success {
                print("Error")
            }
        }
    }

}
