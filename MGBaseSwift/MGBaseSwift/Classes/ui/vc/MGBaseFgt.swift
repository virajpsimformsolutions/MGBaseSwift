//
//  MGBaseFgt.swift
//  MGBaseProject
//
//  Created by Magical Water on 2018/2/22.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import UIKit

open class MGBaseFgt: UIViewController, MGApiHelperDelegate, MGFgtDataHelper {


    private var apiHelper: MGBaseApiHelper? = nil

    override open func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        settingApiHelper()
        setupView()
    }

    //頁面資料進入點
    open func pageData(_ data: MGPageData, isFgtInit: Bool) {
        
    }

    //抓取是否啟用 api 輔助物件的工具
    private func settingApiHelper() {
        apiHelper = enableApiHelper() ? MGBaseApiHelper() : nil
        apiHelper?.delegate = self
    }

    open func setupView() {}

    //是否啟用 api 輔助 class
    open func enableApiHelper() -> Bool { return true}


    //子類別設定倒數計時狀態
    public func timerAction(_ action: MGBaseApiHelper.TimerAction) {
        apiHelper?.timerAction(action)
    }

    //設定倒數計時預設時間
    public func setTimerTime(_ time: TimeInterval) {
        apiHelper?.timerTime = time
    }


    //發送request
    public func sendRequest(_ rt: MGUrlRequest, code: Int = MGRequestSender.REQUEST_DEFAUT) {
        apiHelper?.sendRequest(rt, requestCode: code)
    }


    //******************** API 委託相關回傳 以下 **************************
    open func response(_ request: MGUrlRequest, success: Bool, requestCode: Int) { }

    open func timesUp() { }
    //******************** API 委託相關回傳 結束 **************************


}
