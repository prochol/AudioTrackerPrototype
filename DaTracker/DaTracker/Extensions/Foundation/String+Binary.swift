//
// String+Binary.swift
// DaTrackerFramework
//
// Created by Pavel Kuzmin on 21.11.2018.
// Copyright © 2018 Pavel Kuzmin. All rights reserved.
//

import Foundation

extension String {
    init<B: FixedWidthInteger>(fullBinary value: B) {
        self = value.words.reduce(into: "") {
            if value > 0 {
                $0.append(contentsOf: repeatElement("0", count: $1.leadingZeroBitCount - value.bitWidth))
                $0.append(String($1, radix: 2))
            }
            else {
                let str = String($1, radix: 2).suffix(value.bitWidth)
                $0.append(String(str))
            }
        }
    }
}
