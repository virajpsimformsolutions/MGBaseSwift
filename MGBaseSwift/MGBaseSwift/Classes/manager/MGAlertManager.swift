//
//  MGAlertManager.swift
//  mgbaseproject
//
//  Created by Magical Water on 2018/2/19.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation
import UIKit

public class MGAlertManager {

    //第三個參數代表是否點擊背景可以取消
    public struct AlertData {
        public var view: MGAlertView
        public var type: String
        public var outerCancel: Bool = true //點擊外部是否可取消
        public var width: CGFloat = UIScreen.main.bounds.width
        public var height: CGFloat = UIScreen.main.bounds.height
        public var offsetY: CGFloat = 0
        public init(_ view: MGAlertView, type: String) {
            self.view = view
            self.type = type
        }

        public init(_ view: MGAlertView, type: String, widthMargin: CGFloat, height: CGFloat) {
            self.init(view, type: type)
            self.width -= (widthMargin * 2)
            self.height = height
        }
    }

    public typealias AlertHandler = (_ btnType: AlertButton, _ obj: Any?) -> Void

    public typealias MGAlertView = UIView & MGAlertViewDelegate

    private var bgView: MGBaseView?
    private var bgViewID = "AlertBG"

    private var alertChain: [AlertData] = []
    private var alertHandler: [String : AlertHandler] = [:]

    private var radius: CGFloat = 5

    public static let shared: MGAlertManager = MGAlertManager()

    //alert的類型
//    public enum AlertType {
//        case reconnect //重新連線
//    }

    //按鈕類型, 分成左中右三種
    public enum AlertButton {
        case left
        case center
        case right
    }

    //*************************** 以下讓外部呼叫, 跳出alert ***************************

    //呼叫alert, 一切起始源為此處
    public func alert(_ data: inout AlertData, handler: AlertHandler? = nil) {
        //檢查是否需要動作
        if !isNeedAction(data.type) {
            print("dialog 畫面已存在, 不重複顯示")
            return
        }
        data.view.alertDelegate = self

        if let h = handler {
            alertHandler[data.type] = h
        }
        alertChain.append( data )

        show( data )
    }


//    func buildDatePicker(_ select: Date, _ minDate: Date?, _ maxDate: Date?, mode: UIDatePickerMode, _ handler: BackAlertHandler? = nil) {
//        //檢查是否需要動作
//        if !isNeedAction(.date) {
//            print("時間選擇 dialog 畫面已存在, 不重複顯示")
//            return
//        }
//
//        let view = GPC_AlertDatePicker()
//        view.datePicker.maximumDate = maxDate
//        view.datePicker.minimumDate = minDate
//        view.datePicker.date = select
//        view.alertTapDelegate = self
//
//        view.datePicker.datePickerMode = mode
//
//        if let h = handler {
//            alertHandler[.date] = h
//        }
//
//        alertChain.append( AlertMap(type: .date, view: view, bgCancel: true) )
//
//        show(view, 200, true, true)
//    }

    //隱藏最上面的一個alert
    func dismissLast() {
        if let am = alertChain.last {
            hide(am)
        }
    }

    //關閉特定的 Alert, 這邊目前只有在登出時並且時間選擇浮出視窗開啟時使用
    func dismiss(_ byType: String) {
        for am in alertChain where am.type == byType {
            hide(am)
            return
        }
    }

    //檢查是否需要動作
    private func isNeedAction(_ type: String) -> Bool {
        if isTypeAdded(type) {
            //檢查此view是否在最上層, 若是的話不做任何動作
            //若不在最上層則把view移動到最上層
            if isTypeTop(type) {
                print("alert管理: 已有 alert: \(type) 存在 且在最上層, 不進行動作")
            } else {
                print("alert管理: 已有 alert: \(type) 存在 但不在最上層, 變更順序")
                bringTypeToTop(type)
            }
            return false
        }
        return true
    }

//    //顯示alert - 預設寬高
//    private func show(_ contentView: UIView, height: CGFloat, customBound: Bool, customBG: Bool) {
//        show(contentView, UIScreen.main.bounds.width, height, 0, customBound, customBG)
//    }

