//
// AVPlayerViewController.swift
// DaTracker
//
// Created by Pavel Kuzmin on 03.10.2018.
// Copyright © 2018 Gaika Group. All rights reserved.
//

import UIKit
import AVFoundation

class AVPlayerViewController: UIViewController {
    @IBOutlet private weak var playPauseButton: UIButton!
    @IBOutlet fileprivate weak var currentTimeLabel: UILabel!
    @IBOutlet private weak var finishTimeLabel: UILabel!
    @IBOutlet fileprivate weak var slider: UISlider!

    private let audioSession = AVAudioSession.sharedInstance()
    private var audioPlayer: AVAudioPlayer?

    var audioFilePath: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.makeAudioFile()

        self.slider.setThumbImage(UIImage.init(named: "SliderCircle"), for: .normal)
    }

    @IBAction func playButtonTapped() {
        if let audioPlayer = audioPlayer, audioPlayer.isPlaying {
            audioPlayer.pause()
        }
        else {
            audioPlayer?.play()
        }

        self.updatePlayButtonImage()
    }

    // MARK: - Private functions

    private func makeAudioFile() {
        if audioFilePath == nil {
            audioFilePath = Bundle.main.path(forResource: "sample", ofType: "mp3")
        }

        let urlAudioFile = URL.init(fileURLWithPath: audioFilePath!)
        do {
            try audioSession.setCategory(AVAudioSession.Category.playback, mode: AVFoundation.AVAudioSession.Mode.spokenAudio)
            try audioSession.setActive(true)

            audioPlayer = try AVAudioPlayer.init(contentsOf: urlAudioFile)
            audioPlayer!.volume = 0.5
            audioPlayer!.delegate = self
        } catch {
            let message = error.localizedDescription

            let alert = UIAlertController(title: "Warning", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

            self.show(alert, sender: nil)

            audioPlayer = nil
        }

        slider.minimumValue = 0.0;
        slider.maximumValue = audioPlayer != nil ? Float(audioPlayer!.duration) : 1.0

        currentTimeLabel.text = self.calculateCurrentDuration()
        self.updatePlayButtonImage()
    }

    private func updatePlayButtonImage() {
        var imageName = "PlayerPlayButton";
        if let audioPlayer = audioPlayer, audioPlayer.isPlaying {
            imageName = "PlayerPauseButton"
        }
        playPauseButton.setImage(UIImage.init(named: imageName), for: .normal)
    }
}

extension AVPlayerViewController: AVAudioPlayerDelegate {
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.slider.setValue(Float(player.currentTime), animated: true)
        self.currentTimeLabel.text = self.calculateCurrentDuration()
    }



    private func calculateCurrentDuration() -> String {
        guard let currentPlaybackTime = audioPlayer?.currentTime else {
            return "00:00"
        }

        let currentHours = Int(currentPlaybackTime / 3600)
        let currentMinutes = Int(currentPlaybackTime / 60)  - currentHours * 60
        let currentSeconds = Int(currentPlaybackTime) % 60

        let currentTimeString = currentHours > 0 ? String.init(format: "%i:%02d:%02d", currentHours, currentMinutes, currentSeconds) : String.init(format: "%02d:%02d", currentMinutes, currentSeconds)

        return currentTimeString
    }
}
