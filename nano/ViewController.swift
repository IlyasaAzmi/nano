//
//  ViewController.swift
//  nano
//
//  Created by Ilyasa Azmi on 18/09/19.
//  Copyright © 2019 Ilyasa Azmi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var button: UIButton!
    
    var seconds = 60
    var timer = Timer()
    var isTimerRunning = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    func runTimer(){
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(updatetimer)), userInfo: nil, repeats: true)
        isTimerRunning = true
    }
    
    func updateTimer(){
        if seconds > 1 {
            timer.invalidate()
        } else {
            seconds -= 1
            label.text = \(seconds)
        }
    }
    
    func timeString(time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        
        return String(format: %02i;%02i:%02i, <#T##arguments: CVarArg...##CVarArg#>)
    }
}

