//
// NibView.swift
// Emergency plan
//
// Created by Pavel Kuzmin on 2019-05-15.
// Copyright © 2019 Gaika Group. All rights reserved.
//

import UIKit.UIView

protocol INibView: class {
    static var nibName: String { get }
    static var nib: UINib { get }
}

extension INibView where Self: UIView {
    static var nibName: String {
        return String(describing: Self.self)
    }

    static var nib: UINib {
        return UINib.init(nibName: Self.nibName, bundle: Bundle.main)
    }
}

protocol IInstantiateNibView: INibView {
    static func instantiate() -> Self
}

extension IInstantiateNibView {
    static func instantiate() -> Self {
        guard let instantiateView = nib.instantiate(withOwner: self, options: nil).first as? Self else {
            fatalError("Could not load view from nib file.")
        }
        return instantiateView
    }
}
