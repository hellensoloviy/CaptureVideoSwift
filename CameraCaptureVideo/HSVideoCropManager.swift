//
//  HSVideoCropManager.swift
//  CameraCaptureVideo
//
//  Created by Hellen Soloviy on 7/20/16.
//  Copyright © 2016 Hellen Soloviy. All rights reserved.
//

import AVFoundation

class HSVideoCropManager {
    
    static func cropVideoToSquareCentered(path: NSURL, completion: (newPath: NSURL) -> ()) {
        let asset = AVAsset(URL: path)
        guard let track = asset.tracksWithMediaType(AVMediaTypeVideo).first else {
            //TODO throw error
            return
        }
        
        let composition = AVMutableVideoComposition()
        let frameDuration = track.minFrameDuration
        composition.frameDuration = frameDuration
        let trackSize = track.naturalSize
        composition.renderSize = CGSizeMake(trackSize.width, trackSize.width)
        
        let compositionInstruction = AVMutableVideoCompositionInstruction()
        let timeRange = track.timeRange
        compositionInstruction.timeRange = timeRange
        
        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
        let transform = CGAffineTransformMakeTranslation(0, -(trackSize.height-trackSize.width)/2)
        layerInstruction.setTransform(transform, atTime: kCMTimeZero)
        
        compositionInstruction.layerInstructions = [layerInstruction]
        composition.instructions = [compositionInstruction]
        
        let tempPath = NSURL.tempPathForFile("temp_cropped.m4v")
        guard let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else {
            //TODO throw error
            return
        }
        exporter.videoComposition = composition
        exporter.outputURL = tempPath
        exporter.outputFileType = AVFileTypeMPEG4
        exporter.exportAsynchronouslyWithCompletionHandler { () -> Void in
            completion(newPath: path)
            
            print("url for cropped: - \(tempPath))")
            
            
        }
    }
}