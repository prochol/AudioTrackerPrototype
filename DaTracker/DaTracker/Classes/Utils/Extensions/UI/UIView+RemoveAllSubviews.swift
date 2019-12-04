//
// UIView+RemoveAllSubviews.swift
// DaTracker
//
// Created by Pavel Kuzmin on 26.10.2018.
// Copyright © 2018 Gaika Group. All rights reserved.
//

import UIKit.UIView

extension UIView {
    func removeAllSubviews() {
        for subview in self.subviews {
            subview.removeAllSubviews()
            subview.removeFromSuperview()
        }
    }
}
