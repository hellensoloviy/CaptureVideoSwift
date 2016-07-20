//
//  ViewController.swift
//  CameraCaptureVideo
//
//  Created by Hellen Soloviy on 7/18/16.
//  Copyright © 2016 Hellen Soloviy. All rights reserved.
//

import UIKit
import AVFoundation
import AssetsLibrary

class CaptureViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, UINavigationBarDelegate {
    
    //MARK: Vars
    var camera : Bool = true
    var cameraSession: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var recordControl: HSRecordingManager = HSRecordingManager()
    var startButton = UIButton.init(type: .Custom)
    let dataOutput = AVCaptureVideoDataOutput()
    var videoFileOutput = AVCaptureMovieFileOutput()
    var saveManager: HSSaveManager?
    
    //MARK: Outlets
    @IBOutlet weak var switchCameraButton: UIBarButtonItem!
    
    //MARK: - Button's actions
    @IBAction func cameraSourceChanged(sender: AnyObject) {
        camera = !camera
        reloadSession()
    }
    
    @IBAction func popToController(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    //MARK: - View load methods
    override func viewDidLoad() {
        super.viewDidLoad()
        recordControl.timeDelegate = self
        HSSaveManager.stateDelegate = self
        setupCameraSession()
        setupNavBar()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        view.addSubview(HSOverlayPreview.overlayView())
        addPlayStopButton()
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: true)
        
    }
    
    func setupNavBar() {
        
        let width = UIScreen.mainScreen().bounds.size.width
        let statusBarHeight : CGFloat = 20
        
        let barRect = CGRectMake(0, statusBarHeight, width, 64)
        UIGraphicsBeginImageContext(barRect.size)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.navigationController!.navigationBar.setBackgroundImage(image, forBarMetrics: UIBarMetrics.Default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
        self.navigationController!.navigationBar.translucent = true
        self.navigationController!.view.backgroundColor = UIColor.clearColor()

        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)

    }
    
    func setupCameraSession() {
        var captureDevice:AVCaptureDevice! = nil
        
        cameraSession?.stopRunning()
        cameraSession = AVCaptureSession()
        cameraSession!.sessionPreset = AVCaptureSessionPresetLow
        
        do {
            if (camera == false) {
                let videoDevices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
                
                for device in videoDevices{
                    let device = device as! AVCaptureDevice
                    if device.position == AVCaptureDevicePosition.Front {
                        captureDevice = device
                        break
                    }
                }
            } else {
                captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
            }
            
            cameraSession!.beginConfiguration()
            
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            if (cameraSession!.canAddInput(input) == true) {
                cameraSession!.addInput(input)
            }
            
            
            dataOutput.videoSettings =
                [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(unsignedInt: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
            
            dataOutput.alwaysDiscardsLateVideoFrames = true
            
            cameraSession!.commitConfiguration()
            
            if (cameraSession!.canSetSessionPreset(AVCaptureSessionPresetHigh)) {
                cameraSession!.sessionPreset = AVCaptureSessionPresetHigh
            } else {
                cameraSession!.sessionPreset = AVCaptureSessionPresetMedium
            }
            
            let queue = dispatch_queue_create("com.regionit.videoQueue", DISPATCH_QUEUE_SERIAL)
            dataOutput.setSampleBufferDelegate(self, queue: queue)
            
            cameraSession!.commitConfiguration()
            
            
            let preview =  AVCaptureVideoPreviewLayer(session: self.cameraSession)
            preview.bounds = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
            preview.position = CGPoint(x: CGRectGetMidX(self.view.bounds), y: CGRectGetMidY(self.view.bounds))
            preview.videoGravity = AVLayerVideoGravityResize
            
            previewLayer = preview;
            
            view.layer.addSublayer(previewLayer!)
            view.addSubview(HSOverlayPreview.overlayView())
            cameraSession!.startRunning()
        }
            
        catch let error as NSError {
            NSLog("\(error), \(error.localizedDescription)")
        }
    }
    
    func reloadSession() {
        self.setupCameraSession()
        self.addPlayStopButton()
    }
    


    
    
    //MARK: PLay/Stop button
    func addPlayStopButton() {
        
        startButton.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width/3 , 30)
        
        if (recordControl.isSaving == true) {
            startButton.setTitle("Saving..", forState: .Normal)
        } else {
            startButton.setTitle("Go!", forState: .Normal)
        }
        
        startButton.setTitleColor(UIColor.greenColor(), forState: .Normal)
        startButton.addTarget(self, action: #selector(changeRecordingState), forControlEvents: .TouchUpInside)
        
        let width = UIScreen.mainScreen().bounds.size.width
        let height = UIScreen.mainScreen().bounds.size.height
        
        startButton.center = CGPointMake(width/2,
                                         height/2 + width/2)
        
        view.addSubview(startButton)
    }
    
    func changeRecordingState(sender: UIButton) {
        
        if (recordControl.isRecording == false) {
            
            if (recordControl.isSaving == true) { return }
                
            print("Starting Recording")
            recordControl.isRecording = true
            
            startButton.setTitle("Recording..", forState: .Normal) // time
            startButton.addTarget(self, action: #selector(changeRecordingState), forControlEvents: .TouchUpInside)
            
            startRecording()
            
            
        } else {
            
            print("Stop Recording")
            recordControl.isRecording = false
            stopRecording()

            if (recordControl.isSaving == false) {
                print("Start Saving --")
                recordControl.isSaving = true
                startButton.setTitle("Saving...", forState: .Normal) // time
                return;
            
            }

            startButton.setTitle("Go!", forState: .Normal) // time
            startButton.setTitleColor(UIColor.greenColor(), forState: .Normal)
            startButton.addTarget(self, action: #selector(changeRecordingState), forControlEvents: .TouchUpInside)
        }
    }
    
    
    
    //MARK: Recording
    func startRecording() {
        print("Start Recording")
        let recordingDelegate:AVCaptureFileOutputRecordingDelegate? = self
        videoFileOutput = AVCaptureMovieFileOutput()
        cameraSession!.addOutput(videoFileOutput)
        recordControl.startCounter()
        switchCameraButton.enabled = false
        
        let outputUrl = NSURL(fileURLWithPath: NSTemporaryDirectory() + "temp.m4v")
        videoFileOutput.startRecordingToOutputFileURL(outputUrl, recordingDelegate: recordingDelegate)
        
    }
    
    
    func stopRecording() {
        print("Stop Recording")
        videoFileOutput.stopRecording()
        recordControl.stopCounter();
        reloadSession()
        switchCameraButton.enabled = true

    }

    

}

extension CaptureViewController: AVCaptureFileOutputRecordingDelegate {
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAtURL fileURL: NSURL!, fromConnections connections: [AnyObject]!) {
        
    }
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        
        if (error == nil) {
            print("Suscess")
            HSVideoCropManager.cropVideoToSquareCentered(outputFileURL, completion: { (newPath) in
                HSSaveManager.saveToCameraRoll(newPath)
            })
            
        } else {
            print("Erorr!")
        }
    }
    
}

extension CaptureViewController: HSTimeCounterDelegate {
    
     func timeUpdate(time: String) {
        startButton.setTitle(time, forState: .Normal)
    }
    
}

extension CaptureViewController: HSSaveButtonStateDelegate {
    
    func changeButtonState() {
        if (recordControl.isSaving == true) {
            print("Stop Saving --")
            recordControl.isSaving = false
            
            dispatch_async(dispatch_get_main_queue(), {
                self.startButton.setTitle("Go!", forState: .Normal)
                
            })
        }
    }
    
}

