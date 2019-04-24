//
//  TrackerViewController.swift
//  DaTracker
//
//  Created by Pavel Kuzmin on 02.10.2018.
//  Copyright © 2018 Gaika Group. All rights reserved.
//

import UIKit
import AudioToolbox
import AVFoundation

private let kHighSettings = [
    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
    AVEncoderBitRateKey: 320000,
    AVSampleRateKey: 44100,
    AVNumberOfChannelsKey: 2,
    AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
]

class TrackerViewController: UIViewController {

    @IBOutlet private weak var statusLabel: UILabel!
    
    @IBOutlet private weak var recordButton: UIButton!
    @IBOutlet private weak var playerContainerBottomConstraint: NSLayoutConstraint!

    private var playerViewController: AVPlayerViewController?

    private let audioSession = AVAudioSession.sharedInstance()
    private var audioRecorder: AVAudioRecorder?

    private var isRecording: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "DaTracker"

        playerContainerBottomConstraint.constant = 72
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        playerViewController = segue.destination as? AVPlayerViewController
    }

    // MARK: - Actions

    @IBAction func startExportTapped() {
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as URL
        
        let inputUrl = documentsUrl.appendingPathComponent("Savateev.mp4")
        
        self.resaveMedia(with: inputUrl)
    }
    
    
    @IBAction func startFingerprintsTapped() {
        self.startFingerprints()
    }
    
    
    @IBAction func startStopButtonTapped() {
        if !audioSession.isInputAvailable {
            let message = "Рарешите приложению доступн к для записи айдио.\nДля этого перейдите в настройки приложения."

            let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "Настройки", style: .default, handler: { (_) in
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }

                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)") // Prints true
                    })
                }
            }))

            self.present(alert, animated: true)
        } else {
            if isRecording {
                if audioRecorder == nil {
                    self.startRecording()
                } else {
                    finishRecording(success: true)
                }
            } else {
                audioSession.requestRecordPermission { (granted) in
                    if granted {
                        print("Microphone enable")
                        do {
                            try self.audioSession.setCategory(AVAudioSession.Category.playAndRecord, mode: AVFoundation.AVAudioSession.Mode.default)
                            try self.audioSession.setActive(true)

                            self.audioSession.requestRecordPermission() { [unowned self] allowed in
                                self.isRecording = true

                                DispatchQueue.main.async {
                                    if allowed {
                                        self.startRecording()
                                    } else {

                                        // failed to record!
                                    }
                                }
                            }
                        } catch {
                            let message = error.localizedDescription

                            let alert = UIAlertController(title: "Warning", message: message, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

                            self.present(alert, animated: true)
                        }
                    } else {
                        // Microphone disabled code

                        let message = "Isn't allowed to use the microphone on your device. If you'd like to record, open the system Setting, go to the Privacy section, select Microphone, and turn on the swich next to app."

                        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { (_) in
                            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                                return
                            }

                            if UIApplication.shared.canOpenURL(settingsUrl) {
                                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                                    print("Settings opened: \(success)") // Prints true
                                })
                            }
                        }))

                        self.present(alert, animated: true)

                        self.cancelRecording()
                    }
                }
            }
        }
    }

    // MARK: - private functions

    private func resaveMedia(with mediaURL: URL) {
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as URL
        let outputURL = documentsUrl.appendingPathComponent("output.mp4")
        
        if FileManager.default.fileExists(atPath: outputURL.path) {
            try? FileManager.default.removeItem(at: outputURL)
            print("Removing old output on URL: \(outputURL)")
        }
        
        let trim = (TimeInterval(5.0), TimeInterval(30.0))
        
        MediaRecorderController().saveMedia(of: mediaURL, to: outputURL, trim: trim) { status in
            if status == .completed {
                print("COMPLETED export media")
                
                DispatchQueue.main.async {
                    self.statusLabel.text = "COMPLETED export"
                }
            }
            else if status == .cancelled {
                print("CANCELED export media")
                DispatchQueue.main.async {
                    self.statusLabel.text = "CANCELED export"
                }
            }
            else if status == .failed {
                print("FAILED status export video for Track. See the error earlier.")
                DispatchQueue.main.async {
                    self.statusLabel.text = "FAILED export"
                }
            }
            else {//if status != .failed
                print("OTHER status export video for Track")
                DispatchQueue.main.async {
                    self.statusLabel.text = "OTHER status export"
                }
            }
        }
    }
    
    private func startFingerprints() {
        DispatchQueue.global(qos: .userInitiated).async {
            
            let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as URL
            
            var audioFileFingerprintString = String()
            var audioFileFingerprintInt = [Int]()
            
            //            if let audioFilePath = Bundle.main.path(forResource: "audio", ofType: "mp4") {
            //                if let audioFileURL = URL.init(string: audioFilePath) {
            let audioFileURL = documentsUrl.appendingPathComponent("video.mp4")
            if FileManager.default.fileExists(atPath: audioFileURL.path) {
                guard let (audioFingerprintString, durationAudio) = generateFingerprint(fromSongAtUrl: audioFileURL) else {
                    print("No fingerprint was generated")
                    return
                }
                
                audioFileFingerprintString = audioFingerprintString
                
                print("The audio duration is \(durationAudio)")
                print("The audio fingerprint is: \(audioFingerprintString)")
                print("The audio fingerprint long: \(audioFingerprintString.count)")
                
                let audioFingerprintScalars = audioFingerprintString.unicodeScalars
                
                for scalar in audioFingerprintScalars {
                    audioFileFingerprintInt.append(Int(scalar.value))
                }
                
                print("audio Fingerprint Int: \(audioFileFingerprintInt)")
                
            }
            //                }
            //            }
            
            var clipFingerprintString = String()
            var clipFingerprintInt = [Int]()
            
            //            if let audioClipPath = Bundle.main.path(forResource: "clip_2", ofType: "mp4") {
            //                if let audioClipURL = URL.init(string: audioClip2FilePath) {
            let audioClipURL = documentsUrl.appendingPathComponent("output2.mp4")
            if FileManager.default.fileExists(atPath: audioClipURL.path) {
                guard let (audioFingerprintString, durationAudio) = generateFingerprint(fromSongAtUrl: audioClipURL) else {
                    print("No fingerprint was generated")
                    return
                }
                
                clipFingerprintString = audioFingerprintString
                
                print("The audio clip_2 duration is \(durationAudio)")
                print("The audio clip_2 fingerprint is: \(audioFingerprintString)")
                print("The audio clip_2 fingerprint long: \(audioFingerprintString.count)")
                
                let audioFingerprintScalars = audioFingerprintString.unicodeScalars
                
                for scalar in audioFingerprintScalars {
                    clipFingerprintInt.append(Int(scalar.value))
                }
                
                print("audio clip_2 Fingerprint Int: \(clipFingerprintInt)")
            }
            //                }
            //            }
            
            var substring = ""
            var maxSubstringLocation: Range<String.Index>?
            var maxSubstring = ""
            
            for audioFingerprintStringChar in audioFileFingerprintString {
                substring = substring + String(audioFingerprintStringChar)
                
                if let range = clipFingerprintString.range(of: substring) {
                    if maxSubstring.count < substring.count {
                        maxSubstring = substring
                        maxSubstringLocation = range
                    }
                }
                else {
                    substring = ""
                }
            }
            
            print("maxSubstring: \(maxSubstring)")
            print("rangeMaxSubstring: \(maxSubstringLocation)")
            
            var differenceArrays = [Int: [Int]]()
            var index = 0
            while index < audioFileFingerprintInt.count {
                //                let clipFingerprintElem = clipFingerprintInt[index]
                
                var differenceArray = [Int]()
                
                var clipIndex = 0
                while clipIndex < clipFingerprintInt.count {
                    let clipFingerprintElem = clipFingerprintInt[clipIndex]
                    let audioFingerprintElem = index + clipIndex < audioFileFingerprintInt.count ? audioFileFingerprintInt[index + clipIndex] : 0
                    let differenceElem = audioFingerprintElem - clipFingerprintElem
                    differenceArray.append(differenceElem)
                    
                    clipIndex += 1
                }
                
                differenceArrays[index] = differenceArray
                index += 1
            }
            
            print("matrix difference count elements: \(differenceArrays.count)")
            
            do {
                let differenceUrl = documentsUrl.appendingPathComponent("differenceArrays", isDirectory: false)
                
                var string = String()
                for indexDifferenceArray in 0..<differenceArrays.count {
                    if let differenceArray = differenceArrays[indexDifferenceArray] {
                        var differenceArrayString = "["
                        for indexDifference in 0..<differenceArray.count {
                            let differenceElem = differenceArray[indexDifference]
                            
                            differenceArrayString = differenceArrayString + String(differenceElem) + ", "
                        }
                        differenceArrayString = differenceArrayString + "]"
                        
                        string = string + differenceArrayString + "\n"
                    }
                    
                    if indexDifferenceArray.isMultiple(of: 50) {
                        print("create string for differenceArray with index: \(indexDifferenceArray)")
                    }
                }
                
                try string.write(to: differenceUrl, atomically: true, encoding: String.Encoding.utf8)
                
                print("differenceArrays saved in \(differenceUrl.absoluteString)")
                
                DispatchQueue.main.async {
                    self.statusLabel.text = "Fingerprints status complete"
                }
            }
            catch {
                print(error.localizedDescription)
            }
        }
    }
    
    
    private func removeOldAudioFile() {
        playerViewController?.audioFilePath = nil//For unblocking file
        playerViewController?.makeAudioFile()

        let recordURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        let audioFileURL = recordURL.appendingPathComponent("recording.mp4")

        try? FileManager.default.removeItem(at: audioFileURL)
    }

    private func cancelRecording() {
        audioRecorder?.stop()
    }

    private func startRecording() {
        self.removeOldAudioFile()

        let recordURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        let audioFileURL = recordURL.appendingPathComponent("recording.mp4")

        let settings = kHighSettings

        do {
            audioRecorder = try AVAudioRecorder(url: audioFileURL, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()

            recordButton.setTitle("COMPLETE APPOINTMENT", for: .normal)
            recordButton.setTitleColor(UIColor.init(red: 42.0, green: 80.0, blue: 108.0, alpha: 1.0), for: .normal)
            recordButton.setImage(UIImage.init(named: "CompleteAll"), for: .normal)
        } catch {
            finishRecording(success: false)
        }
    }

    private func finishRecording(success: Bool) {
        audioRecorder?.stop()
        audioRecorder = nil

        if success {
            recordButton.setTitle("RESTART APPOINTMENT", for: .normal)
            recordButton.setImage(UIImage.init(named: "PlayButton"), for: .normal)

            playerContainerBottomConstraint.constant = 72
        } else {
            recordButton.setTitle("START APPOINTMENT", for: .normal)
            recordButton.setImage(UIImage.init(named: "PlayButton"), for: .normal)

            playerContainerBottomConstraint.constant = 0
            // recording failed :(
        }
    }
}

extension TrackerViewController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            let recordURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

            let audioFileURL = recordURL.appendingPathComponent("recording.mp4")

            playerViewController?.audioFilePath = audioFileURL.path
            playerViewController?.makeAudioFile()
        }
        else {
            finishRecording(success: false)
        }
    }
}
