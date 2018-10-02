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

class TrackerViewController: UIViewController {



    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func startButtonTapped() {
        let recordURL =  FileManager.default.urls(for: .userDirectory, in: .userDomainMask).first! as NSURL
        let recordPath = recordURL.path

        let audioSession = AVAudioSession.sharedInstance()

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

//        [self.voiceHUD startForFilePath:[NSString stringWithFormat:@"%@/tmp/tmp.%@", recordPath, AUDIO_FILE_TYPE]];
    }
    
}

