//
//  MGBaseApiHelper.swift
//  mgbaseproject
//
//  Created by Magical Water on 2018/1/30.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation

/*
 輔助 api 呼叫的 超類
 */
public class MGBaseApiHelper : MGRequestSenderDelegate {

    public weak var delegate: MGApiHelperDelegate?

    //發送api需求用的物件
    private var requestSender: MGRequestSender =  MGRequestSender()

    //倒數計時的工具, 時間, 一個 api helper 只能同個時間只能執行一個倒數計時器
    private var timerUtils: MGTimerUtils = MGTimerUtils()
    var timerWhat: Int = 0x1
    var timerTime: TimeInterval = 3

    public enum TimerAction {
        case start   //開始倒數計時
        case cancel  //結束倒數
        case restart //先結束再開始
    }

    public init() {
        requestSender.delegate = self
    }

    //讓子類呼叫
    public func sendRequest(_ request: MGUrlRequest, requestCode: Int = MGRequestSender.REQUEST_DEFAUT) {
        requestSender.send(request, requestCode: requestCode)
    }

    func response(_ request: MGUrlRequest, success: Bool, requestCode: Int) {
        delegate?.response(request, success: success, requestCode: requestCode)
    }

    func timerAction(_ action: TimerAction, time: TimeInterval? = nil) {
        switch action {
        case .start:
            timerUtils.startCountdown(what: timerWhat, byDelay: time ?? timerTime, handler: timesUp)
            break
        case .cancel:
            timerUtils.cancelIfNeed(what: timerWhat)
            break
        case .restart:
            timerAction(.cancel)
            timerAction(.start)
            break
        }
    }

    //子類複寫, 倒數計時時間到
    func timesUp() {}
}


public protocol MGApiHelperDelegate: class {
    func response(_ request: MGUrlRequest, success: Bool, requestCode: Int)
    func timesUp()
}
