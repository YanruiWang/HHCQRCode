//
//  QRCodeView.swift
//  HHCQRCode
//
//  Created by 王彦睿 on 2017/1/16.
//  Copyright © 2017年 家健文化传媒. All rights reserved.
//

import UIKit
import AVFoundation

public protocol QRCodeDelegate {
    func didDetect(QRCode: String)
}

public final class QRCodeView: UIView, AVCaptureMetadataOutputObjectsDelegate {

    private let barCodeTypes = [AVMetadataObjectTypeUPCECode, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode39Mod43Code,
                        AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeCode128Code,
                        AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeQRCode, AVMetadataObjectTypeAztecCode]
    
    private var previewLayer: AVCaptureVideoPreviewLayer!
    
    private var highlightView = UIView()
    
    private let session = AVCaptureSession()
    
    private var input: AVCaptureDeviceInput?
    
    private let stillImageOutput = AVCaptureStillImageOutput()
    
    private let previewRect = PreviewRect()
    
    private var greenLine = UIImageView()
    
    private var upGreenConstraints: [NSLayoutConstraint] = []
    
    private var downGreenConstrains: [NSLayoutConstraint] = []
    
    private var detectionString :String!
    
    public var delegate: QRCodeDelegate?
    
    public func previewSetup() {
        // 不是 async 的话会 block UI
        DispatchQueue.main.async {
            self.start()
        }
    }
    
    private func start() {
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            return
        }
        session.sessionPreset = AVCaptureSessionPreset1280x720
        backgroundColor = UIColor.clear.withAlphaComponent(0.0)
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        do {
            try input = AVCaptureDeviceInput(device: device)
            highlightView.autoresizingMask =
                [.flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
            
            highlightView.layer.borderColor = UIColor.green.cgColor
            highlightView.layer.borderWidth = 3
            
            addSubview(self.highlightView)
            
            if input != nil {
                session.addInput(input)
                
                previewLayer = AVCaptureVideoPreviewLayer(session: session)
                previewLayer.frame = bounds
                previewLayer.videoGravity = AVLayerVideoGravityResizeAspect
                
                let outputSettings = [AVVideoCodecKey : AVVideoCodecJPEG]
                
                stillImageOutput.outputSettings = outputSettings
                
                session.addOutput(stillImageOutput)
                
                //识别条码
                let output = AVCaptureMetadataOutput()
                output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                session.addOutput(output)
                output.metadataObjectTypes = output.availableMetadataObjectTypes
                
                layer.addSublayer(previewLayer)
            }
            
            layer.addSublayer(previewLayer)
            
            session.startRunning()
            
            addPreviewRect()
            addScanLineConstraints()
            
            addBlackView()
            
            moveScanGreenLine()
        } catch let error {
            print(error)
        }
    }
    
    /// 扫描框内上下移动的线的 constaints
    ///
    /// TODO: 当本组件不再支持 iOS 时, 请将 ```else{}``` 内的内容移除
    fileprivate func addScanLineConstraints() {
        if #available(iOS 9.0, *) {
            upGreenConstraints = [greenLine.centerXAnchor.constraint(equalTo: previewRect.centerXAnchor),
                                  greenLine.topAnchor.constraint(equalTo: previewRect.topAnchor, constant: 5),
                                  greenLine.leadingAnchor.constraint(equalTo: previewRect.leadingAnchor, constant: 5),
                                  greenLine.heightAnchor.constraint(equalToConstant: 4)]
            downGreenConstrains = [greenLine.centerXAnchor.constraint(equalTo: previewRect.centerXAnchor),
                                   greenLine.bottomAnchor.constraint(equalTo: previewRect.bottomAnchor, constant: -5),
                                   greenLine.leadingAnchor.constraint(equalTo: previewRect.leadingAnchor, constant: 5),
                                   greenLine.heightAnchor.constraint(equalToConstant: 4)]
            
        } else {
            upGreenConstraints = [NSLayoutConstraint(item: greenLine, attribute: .centerX, relatedBy: .equal, toItem: previewRect, attribute: .centerX, multiplier: 1, constant: 0),
                                  NSLayoutConstraint(item: greenLine, attribute: .top, relatedBy: .equal, toItem: previewRect, attribute: .top, multiplier: 1, constant: 5),
                                  NSLayoutConstraint(item: greenLine, attribute: .leading, relatedBy: .equal, toItem: previewRect, attribute: .leading, multiplier: 1, constant: 5),
                                  NSLayoutConstraint(item: greenLine, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 4)]
            downGreenConstrains = [NSLayoutConstraint(item: greenLine, attribute: .centerX, relatedBy: .equal, toItem: previewRect, attribute: .centerX, multiplier: 1, constant: 0),
                                   NSLayoutConstraint(item: greenLine, attribute: .bottom, relatedBy: .equal, toItem: previewRect, attribute: .bottom, multiplier: 1, constant: -5),
                                   NSLayoutConstraint(item: greenLine, attribute: .leading, relatedBy: .equal, toItem: previewRect, attribute: .leading, multiplier: 1, constant: 5),
                                   NSLayoutConstraint(item: greenLine, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 4)]
        }
        
