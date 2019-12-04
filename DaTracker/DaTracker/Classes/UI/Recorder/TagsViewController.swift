//
// TagsViewController.swift
// DaTracker
//
// Created by Pavel Kuzmin on 26.10.2018.
// Copyright © 2018 Gaika Group. All rights reserved.
//

import UIKit

class TagsViewController: UIViewController {
    @IBOutlet private weak var tagsTextField: UITextField!

    @IBOutlet private weak var addedButton: UIButton!

    @IBOutlet private weak var tagsScrollView: UIScrollView!
    @IBOutlet private weak var tagsPlaceholder: UIView!
    @IBOutlet private weak var tagsPlaceholderWidthConstraint: NSLayoutConstraint!

    var tags: [String] = [String]()

    var addedTags: (([String]) -> Void)?
    var removedTag: ((String) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.updateTagsPlaceHolder()
    }

    // MARK: - Actions

    @IBAction func addedButtonTapped() {
        self.view.endEditing(true)

        self.addedTags?(self.tags)

        self.tagsTextField.text = ""

        self.updateTagsPlaceHolder()
    }

    // MARK: - Private functions

    private func updateTagsPlaceHolder() {
        self.tagsPlaceholder.removeAllSubviews()
        self.tagsScrollView.contentOffset = CGPoint.init(x: 0, y: 0)

        self.tagsPlaceholder.frame = self.tagsScrollView.bounds
        self.tagsPlaceholder.backgroundColor = UIColor.clear
        self.createViewTags(for: self.tags)
        self.tagsPlaceholder.setNeedsLayout()

        self.tagsScrollView.contentSize = self.tagsPlaceholder.frame.size
        self.tagsScrollView.setNeedsLayout()
    }

    private func createViewTags(`for` stringTags: [String]) {
        var lastTagView: TagView?
        var placeholderWidth: CGFloat = 8//padding

        for tagString in stringTags {
            placeholderWidth += TagView.width(for: tagString) + 8//padding

            let tagView = TagView.instantiate(tagString)
            tagView.translatesAutoresizingMaskIntoConstraints = false
            self.tagsPlaceholder.addSubview(tagView)
            self.tagsPlaceholderWidthConstraint.constant = placeholderWidth

            NSLayoutConstraint(item: tagView, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.tagsPlaceholder, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 8).isActive = true
            NSLayoutConstraint(item: tagView, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.tagsPlaceholder, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: -8).isActive = true
            if let lastTagView = lastTagView {
                NSLayoutConstraint(item: tagView, attribute: NSLayoutConstraint.Attribute.left, relatedBy: NSLayoutConstraint.Relation.equal, toItem: lastTagView, attribute: NSLayoutConstraint.Attribute.right, multiplier: 1, constant:8).isActive = true
            }
            else {
                NSLayoutConstraint(item: tagView, attribute: NSLayoutConstraint.Attribute.left, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.tagsPlaceholder, attribute: NSLayoutConstraint.Attribute.left, multiplier: 1, constant: 8).isActive = true
            }
            if let lastStringTag = stringTags.last, tagString == lastStringTag {
                NSLayoutConstraint(item: tagView, attribute: NSLayoutConstraint.Attribute.right, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.tagsPlaceholder, attribute: NSLayoutConstraint.Attribute.right, multiplier: 1, constant: -8).isActive = true
            }

            lastTagView = tagView

            tagView.onRemovedAction = { [weak self] tagString in
                self?.onRemoved(tag: tagString)
            }
        }

        self.tagsPlaceholderWidthConstraint.constant = placeholderWidth
    }

    private func onRemoved(tag: String) {
        self.tags.removeAll { $0 == tag }
        self.removedTag?(tag)
        self.updateTagsPlaceHolder()
    }
}

extension TagsViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        let text = textField.text ?? ""
        let newAddTags = text.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }

        var newTags = self.tags
        for tag in newAddTags {
            if !newTags.contains(tag) {
                newTags.append(tag)
            }
        }

        self.tags = newTags
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.endEditing(true)
    }
}
