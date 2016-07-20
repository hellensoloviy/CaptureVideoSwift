//
//  NSURLExtension.swift
//  CameraCaptureVideo
//
//  Created by Hellen Soloviy on 7/20/16.
//  Copyright © 2016 Hellen Soloviy. All rights reserved.
//

import Foundation

extension NSURL {
    static func tempPathForFile(name: String) -> NSURL {
        let outputPath = NSTemporaryDirectory() + name
        if NSFileManager.defaultManager().fileExistsAtPath(outputPath) {
            do {
                try NSFileManager.defaultManager().removeItemAtPath(outputPath)
            }
            catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        return NSURL(fileURLWithPath: outputPath)
    }
}