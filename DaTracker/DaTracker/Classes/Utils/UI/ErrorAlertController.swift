//
// ErrorAlertController.swift
// Emergency plan
//
// Created by prochol on 2019-05-15.
// Copyright © 2019 Gaika Group. All rights reserved.
//

import UIKit

protocol IShowAlertViewController: class {
    func showAlert(withTitle title: String?, andMessage message: String?)
}

protocol IShowErrorViewController: IShowAlertViewController {
    func show(error: Error, handler: (() -> Void)?)
}

extension IShowAlertViewController where Self: UIViewController {
    func showAlert(withTitle title: String?, andMessage message: String?) {
        let alert = self.regularAlert(withTitle: title, andMessage: message, andCancelActionTitle: LS("general.button.cancel"))
        self.present(alert, animated: true, completion: nil)
    }

    private func regularAlert(withTitle title: String?,
                              andMessage message: String?,
                              andCancelActionTitle actionTitle: String = LS("general.button.cancel")) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: actionTitle, style: .cancel, handler: nil)
        alert.addAction(cancelAction)

        return alert
    }
}

extension IShowErrorViewController where Self: UIViewController {
    func show(error: Error, handler: (() -> Void)? = nil) {
        let alert = self.regularAlert(withTitle: LS("general.alert.title.error"),
                andMessage: error.localizedDescription,
                andCancelActionTitle: LS("general.button.ok"),
                handler: handler)
        self.present(alert, animated: true, completion: nil)
    }

    private func regularAlert(withTitle title: String?,
                              andMessage message: String?,
                              andCancelActionTitle actionTitle: String = LS("general.button.cancel"),
                              handler: (() -> Void)? = nil) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: actionTitle, style: .cancel) { action in
            handler?()
        }
        alert.addAction(cancelAction)

        return alert
    }
}
