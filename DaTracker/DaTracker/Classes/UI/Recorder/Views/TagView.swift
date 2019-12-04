//
// TagView.swift
// DaTracker
//
// Created by Pavel Kuzmin on 26.10.2018.
// Copyright © 2018 Gaika Group. All rights reserved.
//

import UIKit.UIView

private let kMinWidth: CGFloat = 32.0

class TagView: UIView, IInstantiateNibView {
    @IBOutlet weak private var tagStringLabel: UILabel!

    var tagString: String = "" {
        didSet {
            self.tagStringLabel.text = tagString
        }
    }

    var onRemovedAction: ((String) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        let boundsSelf = self.bounds;
        self.layer.cornerRadius = boundsSelf.height / 2 + 1
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.groupTableViewBackground.cgColor
    }

    // MARK: - Actions

    @IBAction fileprivate func removeButtonTapped() {
        self.onRemovedAction?(tagString)
    }

    // MARK: - Class functions

    class func instantiate(_ tagString: String) -> Self {
        let view = self.instantiate()
        view.tagString = tagString
        return view
    }

    class func width(for tag: String) -> CGFloat {
        guard tag.count > 0 else {
            return kMinWidth
        }

        let maxSizeName = CGSize(width: CGFloat(Float.greatestFiniteMagnitude), height: kMinWidth)//kMinWidth equal height view
        let font = UIFont.systemFont(ofSize: 12)
        let fontAttributes = [NSAttributedString.Key.font: font]
        let tagStringWidth = tag.boundingRect(with: maxSizeName, options: .usesLineFragmentOrigin, attributes: fontAttributes).size.width

        let width = tagStringWidth + 16 + 4 + 15 + 8

        return width > kMinWidth ? width + 1 : kMinWidth
    }
}
