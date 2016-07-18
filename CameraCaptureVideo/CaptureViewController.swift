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
        
       
//        let statusBarView = UIView.init(frame: CGRectMake(0, 0, width, statusBarHeigth))
//        view.backgroundColor = UIColor.blackColor()
//        self.view.addSubview(statusBarView)

    }
    
    
    func overlayView() -> UIView {
        let overlayView = UIView()
        overlayView.frame = UIScreen.mainScreen().bounds
        
//        var imageLayer = CALayer.i
        
        let halfWidth = overlayView.frame.size.width/4
        let width = overlayView.frame.size.width/2
        let height = overlayView.frame.size.height/3
        
        let pathRectFrame = CGRectMake(halfWidth, height+15, width, width)
//        
//        let path = UIBezierPath.init(roundedRect: overlayView.frame, cornerRadius: 0)
//        let rectPath = UIBezierPath.init(roundedRect: pathRectFrame, cornerRadius: 8)
        
        let blur = UIBlurEffect.init(style: .Dark)
        let visualEffectView = UIVisualEffectView.init(effect: blur)
        visualEffectView.frame = overlayView.frame
        
        overlayView.addSubview(visualEffectView)

        
        
//        path.appendPath(rectPath)
//        path.usesEvenOddFillRule = true
     
//        let shapeLayer = CAShapeLayer()
//        shapeLayer.path = path.CGPath
//        shapeLayer.fillRule = kCAFillRuleEvenOdd
//        shapeLayer.fillColor = UIColor.whiteColor().CGColor
//        shapeLayer.opacity = 0.5
//
//        CGRect imageViewFrame = imageView.bounds;
//        CGRect circleFrame = CGRectMake(point.x-radius/2,point.y-radius/2,radius,radius);

//
        
//        visualEffectView.layer.addSublayer(shapeLayer)
        
        let imageView = UIImageView.init(image: UIImage.init(named: "CaptureDevice"))
        imageView.contentMode = .ScaleAspectFit
        imageView.frame = overlayView.frame
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor.clearColor()
        overlayView.addSubview(imageView)
        
        let shapeLayer = CAShapeLayer()
        let path1 = CGPathCreateMutable()
        CGPathAddEllipseInRect(path1, nil, pathRectFrame)
        
        CGPathAddRect(path1, nil, overlayView.frame);
        shapeLayer.path = path1
        shapeLayer.fillRule = kCAFillRuleEvenOdd
        overlayView.layer.mask = shapeLayer
        
        return overlayView
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    var cameraSession: AVCaptureSession?

    var previewLayer: AVCaptureVideoPreviewLayer?
    
    @IBAction func cameraSourceChanged(sender: AnyObject) {
        camera = !camera
        self.setupCameraSession()
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
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        // Here you collect each frame and process it
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didDropSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        // Here you can count how many frames are dopped
    }
    
}

