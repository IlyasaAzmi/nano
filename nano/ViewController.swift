//
//  ViewController.swift
//  nano
//
//  Created by Ilyasa Azmi on 18/09/19.
//  Copyright © 2019 Ilyasa Azmi. All rights reserved.
//

import UIKit
import LocalAuthentication

class ViewController: UIViewController {
    
    var seconds = 60
    var timer = Timer()
    var isTimerRunning = false
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var startPauseButton: UIButton! {
        didSet {
            startPauseButton.setBackgroundColor(.green, for: .normal)
            startPauseButton.setBackgroundColor(.yellow, for: .selected)
        }
    }
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var statisticsButton: UIButton!
    @IBOutlet weak var pointsButton: UIButton!
    @IBOutlet weak var timerView: UIView!
    
    
    // An authentication context stored at class scope so it's available for use during UI updates.
    var context = LAContext()
    
    enum AuthenticationState {
        case loggedin, loggedout
    }
    
    /// The current authentication state.
    var state = AuthenticationState.loggedout {
        
        // Update the UI on a change.
        didSet {
//            loginButton.isHighlighted = state == .loggedin  // The button text changes on highlight.
//            timerView.backgroundColor = state == .loggedin ? .green : .red
            
            // FaceID runs right away on evaluation, so you might want to warn the user.
            //  In this app, show a special Face ID prompt if the user is logged out, but
            //  only if the device supports that kind of authentication.
//            faceIdLabel.isHidden = (state == .loggedin) || (context.biometryType != .faceID)
            timerLabel.isHidden = (state == .loggedout)
            startPauseButton.isHidden = (state == .loggedout)
            resetButton.isHidden = (state == .loggedout)
            nextButton.isHidden = (state == .loggedout)
            statisticsButton.isHidden = (state == .loggedout)
            pointsButton.isHidden = (state == .loggedout)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // The biometryType, which affects this app's UI when state changes, is only meaningful
        //  after running canEvaluatePolicy. But make sure not to run this test from inside a
        //  policy evaluation callback (for example, don't put next line in the state's didSet
        //  method, which is triggered as a result of the state change made in the callback),
        //  because that might result in deadlock.
        context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)
        
        // Set the initial app state. This impacts the initial state of the UI as well.
        state = .loggedout
        loginFaceId()
    }
    
    @IBAction func tapLoginButton(_ sender: Any) {
        if state == .loggedin {

            // Log out immediately.
            state = .loggedout

        } else {

            // Get a fresh context for each login. If you use the same context on multiple attempts
            //  (by commenting out the next line), then a previously successful authentication
            //  causes the next policy evaluation to succeed without testing biometry again.
            //  That's usually not what you want.
            context = LAContext()

            context.localizedCancelTitle = "Enter Username/Password"

            // First check if we have the needed hardware support.
            var error: NSError?
            if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {

                let reason = "Log in to your account"
                context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason ) { success, error in

                    if success {

                        // Move to the main thread because a state update triggers UI changes.
                        DispatchQueue.main.async { [unowned self] in
                            self.state = .loggedin
                        }

                    } else {
                        print(error?.localizedDescription ?? "Failed to authenticate")

                        // Fall back to a asking for username and password.
                        // ...
                    }
                }
            } else {
                print(error?.localizedDescription ?? "Can't evaluate policy")

                // Fall back to a asking for username and password.
                // ...
            }
        }
    }
    
    func loginFaceId() {
        if state == .loggedin {
            
            // Log out immediately.
            state = .loggedout
            
        } else {
            
            // Get a fresh context for each login. If you use the same context on multiple attempts
            //  (by commenting out the next line), then a previously successful authentication
            //  causes the next policy evaluation to succeed without testing biometry again.
            //  That's usually not what you want.
            context = LAContext()
            
            context.localizedCancelTitle = "Enter Username/Password"
            
            // First check if we have the needed hardware support.
            var error: NSError?
            if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
                
                let reason = "Log in to your account"
                context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason ) { success, error in
                    
                    if success {
                        
                        // Move to the main thread because a state update triggers UI changes.
                        DispatchQueue.main.async { [unowned self] in
                            self.state = .loggedin
                        }
                        
                    } else {
                        print(error?.localizedDescription ?? "Failed to authenticate")
                        
                        // Fall back to a asking for username and password.
                        // ...
                    }
                }
            } else {
                print(error?.localizedDescription ?? "Can't evaluate policy")
                
                // Fall back to a asking for username and password.
                // ...
            }
        }
    }
    
    
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
    
    @IBAction func reset(_ sendler: UIButton) {
        stopWatch.stop()
        startPauseButton.isSelected = false
    }
    
    func timeString(from timeInterval: TimeInterval) -> String {
        let seconds = Int(timeInterval.truncatingRemainder(dividingBy: 60))
        let minutes = Int(timeInterval.truncatingRemainder(dividingBy: 60 * 60) / 60)
        let hours = Int(timeInterval / 3600)
        return String(format: "%.2d:%.2d:%.2d", hours, minutes, seconds)
    }
}

