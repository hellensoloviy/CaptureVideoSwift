//
//  HSOverlayPreview.swift
//  CameraCaptureVideo
//
//  Created by Hellen Soloviy on 7/20/16.
//  Copyright © 2016 Hellen Soloviy. All rights reserved.
//

import UIKit

class HSOverlayPreview: UIView {
    
    static func overlayView() -> UIView {
        let overlayView = UIView()
        
        overlayView.frame = UIScreen.mainScreen().bounds
        
        let containerView = UIView.init(frame: overlayView.bounds)
        
        let halfWidth = overlayView.frame.size.width/4
        let width = overlayView.frame.size.width/2
        let height = overlayView.frame.size.height/3
        
        let pathRectFrame = CGRectMake(halfWidth, height+15, width, width)
        
        let blur = UIBlurEffect.init(style: .Dark)
        let visualEffectView = UIVisualEffectView.init(effect: blur)
        visualEffectView.frame = overlayView.frame
        
        containerView.addSubview(visualEffectView)
        
        let shapeLayer = CAShapeLayer()
        let path1 = CGPathCreateMutable()
        CGPathAddRect(path1, nil, pathRectFrame)
        CGPathAddRect(path1, nil, overlayView.frame);
        shapeLayer.path = path1
        shapeLayer.fillRule = kCAFillRuleEvenOdd
        containerView.layer.mask = shapeLayer
        
        let imageView = UIImageView.init(image: UIImage.init(named: "CaptureDevice"))
        imageView.contentMode = .ScaleAspectFit
        imageView.frame = overlayView.frame
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor.clearColor()
        
        
        overlayView.addSubview(containerView)
        overlayView.addSubview(imageView)
        
        return overlayView
    }
}
