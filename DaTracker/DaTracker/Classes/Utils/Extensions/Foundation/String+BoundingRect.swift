//
// String+BoundingRect.swift
// DaTrackerFramework
//
// Created by Pavel Kuzmin on 21.11.2018.
// Copyright © 2018 Pavel Kuzmin. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit

extension String {
    public func boundingRect(with size: CGSize, options: NSStringDrawingOptions = [], attributes: [NSAttributedString.Key : Any]? = nil, context: NSStringDrawingContext? = nil) -> CGRect {
        return NSString(string: self).boundingRect(with: size, options: options, attributes: attributes, context: context)
    }
}