    //顯示alert - 自訂寬高
    private func show(_ data: AlertData) {
//        //設置內容背景顏色及圓角
//        if !customBound {
//            contentView.layer.cornerRadius = radius
//            contentView.layer.masksToBounds = true
//            contentView.alpha = 0
//        }
//
//        if !customBG {
//            contentView.backgroundColor = R.clr.sport.black_theme_light_over()
//        }
//        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let window = UIApplication.shared.keyWindow!
        bgView = getBGView()

        //檢查bgview是否已經匯入, 若沒有, 則動畫顯示
        if !isBGViewAdded() {
            window.addSubview(bgView!)
            UIView.animate(withDuration: 0.2) {
                self.bgView?.alpha = 1
            }
        } else {
            bgView?.alpha = 1
            window.bringSubview(toFront: bgView!)
        }

        //加入contentview, 並且動畫出現
        data.view.alpha = 0
        window.addSubview(data.view)

        //設置此變數, 在加入約束後才會自動更新frame
        data.view.translatesAutoresizingMaskIntoConstraints = false

        //置中約束
        //更好的寫法
        data.view.centerXAnchor.constraint(equalTo: window.centerXAnchor).isActive = true
//        data.view.centerYAnchor.constraint(equalTo: window.centerYAnchor).isActive = true
        data.view.centerYAnchor.constraint(equalTo: window.centerYAnchor, constant: data.offsetY).isActive = true

        data.view.widthAnchor.constraint(equalToConstant: data.width).isActive = true
        data.view.heightAnchor.constraint(equalToConstant: data.height).isActive = true

        UIView.animate(withDuration: 0.2) {
            data.view.alpha = 1
        }
    }


    //隱藏alert
    private func hide(_ data: AlertData) {

        UIView.animate(withDuration: 0.2, animations: {
            data.view.alpha = 0
        }, completion: { _ -> Void in
            data.view.removeFromSuperview()
        })

        if let index = alertChain.index(where: { $0.type == data.type }) {
            alertChain.remove(at: index)
        }

        //檢查目前的alert是否已經完全移除
        //是的話代表bgview要一起隱藏
        if alertChain.count == 0 {

            UIView.animate(withDuration: 0.2, animations: {
                self.bgView?.alpha = 0
            }, completion: { _ -> Void in
                if self.alertChain.count == 0 {
                    self.bgView?.removeFromSuperview()
                }
            })

        } else {
//            let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
            let window = UIApplication.shared.keyWindow!
            window.bringSubview(toFront: alertChain.last!.view)
        }
    }

    //檢查背景view是否已加入
    private func isBGViewAdded() -> Bool {
//        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let window = UIApplication.shared.keyWindow!
        for v in window.subviews where v.restorationIdentifier == bgViewID {
            return true
        }
        return false
    }

    //檢查某個type是否已經加入畫面
    private func isTypeAdded(_ type: String) -> Bool {
        for ac in alertChain where ac.type == type {
            return true
        }
        return false
    }

    //檢查某個type是否在畫面最上方
    private func isTypeTop(_ type: String) -> Bool {
        if let ac = alertChain.last, ac.type == type {
            return true
        }
        return false
    }

    //把某個type的view移動到最上方
    private func bringTypeToTop(_ type: String) {

        for i in 0..<alertChain.count {
            let ac = alertChain[i]
            if ac.type == type {
//                let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
                let window = UIApplication.shared.keyWindow!
                window.bringSubview(toFront: ac.view)
                alertChain.moveToLast(i)
                break
            }
        }
    }

    //從view取得對應的alertData
    private func getAlertData(_ byView: UIView) -> AlertData? {
        for alert in alertChain where alert.view == byView {
            return alert
        }
        return nil
    }

    //得到背景view
    private func getBGView() -> MGBaseView {
        if let view = bgView {
            return view
        } else {
//            let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
            let window = UIApplication.shared.keyWindow!
            let view = MGBaseView(frame: window.bounds)
            view.backgroundColor = UIColor.init(white: 0.1, alpha: 0.3)
            view.restorationIdentifier = bgViewID
            view.alpha = 0
            return view
        }
    }

    //點擊到了背景, 所以要取消alert
    func complete<T>(_ tView: T) where T : UIView {
        //點擊背後取消背景
        if let last = alertChain.last, last.outerCancel {
            hide(last)
        }
    }
}


extension MGAlertManager : MGAlertDelegate {
    //點擊了alert裡面的相關觸發性button
    public func alertBtnTap(_ v: MGAlertManager.MGAlertView, btn: MGAlertManager.AlertButton, obj: Any?) {
        //隱藏所有相關
        for am in alertChain {
            hide(am)
            MGThreadUtils.inMain(delay: 0.2) {
                self.alertHandler[am.type]?(btn, obj)
            }
        }
    }
}

//需要給準備顯示alert的view所繼承的委託
public protocol MGAlertViewDelegate {
    weak var alertDelegate: MGAlertDelegate? { get set }
}

public protocol MGAlertDelegate: class {
    func alertBtnTap(_ v: MGAlertManager.MGAlertView, btn: MGAlertManager.AlertButton, obj: Any?)
}





