//
//  MGQRCodeScaner.swift
//  MGBaseProject
//
//  Created by Magical Water on 2018/3/7.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

//掃描qrcode
public class MGQRCodeScaner: NSObject {

    public weak var scanDelegate: MGScanDelegate?

    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!

    private weak var inView: UIView?

    public override init() {
        super.init()
    }

    //初始化掃描qrcode的view, 回傳初始化是否成功
    public func initView(_ inView: UIView) -> Bool {
        self.inView = inView
//        inView.backgroundColor = UIColor.black

        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            scanDelegate?.failed()
            return false
        }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            //初始化發生錯誤
            print("初始化 AVCaptureDeviceInput 發生錯誤")
            scanDelegate?.failed()
            return false
        }

        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            scanDelegate?.failed()
            return false
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            scanDelegate?.failed()
            return false
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = inView.bounds
        previewLayer.videoGravity = .resizeAspectFill
        inView.layer.addSublayer(previewLayer)

        return true
    }


    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        previewLayer.frame = previewLayer.superlayer!.bounds
    }

    deinit {
        inView?.removeObserver(self, forKeyPath: "bounds")
    }


    //開始掃描
    public func startScan() {
        if captureSession?.isRunning == false {
            inView?.addObserver(self, forKeyPath: "bounds", options: .new, context: nil)
            captureSession.startRunning()
        }
    }

    public func stopScan() {
        if captureSession?.isRunning == true {
            inView?.removeObserver(self, forKeyPath: "bounds")
            captureSession.stopRunning()
        }
    }

    private func failed(_ inVC: UIViewController) {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        inVC.present(ac, animated: true)
        captureSession = nil
    }
}

extension MGQRCodeScaner: AVCaptureMetadataOutputObjectsDelegate {
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {

        //檢測是否為qrcode
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        if metadataObj.type == AVMetadataObject.ObjectType.qr {

            //倘若發現的原資料與 QR code 原資料相同，便更新狀態標籤的文字並設定邊界
            let barCodeObject = previewLayer?.transformedMetadataObject(for: metadataObj) as! AVMetadataMachineReadableCodeObject
//            qrCodeFrameView?.frame = barCodeObject.bounds;
            if let detectData = metadataObj.stringValue {
//                messageLabel.text = metadataObj.stringValue
                scanDelegate?.detectData(detectData)
            }
        }
    }
}


public protocol MGScanDelegate : class {
    func detectData(_ content: String)
    func failed()
}
