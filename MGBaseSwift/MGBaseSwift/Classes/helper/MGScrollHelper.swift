//
//  MGScrollHelper.swift
//  mgbaseproject
//
//  Created by Magical Water on 2018/2/6.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation
import UIKit

public class MGScrollHelper: NSObject {

    //滑動方向委託回調
    weak var scrollDirectionDelegate: MGScrollDelegate?

    //滑動監測方向默認為垂直
    var scrollOrientation: ScrollOrientation = .vertical

    var scrollActiveRange: CGFloat = 50 //檢測當滑動距離(nowScrollValue)超過此值, 則判定滑動某個方向中開始
    var nowScrollValue: CGFloat = 0 //儲存滑動累積的距離


    //滑動監測方向
    public enum ScrollOrientation{
        case vertical
        case horizontal
    }


    //正在滑動的方向
    public enum ScrollDirection {
        case none
        case up
        case down
        case left
        case right
    }

    //滑動邊界
    public enum ScrollBoundary {
        case none
        case top
        case bottom
        case leading
        case trailing
    }
}


//基於滑動方向之類
extension MGScrollHelper: UIScrollViewDelegate {

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {

        //只有當委託回調有設置了才會進行回調
        guard let delegate = scrollDirectionDelegate else {
            return
        }

    }
}

//監測滑動狀態委託
public protocol MGScrollDelegate: class {
    func scrollActive(direction: MGScrollHelper.ScrollDirection, boundary: MGScrollHelper.ScrollBoundary)
}
