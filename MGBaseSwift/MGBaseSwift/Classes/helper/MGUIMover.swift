//
//  MGUIMover.swift
//  mgbaseproject
//
//  Created by Magical Water on 2018/1/31.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation
import UIKit

//位移view相關工具
public class MGUIMover {

    private var movableItem: [UIView : Attr] = [:]
    private var animationUtils = MGAnimationUtils()


    public init() {}

    //得到某個view的attr
    public func getAttr(_ view: UIView) -> Attr? {
        if let attr = movableItem[view] {
            return attr
        }
        return nil
    }

    public func addItem(_ view: UIView, attr: Attr) {
        movableItem[view] = attr
    }

    //將所有view都往外移, 除了參數的view之外
    public func outAllView(_ exView: [UIView] = []) {
        for mi in movableItem where !exView.contains(mi.key) {
            _ = startMoveOut(mi.key)
        }
    }

    //移動某個特定的view
    public func moveView(_ view: UIView, isOut: Bool) {
        if let _ = movableItem[view] {
            if isOut { _ = startMoveOut(view) }
            else { _ = startMoveIn(view) }
        }
    }

    //回傳是否成功
    public func startMoveIn(_ view: UIView) -> Bool {
        guard let attr = movableItem[view], attr.state == .idle_out || attr.state == .moving_out else {
            return false
        }

        attr.state = .moving_in
        executeAnim(view: view, attr: attr, isOut: false)

        return true
    }


    public func startMoveOut(_ view: UIView) -> Bool {
        guard let attr = movableItem[view], attr.state == .idle_in || attr.state == .moving_in else {
            return false
        }

        attr.state = .moving_out
        executeAnim(view: view, attr: attr, isOut: true)

        return true

    }

    //執行動畫
    private func executeAnim(view: UIView, attr: Attr, isOut: Bool) {

        //位移方向是否為正向, 當向下/向右(x越大/y越大), 為正向
        let isPositive = (attr.direction == .down || attr.direction == .right)

        //取得位移距離
        var viewSize: CGFloat
        if attr.direction == .left || attr.direction == .right {
            viewSize = view.frame.width
        } else {
            viewSize = view.frame.height
        }

        //位移距離需要再加上偏移距離
        viewSize = viewSize + attr.outOffset

        //位移的方向是否為正向, 若為反向, 則需要改變位移距離為負值
        if !isPositive { viewSize = -viewSize }

        //位移的起始與結束數值
        let start: CGFloat = isOut ? 0 : viewSize
        let end: CGFloat = isOut ? viewSize : 0

        let tramsformKey: String
        switch attr.direction {
        case .down, .up: tramsformKey = MGAnimationKey.translateY
        case .left, .right: tramsformKey = MGAnimationKey.translateX
        }

        let translateAttr = MGAnimationAttr(tramsformKey, start: start, end: end)
        var animAttrs: [MGAnimationAttr] = [translateAttr]

        if attr.outAlpha {
            let alphaAttr = MGAnimationAttr(MGAnimationKey.opacity, start: isOut ? 1 : 0, end: isOut ? 0 : 1)
            animAttrs.append(alphaAttr)
        }

        let scaleAttr = MGAnimationAttr(MGAnimationKey.scale, start: isOut ? 1 : attr.scale, end: isOut ? attr.scale : 1)
        animAttrs.append(scaleAttr)

//        print("動畫前: view.frame = \(view.frame), layer.frame = \(view.layer.frame)")

        MGTransformUtils.animator(view, attrs: animAttrs, duration: attr.duration)
//        animationUtils.animator(view, attr: animAttrs, duration: CFTimeInterval(attr.duration), animTag: "animTag") {
//            //動畫結束, 確認frame位置
//            print("動畫後: view.frame = \(view.frame), layer.frame = \(view.layer.frame)")
//
////            CATransaction.begin()
////            CATransaction.setDisableActions(true)
////            view.layer.frame = view.frame
////            CATransaction.commit()
//        }
    }


    //view的動畫相關屬性
    public class Attr {

        public var direction: Direction
        public var duration: TimeInterval
        public var state: State
        public var outAlpha: Bool = false //移出時是否要加入透明
        public var outOffset: CGFloat = 0 //移出時多增加的位移
        public var scale: CGFloat = 1 //移出時的縮放倍數

        public init(direct: Direction, dur: TimeInterval, s: State) {
            self.direction = direct
            self.duration = dur
            self.state = s
        }

    }

    public enum Direction {
        case up
        case down
        case left
        case right
    }

    public enum State {
        case moving_in
        case moving_out
        case idle_in
        case idle_out
    }

}
