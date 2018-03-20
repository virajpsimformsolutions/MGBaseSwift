//
//  MGRequestSender.swift
//  mgbaseproject
//
//  Created by Magical Water on 2018/1/30.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation

/*
 一般呼叫 api(非跳頁, 或者須完全自行處理的)
 */
public class MGRequestSender: MGRequestCallback {

    /*
     一般呼叫 api 都會有統一回傳的接口
     為了分辨誰是誰, 我們得給每次的 request 加上一個編號
     通常request 只有幾種分類, 未免每次都重新定義, 這邊直接定義幾種
     */
    public static let REQUEST_DEFAUT = -1
    public static let REQUEST_LOAD_MORE = -2
    public static let REQUEST_LOAD_TOP = -3
    public static let REQUEST_REFRESH = -4

    weak var delegate: MGRequestSenderDelegate?

    //儲存所有的 request
    private var requests: [Int:MGUrlRequest] = [:]


    /**************************供外部呼叫 以下********************************/
    //發送 REQUEST, 默認 code 是 REQUEST_DEFAUT
    public func send(_ request: MGUrlRequest, requestCode: Int = REQUEST_DEFAUT) {
        MGRequestConnect.getData(request, requestCode: requestCode, cbk: self)
    }
    /**************************供外部呼叫 結束********************************/

    public func response(_ request: MGUrlRequest, requestCode: Int, success: Bool) {
        delegate?.response(request, success: success, requestCode: requestCode)
    }


}


//處理 MGRequestSender 的回傳
protocol MGRequestSenderDelegate: class {
    func response(_ request: MGUrlRequest, success: Bool, requestCode: Int)
}







