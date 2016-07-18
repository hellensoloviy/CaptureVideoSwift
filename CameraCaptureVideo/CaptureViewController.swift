//
//  ViewController.swift
//  CameraCaptureVideo
//
//  Created by Hellen Soloviy on 7/18/16.
//  Copyright © 2016 Hellen Soloviy. All rights reserved.
//

import UIKit

import AVFoundation

class CaptureViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, UINavigationBarDelegate {
    
    var isRecording = false
    
//    @IBAction func switchCameraButtonAction(sender: UIButton) {
//    
//    if(session)
//    {
//    [session beginConfiguration];
//    
//    AVCaptureInput *currentCameraInput = [session.inputs objectAtIndex:0];
//    
//    [session removeInput:currentCameraInput];
//
//    AVCaptureDevice *newCamera = nil;
//    
//    if(((AVCaptureDeviceInput*)currentCameraInput).device.position == AVCaptureDevicePositionBack)
//    {
//    newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
//    }
//    else
//    {
//    newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
//    }
//    
//    NSError *err = nil;
//    
//    AVCaptureDeviceInput *newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:newCamera error:&err];
//    
//    if(!newVideoInput || err)
//    {
//    NSLog(@"Error creating capture device input: %@", err.localizedDescription);
//    }
//    else
//    {
//    [session addInput:newVideoInput];
//    }
//    
//    [session commitConfiguration];
//    }
//
//    }
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
            
            //ur code
            
        } else {
            print("Stop Recording")
            isRecording = false
            
            //ur stop code
        }
    }


}

