//
// QRCodeScannerViewController.swift
// Emergency plan
//
// Created by Pavel Kuzmin on 2019-05-16.
// Copyright © 2019 Gaika Group. All rights reserved.
//

import UIKit
import AVFoundation

class QRCodeScannerViewController: UIViewController, IShowErrorViewController {
    @IBOutlet private weak var qrCodePlaceholder: UIView!
    @IBOutlet private weak var qrCodeHolePlaceholder: UIView!

    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!

    public var onFoundString: ((String) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
            self.setupCaptureSession()
        }
        else {
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    print("There are all necessary permissions for video")
                    DispatchQueue.main.async {
                        self?.setupCaptureSession()

                        self?.captureSession.startRunning()
                    }
                }
                else {
                    DispatchQueue.main.async {
                        self?.showAlertInputNotAvailable()
                    }
                }
            }
        }

        #if targetEnvironment(simulator)

        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(self.handle(_:)))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        self.qrCodePlaceholder.addGestureRecognizer(tapGesture)

        #endif
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        DispatchQueue.global(qos: .userInitiated).async { //[weak self] in
            if self.captureSession?.isRunning == false {
                self.captureSession.startRunning()
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        DispatchQueue.global(qos: .userInitiated).async { //[weak self] in
            if self.captureSession?.isRunning == true  {
                self.captureSession.stopRunning()
            }
        }
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.createHole()
    }

    // MARK: - Actions

    @objc func handle(_ gestureRecognizer: UIGestureRecognizer) {
        self.openImagePickerController()
    }

    // MARK: - Public

    func startRunning() {
        DispatchQueue.global(qos: .userInitiated).async { //[weak self] in
            if self.captureSession?.isRunning == false {
                self.captureSession.startRunning()
            }
        }
    }

    // MARK: - Private functions

    private func createHole() {
        // Create the initial layer from the view bounds.
        let overlayFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        let maskLayer = CAShapeLayer()
        maskLayer.frame = overlayFrame
        maskLayer.fillColor = UIColor.black.cgColor
        maskLayer.fillRule = .evenOdd

        let path = UIBezierPath(rect: overlayFrame)
        path.append(self.pathHole())

        maskLayer.path = path.cgPath

        // Set the mask of the view.
        self.qrCodePlaceholder.layer.mask = maskLayer
    }

    private func pathHole() -> UIBezierPath {
        let rect = self.qrCodeHolePlaceholder?.frame ?? CGRect.zero
        let path = UIBezierPath(rect: rect)
        return path
    }

    private func setupCaptureSession() {
        self.captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }

        if self.captureSession.canAddInput(videoInput) {
            self.captureSession.addInput(videoInput)
        }
        else {
            let error = QRCodeScannerError.noCameraPermission
            self.show(error: error)
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if self.captureSession.canAddOutput(metadataOutput) {
            self.captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        }
        else {
            let error = QRCodeScannerError.noCameraPermission
            self.show(error: error)
            return
        }

        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer.frame = self.view.layer.bounds
        self.previewLayer.videoGravity = .resizeAspectFill
        self.view.layer.insertSublayer(previewLayer, at: 0)

//        self.captureSession.startRunning()
    }

    private func found(code: String) {
        self.onFoundString?(code)
    }

    private func performQRCodeDetection(image: UIImage) -> String? {
        guard let cgimage = image.cgImage else {
            return nil;
        }
        let ciImage = CIImage(cgImage: cgimage)
        let options = [CIDetectorAccuracy: CIDetectorAccuracyLow]
        let context = CIContext()
        let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: context, options: options)
        var decode: String?
        if let detector = detector {
            let features = detector.features(in: ciImage)
            for feature in features as! [CIQRCodeFeature] {
                decode = feature.messageString
            }
        }
        return decode
    }

    private func openImagePickerController() {
        #if targetEnvironment(simulator)

        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary

        imagePicker.delegate = self

        self.present(imagePicker, animated: true)

        #endif
    }
}

extension QRCodeScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        self.captureSession.stopRunning()

        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            self.found(code: stringValue)
        }

//        self.dismiss(animated: true)
    }
}

extension QRCodeScannerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) {
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage, let result = self.performQRCodeDetection(image: image) {
                self.found(code: result)
            }
        }
    }
}
// MARK: Alerts
extension QRCodeScannerViewController {
    private func showAlertInputNotAvailable() {
        let alert = self.alertInputNotAvailable()

        self.present(alert, animated: true)
    }

    private func alertInputNotAvailable() -> UIAlertController {
        let message = QRCodeScannerError.noCameraPermission.localizedDescription

        let alert = UIAlertController.init(title: LS("general.alert.title.warning"), message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: LS("general.button.ok"), style: .default, handler: { (_) in
            //self.dismiss(animated: true)
        }))
        alert.addAction(UIAlertAction.init(title: LS("general.button.settings"), style: .default, handler: { (_) in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }

            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)") // Prints true
                })
            }
        }))

        return alert
    }
}

extension QRCodeScannerViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }
}
