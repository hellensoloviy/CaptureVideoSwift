//
//  HSRecordingManager.swift
//  CameraCaptureVideo
//
//  Created by Hellen Soloviy on 7/20/16.
//  Copyright © 2016 Hellen Soloviy. All rights reserved.
//

import UIKit

protocol HSTimeCounterDelegate {
    func timeUpdate(time: String)
}

class HSRecordingManager: UIView {
    
    
    //MARK: Vars
    var timeDelegate: HSTimeCounterDelegate?
    
    var isRecording = false {
        didSet {
            if isRecording {
                prepareRecordControls()
            }
        }
    }
    
    var isSaving = false
    var camera : Bool = true
    
    var timeElapsed: UInt32 = 0
    var secondTimer: NSTimer?
    
    
    //MARK: init
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    func initialize() {
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    
    //MARK: - Work with time
    func prepareRecordControls() {
        timeElapsed = 0
        updateTimeLabel(0)
    }
    
    func startCounter() {
        secondTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(secondElapsed), userInfo: nil, repeats: true)
    }
    
    func secondElapsed() {
        timeElapsed += 1
        updateTimeLabel(timeElapsed)
    }
    
    func updateTimeLabel(time:UInt32) {
        let seconds = time%60
        let minutes = (time%(60*60))/60
        let hours = time/(60*60)
        let timeStr = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        timeDelegate?.timeUpdate(timeStr)
    }
    
    func stopCounter() {
        secondTimer?.invalidate()
    }
}
