//
//  MGBaseVC.swift
//  mgbaseproject
//
//  Created by Magical Water on 2018/1/5.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import UIKit

/*
 最基本的上層 VC, 封裝一些普遍的需求(例如倒數計時, api request)
 */
open class MGBaseAty: UIViewController, MGApiHelperDelegate, MGVCManagerDelegate {

    private var apiHelper: MGBaseApiHelper? = nil
    private var fgtManager: MGFgtManager? = nil

    override open func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        settingApiHelper()
        settingFgtManager()
        setupView()
        registerObserverAtyStatus()
    }

    //監測頁面狀態(回到前台/進入後台)
    private func registerObserverAtyStatus() {
        //進入前台監聽
        NotificationCenter.default.addObserver(self, selector: #selector(activityToForeground), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)

        //進入後台監聽
        NotificationCenter.default.addObserver(self, selector: #selector(activityTobackground), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
    }


    private func unregisterOberverAtyStatus() {
        NotificationCenter.default.removeObserver(self)
    }

    deinit {
        unregisterOberverAtyStatus()
    }

    @objc open func activityToForeground() {}
    @objc open func activityTobackground() {}

    //抓取是否啟用 api 輔助物件的工具
    private func settingApiHelper() {
        apiHelper = enableApiHelper() ? MGBaseApiHelper() : nil
        apiHelper?.delegate = self
    }

    //抓取是否啟用 api 輔助物件的工具
    private func settingFgtManager() {
        fgtManager = enableFgtManager() ? MGFgtManager() : nil
        fgtManager?.setBaseCotainer(vcContainer())
        fgtManager?.delegate = self
        if let rootPage = rootPage() {
            fgtManager?.setRootPage(rootPage)
        }
    }


    open func setupView() {}

    //是否啟用 api 輔助 class
    open func enableApiHelper() -> Bool { return true}

    //是否啟用 fgt管理 輔助 class
    open func enableFgtManager() -> Bool { return true }

    //裝載所有vc的view
    open func vcContainer() -> UIViewController { return self }

    //如果啟VC管理則此項必須設置
    open func rootPage() -> MGPageData? { return nil }


    //子類別設定倒數計時狀態
    public func timerAction(_ action: MGBaseApiHelper.TimerAction) {
        apiHelper?.timerAction(action)
    }

    //設定倒數計時預設時間
    public func setTimerTime(_ time: TimeInterval) {
        apiHelper?.timerTime = time
    }

    //設定 vc manager 的 root page
    public func setRootPage(_ page: MGPageData) {
        fgtManager?.setRootPage(page)
    }

    //跳轉到某個 VC, 可供複寫, 為的在跳轉前的執行動作
    open func fgtShow(_ request: MGUrlRequest) {
        fgtManager?.pageJump(request)
    }

    //顯示某個頁面, 不用經過網路
    public func fgtShow(_ pageInfo: MGPageInfo) {
        fgtManager?.pageJump(pageInfo)
    }

    //隱藏某個頁面
    public func fgtHide(_ vcTag: String) {
        fgtManager?.hideFgt(vcTag)
    }

    //回到首頁
    public func toRootPage() {
        fgtManager?.toRootPage()
    }

    //得到目前最頂端顯示的page
    public func getTopPage() -> MGPageData? {
        if let page = fgtManager?.totalHistory.last {
            return page
        } else {
            return nil
        }
    }

    //回退上一頁fragment, 回傳代表是否處理 back
    open func backPage(_ back: Int = 1) -> Bool {
        //先檢查最上層的fgt是否處理back的動作, 當back數量等於1時
        guard let fgtManager = fgtManager else {
            return false
        }
        if back == 1 && fgtManager.backAction() {
            return true
        } else {
            return fgtManager.backPage(back)
        }

    }

    //發送request
    public func sendRequest(_ rt: MGUrlRequest, code: Int = MGRequestSender.REQUEST_DEFAUT) {
        apiHelper?.sendRequest(rt, requestCode: code)
    }

    //******************** MGVCManagerDelegate - API 委託相關回傳 以下 **************************

    //跳轉頁面回調
    open func fgtChange(pageData: MGPageData) {}

    //跳轉頁面包含撈取api, 得到response之後, 跳轉頁面之前回調
    //回傳代表是否攔截回調
    open func jumpResponse(request: MGUrlRequest, requestCode: Int, success: Bool) -> Bool { return false }

    //******************** MGVCManagerDelegate - API 委託相關回傳 以下 **************************

    //******************** MGApiHelperDelegate - API 委託相關回傳 以下 **************************
    open func response(_ request: MGUrlRequest, success: Bool, requestCode: Int) { }

    open func timesUp() { }
    //******************** MGApiHelperDelegate - API 委託相關回傳 結束 **************************



    //******************** 局部控制 狀態欄是否隱藏的關鍵 以下 **************************

    //自訂變數控制狀態欄是否隱藏
    var statusHidden: Bool = false {
        didSet {
            UIView.animate(withDuration: 0.2) { () -> Void in
                self.setNeedsStatusBarAppearanceUpdate()
            }
        }
    }

    //顯示隱藏動畫
    override open var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return UIStatusBarAnimation.slide
    }

    //需重寫此變數, 並且在 info.plist 的 View controller-based status bar appearance 設置為 true
    //呼叫 setNeedsStatusBarAppearanceUpdate() 方法時才會重設狀態欄
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    //狀態欄 bar 是否隱藏
    override open var prefersStatusBarHidden: Bool {
        get { return statusHidden }
    }

    //******************** 局部控制 狀態欄是否隱藏的關鍵 結束 **************************



    //******************** vc 支持的螢幕方向 **********************

    //可否自動轉向
    override open var shouldAutorotate: Bool {
        get { return false }
    }

    //支持方向
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get { return [.portrait] }
    }

    //初次進入方向
    override open var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        get { return .portrait }
    }


}
