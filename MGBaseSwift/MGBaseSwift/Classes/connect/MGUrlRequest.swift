//
//  MGUrlRequest.swift
//  mgbaseproject
//
//  Created by Magical Water on 2018/1/30.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation

/*
 網路 request 需要裝入的 class
 */
public class MGUrlRequest {

    //所要連接的 url 相關參數, 反序列化相關
    public var content: [MGRequestContent]

    //request 回來的 response
    public var response: [MGResponse] = []

    //request 執行順序
    public var runSort: [[Int]]

    //整個 Request 執行的方式
    public var executeType: MGExecuteType

    //跳轉頁面相關
    public var pageInfo: MGPageInfo?

    //資料是否過期, 給 MGFgtManager 統一設置是否過期的標籤, 當過期代表資料不可重用
    public var isExpired: Bool = false

    //將此request加上標記
    public var requestTag: String?

//    //有任何東西需要攜帶的直接放入此array
//    private var attachData: [String:Any] = [:]

    init (_ content: [MGRequestContent], sort: [[Int]]?, executeType: MGExecuteType, pageInfo: MGPageInfo?, requestTag: String?) {
        self.content = content
        self.executeType = executeType
        self.pageInfo = pageInfo
        self.requestTag = requestTag

        //如果沒有自訂順序, 則執行順序是串連
        if let s = sort {
            self.runSort = s
        } else {
            self.runSort = []
            for i in 0..<content.count {
                self.runSort.append([i])
            }
        }

        response = [MGResponse] (repeatElement(MGResponse(), count: content.count))
    }


    //返回的資料形式
    public enum MGResponseDataType {
        case image
        case text
    }

    public class MGResponse {

        open var instance: Any? = nil
        open var code: String
        open var message: String? = nil
        open var isSuccess: Bool = false
        open var httpStatus: Int? = nil

        public convenience init() {
            self.init("-1")
        }

        public init(_ responseCode: String) {
            self.code = responseCode
        }

        public func getIns<T>() -> T? {
            return instance as? T
        }
    }

//    public func addAttachData(_ key: String, data: Any) {
//        attachData[key] = data
//    }
//
//    public func getAttachData<T>(_ key: String) -> T? {
//        return attachData[key] as? T
//    }

    //request執行的類型
    public enum MGExecuteType {
        case successBack    //只要遇到成功即回傳, 換句話說直到成功為止
        case all            //即使中間發生錯誤也不回傳, 依定執行完所有 url 的 request才回傳
        case errorBack      //預設, 只要發生錯誤就回傳
    }

    //request 每個 url 執行順序的類型
    public enum MGSortType {
        case custom //自訂順序
        case concurrent //併發
        case sort //依照 urls 的順序一個一個往下
    }

    /**
     * 構建 UrlRequest
     * */
    public class MGRequestBuilder {
        private var content: [MGRequestContent] = []
        private var runSort: [[Int]]? = nil
        private var runSortType: MGSortType = MGSortType.sort
        private var executeType: MGExecuteType = MGExecuteType.errorBack
        private var responseType: [MGResponseDataType]? = nil
        private var pageInfo: MGPageInfo? = nil
        private var requestTag: String? = nil

        public init() {}

        public func setPageInfo(_ pageInfo: MGPageInfo?) -> MGRequestBuilder {
            self.pageInfo = pageInfo
            return self
        }

        public func setTag(_ tag: String) -> MGRequestBuilder {
            self.requestTag = tag
            return self
        }

        public func setUrlContent(_ content: MGRequestContent...) -> MGRequestBuilder {
            self.content = content
            return self
        }

        public func setRunSort(_ runSort: [[Int]]? = nil, type: MGSortType = MGSortType.sort) -> MGRequestBuilder {
            self.runSort = runSort
            self.runSortType = type
            return self
        }

        public func setExecuteType(type: MGExecuteType) -> MGRequestBuilder {
            self.executeType = type
            return self
        }

        public func setResponseDataType(type: MGResponseDataType...) -> MGRequestBuilder {
            self.responseType = type
            return self
        }

        public func build() -> MGUrlRequest {
            let ins = MGUrlRequest(
                content,
                sort: runSort,
                executeType: executeType,
                pageInfo: pageInfo,
                requestTag: requestTag
            )
            return ins
        }
    }
}
