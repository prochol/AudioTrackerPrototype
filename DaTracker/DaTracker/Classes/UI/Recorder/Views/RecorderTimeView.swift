//
// RecorderTimeView.swift
// DaTrackerFramework
//
// Created by Pavel Kuzmin on 2019-07-18.
// Copyright © 2019 Pavel Kuzmin. All rights reserved.
//

import UIKit.UIView

class RecorderTimeView: UIView, IInstantiateNibView {
    private let kFontTag = UIFont.init(name: "Archivo-Medium", size: 11.0) ?? UIFont.systemFont(ofSize: 11.0)

    @IBOutlet private weak var timeLabel: UILabel!

    var timeInterval: TimeInterval = TimeInterval(0) {
        didSet {
            self.setTimeInterval(timeInterval)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.layer.cornerRadius = self.frame.size.height / 2 - 1

        self.timeLabel.text = self.text(byTimeInterval: self.timeInterval)
    }

    // MARK: - Private functions

    private func setTimeInterval(_ timeInterval: TimeInterval) {
        self.timeLabel?.text = self.text(byTimeInterval:timeInterval)
    }

    private func text(byTimeInterval timeInterval: TimeInterval) -> String  {
        let currentHours = timeInterval.isFinite ? Int(timeInterval / 3600) : 0
        let currentMinutes = timeInterval.isFinite ? Int(timeInterval / 60) - currentHours * 60 : 0
        let currentSeconds = timeInterval.isFinite ? Int(timeInterval) % 60 : 0

        let text = currentHours > 0 ?
                String.init(format: "%i:%02d:%02d", currentHours, currentMinutes, currentSeconds) :
                String.init(format: "%02d:%02d", currentMinutes, currentSeconds)

        return text
    }

    // MARK: - Class functions

    class func instantiate(_ timeInterval: TimeInterval) -> Self {
        let view = self.instantiate()
        view.timeInterval = timeInterval
        return view
    }
}
