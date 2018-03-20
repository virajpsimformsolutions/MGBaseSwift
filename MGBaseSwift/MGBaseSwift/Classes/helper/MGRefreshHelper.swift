//
//  RefreshHelper.swift
//  mgbaseproject
//
//  Created by Magical Water on 2018/1/30.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation
import UIKit

//scroll view刷新工具封裝
public class MGRefreshHelper: NSObject {

    private var refreshControl: UIRefreshControl?

    weak public var refreshDelegate: MGRefreshHelperDelegate?

    //需要可以下拉刷新的view
    public func setRefresh(view: UIScrollView) {
        //代表註冊了下拉刷新
        refreshControl = UIRefreshControl.init()
        refreshControl?.addTarget(self, action: #selector(refreshStart), for: UIControlEvents.valueChanged)

        let style: NSMutableParagraphStyle = NSMutableParagraphStyle()
        style.alignment = .center
        style.lineBreakMode = .byTruncatingTail
        let stringAttrs: [NSAttributedStringKey : Any] = [
            NSAttributedStringKey.foregroundColor: UIColor.black,
            NSAttributedStringKey.paragraphStyle: style
        ]

        refreshControl?.attributedTitle = NSAttributedString.init(string: "下拉刷新資料", attributes: stringAttrs)
        refreshControl?.tintColor = UIColor.black

        view.addSubview(refreshControl!)
    }


    //下拉刷新開始
    @objc private func refreshStart() {
        if let d = refreshDelegate {
            d.refreshStart()
        } else {
            refreshEnd()
        }
    }

    public func refreshEnd() {
        refreshControl?.endRefreshing()
    }

}


public protocol MGRefreshHelperDelegate : class {
    func refreshStart()
}
