//
// MediaRecorderController.swift
// DaTracker
//
// Created by Pavel Kuzmin on 12.11.2018.
// Copyright © 2018 Gaika Group. All rights reserved.
//

import Foundation
import AudioToolbox
import AVFoundation

/**
* Base Controller for recording in file (no UI)
*/
public class MediaRecorderController: NSObject {
    public var isFinished: Bool = false

    /// URL with the raw result of the appointment recording
    /// `nil` if the record is missing or not finished
    public internal(set) var outputURL: URL?

    public override init() {}

    // MARK: Recording

    /// Saving media file.
    ///
    /// - parameter of: - the input URL of the recording folder to which the tracking refers
    /// - parameter to: - the output URL of the recording folder to which the tracking refers
    /// - parameter trim:  - the target record length, if the `nil` record remains complete
    /// - parameter completionHandler:  - Callback with result operation
    public func saveMedia(of inputURL: URL, to outputURL: URL, trim: (TimeInterval, TimeInterval)? = nil, completionHandler handler: @escaping (AVAssetExportSession.Status) -> Void) {
        let inputAsset = AVAsset.init(url: inputURL)

        var exportSession = AVAssetExportSession.init(asset: inputAsset, presetName: AVAssetExportPresetPassthrough)
        if inputURL.lastPathComponent.hasSuffix("mp3") {
            if let exportSessionMP3 = AVAssetExportSession.init(asset: inputAsset, presetName: AVAssetExportPresetHighestQuality) {
                exportSession = exportSessionMP3
            }
        }
        exportSession?.outputFileType = .mp4
        exportSession?.outputURL = outputURL

        if let trim = trim {
            exportSession?.timeRange = CMTimeRange(by: trim)
        }

        exportSession?.exportAsynchronously {
            if let status = exportSession?.status {
                if status == .failed {
                    print("FAILED export media with error: \(String(describing: exportSession?.error?.localizedDescription))")
                }

                handler(status)
            }
            else {
                handler(.unknown)
            }
        }
    }

    // MARK: - Private functions

    private func CMTimeRange(by trim: (TimeInterval, TimeInterval)) -> CMTimeRange {
        let startTime = CMTime.init(value: CMTimeValue.init(trim.0 * 600), timescale: 600)
        let stopTime = CMTime.init(value: CMTimeValue.init((trim.0 + trim.1) * 600), timescale: 600)

        return CMTimeRangeFromTimeToTime(start: startTime, end: stopTime)
    }
}
