//
//  TimerViewController.swift
//  nano
//
//  Created by Ilyasa Azmi on 19/09/19.
//  Copyright © 2019 Ilyasa Azmi. All rights reserved.
//

import UIKit
import AVFoundation

class TimerViewController: UIViewController {
    
    var seconds = 60
    var timer = Timer()
    var isTimerRunning = false
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var startPauseButton: UIButton! {
        didSet {
            startPauseButton.setBackgroundColor(.green, for: .normal)
            startPauseButton.setBackgroundColor(.gray, for: .selected)
            startPauseButton.setTitle("Pause", for: .selected)
        }
    }
    
    var player: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        startPauseButton.layer.cornerRadius = startPauseButton.frame.size.width/2
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    private lazy var stopWatch = Stopwatch(timeUpdated: { [weak self] timeInterval in
        guard let strongSelf = self else { return }
        strongSelf.timerLabel.text = strongSelf.timeString(from: timeInterval)
    })
    
    deinit {
        stopWatch.stop()
    }
    
    @IBAction func toggle(_ sendler: UIButton) {
        sendler.isSelected = !sendler.isSelected
        stopWatch.toggle()
    }
    
    func timeString(from timeInterval: TimeInterval) -> String {
        let seconds = Int(timeInterval.truncatingRemainder(dividingBy: 60))
        let minutes = Int(timeInterval.truncatingRemainder(dividingBy: 60 * 60) / 60)
        let hours = Int(timeInterval / 3600)
        print(seconds)
        if seconds == 20 {
            playSound()
        }
        return String(format: "%.2d:%.2d:%.2d", hours, minutes, seconds)
    }
    
    func playSound() {
        guard let url = Bundle.main.url(forResource: "water", withExtension: "mp3") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            guard let player = player else { return }
            
            player.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }

}
