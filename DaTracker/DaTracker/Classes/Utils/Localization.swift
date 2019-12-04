//
// Localization.swift
// Emergency plan
//
// Created by prochol on 2019-05-15.
// Copyright © 2019 Gaika Group. All rights reserved.
//

import Foundation

func LS(_ key: String, table: String? = nil) -> String {
    return NSLocalizedString(key, tableName: table, comment: "")
}
