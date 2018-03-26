//
//  ViewController.swift
//  MGBaseSwift
//
//  Created by Magical Water on 2018/3/20.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    private var networkUtils: MGNetworkDetectUtils = MGNetworkDetectUtils()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view, typically from a nib.
        testNetworkDetect()
    }


    //測試網路狀態檢測
    private func testNetworkDetect() {
        networkUtils.networkDelegate = self
        networkUtils.start()
    }

}

extension ViewController: MGNetworkDetectDelegate {
    func networkStatusChange(_ status: MGNetworkDetectUtils.NetworkStatus) {
        print("當前網路狀態: \(status)")
    }
}

