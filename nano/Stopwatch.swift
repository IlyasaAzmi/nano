//
//  Stopwatch.swift
//  nano
//
//  Created by Ilyasa Azmi on 19/09/19.
//  Copyright © 2019 Ilyasa Azmi. All rights reserved.
//

import Foundation

class Stopwatch {
    
    //MARK: Private Properties
    
    private let step: Double
    private var timer: Timer?
    
    //the time when counting was started
    private(set) var from: Date?
    
    //the time when counting was stopped
    private(set) var to: Date?
    
    //the time when user pause timer last one
    private var timeIntervalTimelapsFrom: TimeInterval?
    //the total time before user paused timer
    private var timerSavedTime: TimeInterval = 0
    
    typealias TimeUpdated = (_ time: Double)->Void
    let timeUpdated: TimeUpdated
    
    //MARK: Initialization
    
    init(step: Double = 1.0, timeUpdated: @escaping TimeUpdated) {
        self.step = step
        self.timeUpdated = timeUpdated
    }
    
    deinit {
        print("Stopwatch success deinited")
        deinitTimer()
    }
    
    //MARK: Timer Actions
    
    func toggle() {
        guard timer != nil else {
            initTimer()
            return
        }
        deinitTimer()
    }
    
    func stop() {
        deinitTimer()
        from = nil
        to = nil
        timerSavedTime = 0
        timeUpdated(0)
    }
    
    private func initTimer() {
        let action: (Timer)->Void = { [weak self] timer in
            guard let strongSelf = self else {
                return
            }
            let to = Date().timeIntervalSince1970
            let timeIntervalForm = strongSelf.timeIntervalTimelapsFrom ?? to
            let time = strongSelf.timerSavedTime + (to - timeIntervalForm)
            strongSelf.timeUpdated(round(time))
        }
        if from == nil {
            from = Date()
        }
        if timeIntervalTimelapsFrom == nil {
            timeIntervalTimelapsFrom = Date().timeIntervalSince1970
        }
        timer = Timer.scheduledTimer(withTimeInterval: step, repeats: true, block: action)
    }
    
    private func deinitTimer() {
        //Saving last timelaps
        if let timeIntervalTimelapsFrom = timeIntervalTimelapsFrom {
            let to = Date().timeIntervalSince1970
            timerSavedTime += to - timeIntervalTimelapsFrom
        }
        //Invalidating
        timer?.invalidate()
        timer = nil
        timeIntervalTimelapsFrom = nil
    }
}
