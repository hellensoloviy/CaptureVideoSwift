//
//  ViewController.swift
//  CameraCaptureVideo
//
//  Created by Hellen Soloviy on 7/18/16.
//  Copyright © 2016 Hellen Soloviy. All rights reserved.
//

import UIKit
import AVFoundation

class CaptureViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, UINavigationBarDelegate, AVCaptureFileOutputRecordingDelegate {
    
    var isRecording = false
    var camera : Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCameraSession()
        setupNavBar()
        
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
        
        let statusBarView = UIView.init(frame: CGRectMake(0, 0, width, statusBarHeight))
        view.backgroundColor = UIColor.blackColor()
        self.view.addSubview(statusBarView)

    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
//        view.layer.addSublayer(previewLayer)
        view.addSubview(overlayView())
//        cameraSession.startRunning()
        addPlayStopButton()
        
    }
    
     //MARK: overlay
    func overlayView() -> UIView {
        let overlayView = UIView()
        overlayView.frame = UIScreen.mainScreen().bounds
        
        let halfWidth = overlayView.frame.size.width/4
        let width = overlayView.frame.size.width/2
        let height = overlayView.frame.size.height/3
        
        let pathRectFrame = CGRectMake(halfWidth, height+15, width, width)
        
        let blur = UIBlurEffect.init(style: .Dark)
        let visualEffectView = UIVisualEffectView.init(effect: blur)
        visualEffectView.frame = overlayView.frame
        
        overlayView.addSubview(visualEffectView)
        
        let shapeLayer = CAShapeLayer()
        let path1 = CGPathCreateMutable()
        CGPathAddRect(path1, nil, pathRectFrame)
        
        CGPathAddRect(path1, nil, overlayView.frame);
        shapeLayer.path = path1
        shapeLayer.fillRule = kCAFillRuleEvenOdd
        overlayView.layer.mask = shapeLayer

        let imageView = UIImageView.init(image: UIImage.init(named: "CaptureDevice"))
        imageView.contentMode = .ScaleAspectFit
        imageView.frame = overlayView.frame
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor.clearColor()
        overlayView.addSubview(imageView)
        
        return overlayView
    }
    
    var cameraSession: AVCaptureSession?

    var previewLayer: AVCaptureVideoPreviewLayer?
    
    @IBAction func cameraSourceChanged(sender: AnyObject) {
        camera = !camera
        self.setupCameraSession()
        self.addPlayStopButton()
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
            
            let dataOutput = AVCaptureVideoDataOutput()
            dataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(unsignedInt: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
            dataOutput.alwaysDiscardsLateVideoFrames = true
            
            cameraSession!.commitConfiguration()
            
            if (cameraSession!.canSetSessionPreset(AVCaptureSessionPresetHigh)) {
                cameraSession!.sessionPreset = AVCaptureSessionPresetHigh
            } else {
                cameraSession!.sessionPreset = AVCaptureSessionPresetMedium
            }
            
            cameraSession!.commitConfiguration()
            
            let queue = dispatch_queue_create("com.regionit.videoQueue", DISPATCH_QUEUE_SERIAL)
            dataOutput.setSampleBufferDelegate(self, queue: queue)
            
            let preview =  AVCaptureVideoPreviewLayer(session: self.cameraSession)
            preview.bounds = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
            preview.position = CGPoint(x: CGRectGetMidX(self.view.bounds), y: CGRectGetMidY(self.view.bounds))
            preview.videoGravity = AVLayerVideoGravityResize
            
            previewLayer = preview;
            
            view.layer.addSublayer(previewLayer!)
            view.addSubview(overlayView())
            cameraSession!.startRunning()
        }
            
        catch let error as NSError {
            NSLog("\(error), \(error.localizedDescription)")
        }
    }
    
    
    
     //MARK: Camera Delegate Methods
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        // Here you collect each frame and process it
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didDropSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        // Here you can count how many frames are dopped
    }
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAtURL fileURL: NSURL!, fromConnections connections: [AnyObject]!) {
        
    }

    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        
        if (error == nil) {
            print("Suscess")
            
            
            
        } else {
            print("Erorr!")
            
        }
    }

    
//    func saveToCameraRoll(URL: NSURL!) {
//        
//        NSLog("srcURL: %@", URL)
//        var library: ALAssetsLibrary = ALAssetsLibrary()
//        var videoWriteCompletionBlock: ALAssetsLibraryWriteVideoCompletionBlock = {(newURL: NSURL!, error: NSError!) in
//            if (error != nil) {
//                NSLog("Error writing image with metadata to Photo Library: %@", error)
//            }
//            else {
//                NSLog("Wrote image with metadata to Photo Library %@", newURL.absoluteString!)
//            }
//            
//        }
//        if library.videoAtPathIsCompatibleWithSavedPhotosAlbum(URL) {
//            library.writeVideoAtPathToSavedPhotosAlbum(URL, completionBlock: videoWriteCompletionBlock)
//        }
//    }


    //MARK: PLay/Stop button
    func addPlayStopButton() {
        
        let startButton = UIButton.init(type: .Custom)
        startButton.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width/3 , 30)
        startButton.setTitle("Go!", forState: .Normal)
        startButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        startButton.addTarget(self, action: #selector(changeRecordingState), forControlEvents: .TouchUpInside)
        
        let width = UIScreen.mainScreen().bounds.size.width
        let height = UIScreen.mainScreen().bounds.size.height
        
        startButton.center = CGPointMake(width/2,
                                         height/2 + width/2)
        
        view.addSubview(startButton)
    }
    
    func changeRecordingState(sender: UIButton) {
        
        if (isRecording == false) {
            print("Starting Recording")
            isRecording = true
            startRecording()
            
        } else {
            print("Stop Recording")
            isRecording = false
            stopRecording()
        }
    }

    
    var filePath : NSURL {
        
            let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
            let filePath = documentsURL.URLByAppendingPathComponent("temp")
            return filePath
        
    }
    
    var videoFileOutput = AVCaptureMovieFileOutput()
    
    func startRecording() {
        print("Start")

        let recordingDelegate:AVCaptureFileOutputRecordingDelegate? = self
        
        cameraSession!.addOutput(videoFileOutput)
        
        videoFileOutput.startRecordingToOutputFileURL(filePath, recordingDelegate: recordingDelegate)
    }
    
    func stopRecording() {
        print("Stop Recording")
        videoFileOutput.stopRecording()
        
    }

}

