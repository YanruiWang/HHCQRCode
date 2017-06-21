//
//  QRCodeScanViewController.swift
//  HHCQRCode
//
//  Created by 王彦睿 on 2017/1/18.
//  Copyright © 2017年 家健文化传媒. All rights reserved.
//

import UIKit
import AVFoundation

public class QRCodeScanViewController: UIViewController, QRCodeDelegate {

    public let qrCodeView = QRCodeView()

    public var codeDetected: String?

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        view.addSubview(qrCodeView)
        qrCodeView.delegate = self
        qrCodeView.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 9.0, *) {
            NSLayoutConstraint.activate([qrCodeView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                                         qrCodeView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                                         qrCodeView.topAnchor.constraint(equalTo: view.topAnchor),
                                         qrCodeView.bottomAnchor.constraint(equalTo: view.bottomAnchor)])
        } else {
            NSLayoutConstraint.activate([NSLayoutConstraint(item: qrCodeView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0),
                                         NSLayoutConstraint(item: qrCodeView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0),
                                         NSLayoutConstraint(item: qrCodeView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0),
                                         NSLayoutConstraint(item: qrCodeView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0)])
        }

        if isCameraPermitted() {
            qrCodeView.previewSetup()
        }

    }

    func isCameraPermitted() -> Bool {
        let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        switch status {
        case .notDetermined:
            let result = false
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (granted) in
                if granted {
                    self.qrCodeView.previewSetup()
                }
            })
            return result
        case .restricted:
            return false
        case .authorized:
            return true
        default:
            return false
        }
    }

    func isCameraAvailable() -> Bool {
        return UIImagePickerController.isSourceTypeAvailable(.camera)
    }

    public func didDetect(QRCode: String) {
        codeDetected = QRCode
    }


}
