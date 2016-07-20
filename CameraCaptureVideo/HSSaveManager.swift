//
//  HSSaveManager.swift
//  CameraCaptureVideo
//
//  Created by Hellen Soloviy on 7/20/16.
//  Copyright © 2016 Hellen Soloviy. All rights reserved.
//

import Foundation
import AssetsLibrary

protocol HSSaveButtonStateDelegate {
    func changeButtonState()
}

class HSSaveManager {
    
    static var stateDelegate: HSSaveButtonStateDelegate?
    
    static func saveToCameraRoll(URL: NSURL!) {
        
        NSLog("srcURL: %@", URL)
        
        let library: ALAssetsLibrary = ALAssetsLibrary()
        let videoWriteCompletionBlock: ALAssetsLibraryWriteVideoCompletionBlock = {(newURL: NSURL!, error: NSError!) in
            if (error != nil) {
                NSLog("Error writing image with metadata to Photo Library: %@", error)
            }
            else {
                NSLog("Wrote image with metadata to Photo Library %@", newURL.absoluteString)
                    HSSaveManager.stateDelegate?.changeButtonState()
            }
        }
        if library.videoAtPathIsCompatibleWithSavedPhotosAlbum(URL) {
            library.writeVideoAtPathToSavedPhotosAlbum(URL, completionBlock: videoWriteCompletionBlock)
        }
    }

    
}