        NSLayoutConstraint.activate(upGreenConstraints)
    }
    
    /// 扫描框四周的黑色半透明遮罩
    fileprivate func addBlackView() {
        let blackViewLeft = UIView()
        blackViewLeft.translatesAutoresizingMaskIntoConstraints = false
        blackViewLeft.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        addSubview(blackViewLeft)
        if #available(iOS 9.0, *) {
            NSLayoutConstraint.activate([blackViewLeft.leadingAnchor.constraint(equalTo: leadingAnchor),
                                         blackViewLeft.topAnchor.constraint(equalTo: topAnchor),
                                         blackViewLeft.bottomAnchor.constraint(equalTo: bottomAnchor),
                                         blackViewLeft.trailingAnchor.constraint(equalTo: previewRect.leadingAnchor)])
        } else {
            NSLayoutConstraint.activate([NSLayoutConstraint(item: blackViewLeft, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0),
                                         NSLayoutConstraint(item: blackViewLeft, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0),
                                         NSLayoutConstraint(item: blackViewLeft, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0),
                                         NSLayoutConstraint(item: blackViewLeft, attribute: .trailing, relatedBy: .equal, toItem: previewRect, attribute: .leading, multiplier: 1, constant: 0)])
        }
        
        let blackViewRight = UIView()
        blackViewRight.translatesAutoresizingMaskIntoConstraints = false
        blackViewRight.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        addSubview(blackViewRight)
        if #available(iOS 9.0, *) {
            NSLayoutConstraint.activate([blackViewRight.leadingAnchor.constraint(equalTo: previewRect.trailingAnchor),
                                         blackViewRight.topAnchor.constraint(equalTo: topAnchor),
                                         blackViewRight.bottomAnchor.constraint(equalTo: bottomAnchor),
                                         blackViewRight.trailingAnchor.constraint(equalTo: trailingAnchor)])
        } else {
            NSLayoutConstraint.activate([NSLayoutConstraint(item: blackViewRight, attribute: .leading, relatedBy: .equal, toItem: previewRect, attribute: .trailing, multiplier: 1, constant: 0),
                                         NSLayoutConstraint(item: blackViewRight, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0),
                                         NSLayoutConstraint(item: blackViewRight, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0),
                                         NSLayoutConstraint(item: blackViewRight, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0)])
        }
        
        let blackViewTop = UIView()
        blackViewTop.translatesAutoresizingMaskIntoConstraints = false
        blackViewTop.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        addSubview(blackViewTop)
        if #available(iOS 9.0, *) {
            NSLayoutConstraint.activate([blackViewTop.leadingAnchor.constraint(equalTo: previewRect.leadingAnchor),
                                         blackViewTop.topAnchor.constraint(equalTo: topAnchor),
                                         blackViewTop.bottomAnchor.constraint(equalTo: previewRect.topAnchor),
                                         blackViewTop.trailingAnchor.constraint(equalTo: previewRect.trailingAnchor)])
        } else {
            NSLayoutConstraint.activate([NSLayoutConstraint(item: blackViewTop, attribute: .leading, relatedBy: .equal, toItem: previewRect, attribute: .leading, multiplier: 1, constant: 0),
                                         NSLayoutConstraint(item: blackViewTop, attribute: .top, relatedBy: .equal, toItem: previewRect, attribute: .top, multiplier: 1, constant: 0),
                                         NSLayoutConstraint(item: blackViewTop, attribute: .bottom, relatedBy: .equal, toItem: previewRect, attribute: .top, multiplier: 1, constant: 0),
                                         NSLayoutConstraint(item: blackViewTop, attribute: .trailing, relatedBy: .equal, toItem: previewRect, attribute: .trailing, multiplier: 1, constant: 0)])
        }
        
        let blackViewBottom = UIView()
        blackViewBottom.translatesAutoresizingMaskIntoConstraints = false
        blackViewBottom.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        addSubview(blackViewBottom)
        if #available(iOS 9.0, *) {
            NSLayoutConstraint.activate([blackViewBottom.leadingAnchor.constraint(equalTo: previewRect.leadingAnchor),
                                         blackViewBottom.topAnchor.constraint(equalTo: previewRect.bottomAnchor),
                                         blackViewBottom.bottomAnchor.constraint(equalTo: bottomAnchor),
                                         blackViewBottom.trailingAnchor.constraint(equalTo: previewRect.trailingAnchor)])
        } else {
            NSLayoutConstraint.activate([NSLayoutConstraint(item: blackViewBottom, attribute: .leading, relatedBy: .equal, toItem: previewRect, attribute: .leading, multiplier: 1, constant: 0),
                                         NSLayoutConstraint(item: blackViewBottom, attribute: .top, relatedBy: .equal, toItem: previewRect, attribute: .bottom, multiplier: 1, constant: 0),
                                         NSLayoutConstraint(item: blackViewBottom, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0),
                                         NSLayoutConstraint(item: blackViewBottom, attribute: .trailing, relatedBy: .equal, toItem: previewRect, attribute: .trailing, multiplier: 1, constant: 0)])
        }
    }
    
    /// 扫描框
    fileprivate func addPreviewRect() {
        
        previewRect.translatesAutoresizingMaskIntoConstraints = false
        previewRect.autoresizingMask =
            [UIViewAutoresizing.flexibleTopMargin, UIViewAutoresizing.flexibleBottomMargin, UIViewAutoresizing.flexibleLeftMargin, UIViewAutoresizing.flexibleRightMargin]
        
        addSubview(previewRect)
        if #available(iOS 9.0, *) {
            let con = [previewRect.centerXAnchor.constraint(equalTo: centerXAnchor),
                       previewRect.centerYAnchor.constraint(equalTo: centerYAnchor),
                       previewRect.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
                       previewRect.heightAnchor.constraint(equalTo: previewRect.widthAnchor)]
            con.forEach { $0.priority = 1000 }
            NSLayoutConstraint.activate(con)
        } else {
            let con = [NSLayoutConstraint(item: previewRect, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0),
                       NSLayoutConstraint(item: previewRect, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0),
                       NSLayoutConstraint(item: previewRect, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 20),
                       NSLayoutConstraint(item: previewRect, attribute: .height, relatedBy: .equal, toItem: previewRect, attribute: .height, multiplier: 1, constant: 0)]
            con.forEach { $0.priority = 1000 }
            NSLayoutConstraint.activate(con)
        }
       
        
        bringSubview(toFront: previewRect)
        previewRect.backgroundColor = UIColor.clear.withAlphaComponent(0.0)
        
        previewRect.setNeedsDisplay()
        
        greenLine = UIImageView()
        greenLine.translatesAutoresizingMaskIntoConstraints = false
        let bundle = Bundle(for: type(of: self))
        greenLine.image = UIImage(named:"scanline", in: bundle, compatibleWith: nil)?.resizableImage(withCapInsets: UIEdgeInsetsMake(1, 1, 1, 1), resizingMode: .stretch)
        previewRect.addSubview(greenLine)
    }
    
    /// 添加扫描框中上下移动的线的动画
    private func moveScanGreenLine() {
        NSLayoutConstraint.deactivate(downGreenConstrains)
        self.layoutIfNeeded()
        UIView.animate(withDuration: 4.0, delay: 0.0, options: [.repeat], animations: {
            NSLayoutConstraint.deactivate(self.upGreenConstraints)
            NSLayoutConstraint.activate(self.downGreenConstrains)
            self.layoutIfNeeded()
        }, completion: nil)
    }
    
    public func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            return
        }
        
        var highlightViewRect = CGRect.zero
        
        var barCodeObject: AVMetadataObject!
        
        for metadata in metadataObjects {
            
            for barcodeType in barCodeTypes {
                if (metadata as AnyObject).type == barcodeType {
                    barCodeObject = self.previewLayer.transformedMetadataObject(for: metadata as! AVMetadataMachineReadableCodeObject)
                    highlightViewRect = barCodeObject.bounds
                    detectionString = (metadata as! AVMetadataMachineReadableCodeObject).stringValue  //扫描到的条码
                    if detectionString != nil && detectionString != "" {
                        delegate?.didDetect(QRCode: detectionString)
                    }
                }
            }
        }
        
        highlightView.frame = CGRect(x: highlightViewRect.origin.x, y: highlightViewRect.origin.y, width: highlightViewRect.size.width, height: highlightViewRect.size.height)
        
        bringSubview(toFront: self.highlightView)
        
        
    }

}
