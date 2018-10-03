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

class TrackerViewController: UIViewController, AVAudioRecorderDelegate {

    @IBOutlet private weak var recordButton: UIButton!
    
    private let audioSession = AVAudioSession.sharedInstance()
    private var audioRecorder: AVAudioRecorder?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func startButtonTapped() {
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

            self.show(alert, sender: nil)
        }
        else {
            audioSession.requestRecordPermission { (granted) in
                if granted {
                    print("Microphone enable")
                    do {
                        try? self.audioSession.setCategory(AVAudioSession.Category.record, mode: AVFoundation.AVAudioSession.Mode.spokenAudio)
                        try? self.audioSession.setActive(true)
                        
                        self.audioSession.requestRecordPermission() { [unowned self] allowed in
                            DispatchQueue.main.async {
                                if allowed {
                                    self.startRecording()
                                } else {

                                    // failed to record!
                                }
                            }
                        }
                    }
                    catch {
                        let message = error.localizedDescription

                        let alert = UIAlertController(title: "Warning", message: message, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

                        self.show(alert, sender: nil)
                    }
                }
                else {
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
                    
                    self.show(alert, sender: nil)
                    
                    self.cancelRecording()
                }
            }
        }
    }
 
    // MARK: - private functions

    private func cancelRecording() {
        audioRecorder?.stop()
    }

    private func startRecording() {
        let recordURL =  FileManager.default.urls(for: .userDirectory, in: .userDomainMask).first!

        let audioFileURL = recordURL.appendingPathComponent("recording.m4a")

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: audioFileURL, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()

            recordButton.setTitle("COMPLETE APPOINTMENT", for: .normal)
            recordButton.setTitleColor(UIColor.init(red: 42.0, green: 80.0, blue: 108.0, alpha: 1.0), for: .normal)
            recordButton.setImage(UIImage.init(named: "btnSessionComplete"), for: .normal)


        } catch {
            finishRecording(success: false)
        }
    }

    func finishRecording(success: Bool) {
        audioRecorder?.stop()
        audioRecorder = nil

        if success {
            recordButton.setTitle("Tap to Re-record", for: .normal)
        } else {
            recordButton.setTitle("Tap to Record", for: .normal)
            // recording failed :(
        }
    }

    // MARK: - AVAudioRecorderDelegate

    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
}
