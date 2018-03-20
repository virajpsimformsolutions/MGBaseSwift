//
//  MGPageInfo.swift
//  mgbaseproject
//
//  Created by Magical Water on 2018/1/30.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation
import UIKit

/*
 頁面相關資訊, 通常與 MGUrlRequest 綁一起
 */
public class MGPageInfo {

    //頁面實體化的 story board
    public var page: UIStoryboard

    //在story board裡面有多個vc, 此時要借用idientfier判別是哪個vc
    public var pageIdientfier: String?

    //頁面的類型, 為裝載 Fragment 的 view id
    public var containerId: String

    //頁面的標籤, 判別頁面的tag
    //因此每個頁面都必須設置
    public var pageTag: String

    //頁面的標題
    public var pageTitle: String

    //此次跳轉是否加入歷史紀錄, 歷史紀錄用來返回上一頁
    public var inHistory: Bool

    //是否為返回上一頁, 不可主動設定, 此參數給 FgtManager 在跳回上一頁時設定
    public var isPageBack: Bool = false

    //此頁面是否需要登入
    public var needLogin: Bool

    //頁面是否為節點, 若是節點則會清除掉之前所有的歷史跳轉
    public var isChainNode: Bool

    //此次跳轉資料是否可重複使用
    public var dataReuse: Bool

    //有任何東西需要攜帶的直接放入此array
    private var attachData: [String:Any] = [:]


    private init(_ page: UIStoryboard,
                 idientifier: String?,
                 containerId: String,
                 pageTag: String,
                 pageTitle: String,
                 inHistory: Bool,
                 needLogin: Bool,
                 isNode: Bool,
                 dataReuse: Bool) {
        self.page = page
        self.pageIdientfier = idientifier
        self.containerId = containerId
        self.pageTag = pageTag
        self.pageTitle = pageTitle
        self.inHistory = inHistory
        self.needLogin = needLogin
        self.isChainNode = isNode
        self.dataReuse = dataReuse
    }


    public func addAttachData(_ key: String, data: Any) {
        attachData[key] = data
    }

    public func getAttachData<T>(_ key: String) -> T? {
        return attachData[key] as? T
    }

    public class MGPageInfoBuilder {
        private var page: UIStoryboard!
        private var pageIdientfier: String?
        private var containerId: String = ""
        private var pageTag: String = ""
        private var pageTitle: String = ""
        private var inHistory: Bool = true
        private var needLogin: Bool = false
        private var isChainNode: Bool = false
        private var dataReuse: Bool = true

        public init() {}

        public func setPage(_ page: UIStoryboard, idientfier: String? = nil) -> MGPageInfoBuilder {
            self.page = page
            self.pageIdientfier = idientfier
            return self
        }

        public func setContainer(_ viewId: String) -> MGPageInfoBuilder {
            self.containerId = viewId
            return self
        }

        public func setPageTitle(_ title: String) -> MGPageInfoBuilder {
            self.pageTitle = title
            return self
        }

        public func setPageTag(_ tag: String) -> MGPageInfoBuilder {
            self.pageTag = tag
            return self
        }

        public func setHistory(_ inHistory: Bool) -> MGPageInfoBuilder {
            self.inHistory = inHistory
            return self
        }

        public func setNeedLogin(_ login: Bool) -> MGPageInfoBuilder {
            self.needLogin = login
            return self
        }

        public func setChainNode(_ isNode: Bool) -> MGPageInfoBuilder {
            self.isChainNode = isNode
            return self
        }

        public func setDataReuse(_ reuseable: Bool) -> MGPageInfoBuilder {
            self.dataReuse = reuseable
            return self
        }



        public func build() -> MGPageInfo {
            return MGPageInfo.init(page, idientifier: pageIdientfier, containerId: containerId,
                                   pageTag: pageTag, pageTitle: pageTitle, inHistory: inHistory,
                                   needLogin: needLogin, isNode: isChainNode, dataReuse: dataReuse)
        }

    }
}
