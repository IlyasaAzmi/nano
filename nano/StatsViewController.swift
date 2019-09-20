//
//  StatsViewController.swift
//  nano
//
//  Created by Ilyasa Azmi on 19/09/19.
//  Copyright © 2019 Ilyasa Azmi. All rights reserved.
//

import UIKit
import HealthKit

class StatsViewController: UIViewController {
    
    let healthStore = HKHealthStore()
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var stepCountLabel: UILabel!
    @IBOutlet weak var pushUpLabel: UILabel!
    @IBOutlet weak var sitUpLabel: UILabel!
    
    @IBOutlet weak var distanceNumberLabel: UILabel!
    @IBOutlet weak var stepCountNumberLabel: UILabel!
    @IBOutlet weak var pushUpNumberLabel: UILabel!
    @IBOutlet weak var sitUpNumberLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        otorisasiHealthKit()
        ngambilDataDistances()
        ngambilDataStepCount()
    }
    
    func otorisasiHealthKit(){
        let allTypes = Set([HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
                            HKObjectType.quantityType(forIdentifier: .stepCount)!,
                            HKObjectType.quantityType(forIdentifier: .heartRate)!])
        
        healthStore.requestAuthorization(toShare: allTypes, read: allTypes) { (success, error) in
            if !success {
                print("Error")
            } else {
                print("Data Authorized")
            }
        }
    }
    
    func ngambilDataStepCount() {
        // Read Step Count
        guard let stepsSampleType  = HKSampleType.quantityType(forIdentifier: .stepCount) else { return }
        
        //predicate boleh nil
//        let startDate = Date.distantPast
        let cal = Calendar(identifier: .gregorian)
        let noLimit = HKObjectQueryNoLimit
        let today = Date()
        let startDate = cal.date(bySettingHour: 0, minute: 0, second: 0, of: today)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: today, options: .strictEndDate)
        
        //limit
//        let limit = 1
        
        //descriptor boleh nil
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let stepsSampleQuery = HKSampleQuery(sampleType: stepsSampleType, predicate: predicate, limit: noLimit, sortDescriptors: [sortDescriptor]) { (query, resultSamples, error) in
            var total = 0
            DispatchQueue.main.async {
                guard let samples = resultSamples as? [HKQuantitySample] else { return }
                
                for sample in samples {
                    let timestamp = sample.startDate
                    let stepsValue = sample.quantity.doubleValue(for: .count())
                    let stepsShort = Int(stepsValue)
                    total += stepsShort
                    print("Date = \(timestamp) Jumlah Steps =  \(stepsShort)")
                    self.stepCountNumberLabel.text = String(total)
                }
            }
        }
        healthStore.execute(stepsSampleQuery)
    }
    
    func ngambilDataDistances() {
        // Read Walking Distances
        guard let distancesSampleType  = HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning) else { return }
        
        //predicate boleh nil
//        let startDate = Date.distantPast
        let cal = Calendar(identifier: .gregorian)
        let noLimit = HKObjectQueryNoLimit
        let today = Date()
        let startDate = cal.date(bySettingHour: 0, minute: 0, second: 0, of: today)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: today, options: .strictEndDate)
        
        //limit
//        let limit = 1
        
        //descriptor boleh nil
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let distancesSampleQuery = HKSampleQuery(sampleType: distancesSampleType, predicate: predicate, limit: noLimit, sortDescriptors: [sortDescriptor]) { (query, resultSamples, error) in
            //set variable total
            var total = 0.0
            DispatchQueue.main.async {
                guard let samples = resultSamples as? [HKQuantitySample] else { return }
                
                for sample in samples {
                    let timestamp = sample.startDate
                    let distancesValue = sample.quantity.doubleValue(for: .meter())
                    let distancesInKm = distancesValue
                    total += distancesInKm
                    let intTotal = Int(total)
                    print("Date = \(timestamp) Jarak Tempuh =  \(intTotal)")
                    self.distanceNumberLabel.text = String(intTotal)
                }
            }
        }
        healthStore.execute(distancesSampleQuery)
    }

}
