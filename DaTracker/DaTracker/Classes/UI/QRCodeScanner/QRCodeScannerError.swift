//
// QRCodeScannerError.swift
// Emergency plan
//
// Created by prochol on 2019-05-16.
// Copyright © 2019 Gaika Group. All rights reserved.
//

import Foundation

enum QRCodeScannerError: Error {
    case noCameraPermission
}

extension QRCodeScannerError: CustomNSError {
    var errorCode: Int {
        switch self {
        case .noCameraPermission:
            return 403
        }
    }

    var errorUserInfo: [String : Any] {
        switch self {
        case .noCameraPermission:
            return [NSLocalizedDescriptionKey: self.errorDescription!]
        }
    }
}

extension QRCodeScannerError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .noCameraPermission:
            return self.failureReason! + ". " + self.recoverySuggestion!
        }
    }

    var failureReason: String? {
        switch self {
        case .noCameraPermission:
            return LS("qr.scanner.error.camera.permission.Reason")
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .noCameraPermission:
            return LS("qr.scanner.error.camera.permission.Suggestion")
        }
    }
}