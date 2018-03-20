//
//  MGVCManager.swift
//  mgbaseproject
//
//  Created by Magical Water on 2018/1/30.
//  Copyright © 2018年 Magical Water. All rights reserved.
//


import Foundation
import UIKit

//因為有時候跳轉 Page 並不用網路 request
//所以將兩者分開
public typealias MGPageData = (rt: MGUrlRequest?, pi: MGPageInfo)

class MGFgtManager {

    //因為 ios 跟 android 不一樣, 沒有 FragmentManager 記錄下已存在的 碎片頁面
    //因此需要自行儲存
    typealias VCBuilder = (board: UIStoryboard, tag: String, vc: UIViewController)

    //最基本的fgt跳轉, 每次將歷史紀錄清除後都需要回到地俗稱首頁的頁面
    private var rootPage: MGPageData!

    //儲存所有的頁面跳轉歷史
    var totalHistory: [MGPageData] = []

    //針對每種類型頁面的 history, key 為containerId, value 為 MGPageData
    var pageHistory: [String:[MGPageData]] = [:]

    //跳轉時的相關回調
    weak var delegate: MGVCManagerDelegate?

    //發送api相關回調
    var requestHelper: MGBaseApiHelper = MGBaseApiHelper()

    /*
     儲存 某個 layout 裡面裝載的最上層 fgt
     不一定是顯示狀態, 但一定是最上層
     pageInfo 是此layout id正在顯示的 vc
     讓外部已註冊的方式加入
     */
    private var containerMap: [String:VCBuilder] = [:]


    //最外層的vc, 所有的跳轉行為皆在此vc下
    private weak var baseContainerVC: UIViewController! = nil


    init() {
        requestHelper.delegate = self
    }


    //設定所有container view的上層view, 所有的container都須包含在此container裡面
    func setBaseCotainer(_ base: UIViewController) {
        baseContainerVC = base
    }


    //設定最底層 page
    func setRootPage(_ page: MGPageData) {
        self.rootPage = page
    }

    //回傳最上方的page是否處理back的動作
    func backAction() -> Bool {
        //先檢查是否擁有頁面可以檢查是否處理
        if totalHistory.count == 0  { return false }

        let last = totalHistory.last!

        if let vcBuilder = containerMap[last.pi.containerId],
            let backHandler = vcBuilder.vc as? MGVCBackHelper {
            return backHandler.backPress()
        } else {
            return false
        }
    }

    //回上一個 fgt, 參數回到退多少頁
    //回傳可否回上一頁, 例如: 如果當頁已經是首頁, 即無法回上頁
    func backPage(_ back: Int = 1) -> Bool {

        //先檢查是否擁有頁面可以跳轉
        if totalHistory.isEmpty { return false }


        var pageData: MGPageData? = nil

        //檢查是否還擁有頁面可回退, 如果沒有的話直接跳回首頁
        func isNeedToRoot() -> Bool {
            if totalHistory.isEmpty {
                toRootPage()
                return true
            }
            return false
        }

        //因為是退回上一頁, 所以我們要拿上一頁的資料進行跳轉
        //因此當回退一頁的時候, 就要刪除兩頁
        for i in 0..<(back+1) {

            if isNeedToRoot() { return true }

            pageData = totalHistory.removeLast()

            //藉由刪除 total 最後一筆, 我們就能知道container id是多少
            //並且 pageHistory 內此 container id的最後面一筆就是我們要刪除的
            //因此直接刪除即可

            _ = pageHistory[pageData!.pi.containerId]?.removeLast()

            if (i < back) {
                hideFgt(pageData!.pi.pageTag)
            }
        }

        pageJump(pageData!)
        return true
    }

    //需要透過網路要求資料, 再跳頁面
    func pageJump(_ request: MGUrlRequest) {
        requestHelper.sendRequest(request)
    }

    //不需要透過網路要求資料, 直接跳頁面
    func pageJump(_ page: MGPageInfo) {
        let pageData = MGPageData(rt: nil, pi: page)
        pageJump( pageData )
    }


    //回到首頁
    func toRootPage() {
        if let root = rootPage { pageJump(root) }
    }

    //直接隱藏某個 container Fragment, 並且將之從歷史紀錄移除
    func hideFgt(_ fgtTag: String) {

        //尋找此tag目前是否仍然顯示中, 如果是的話則移除
        let index = containerMap.index { key, value in
            return value.tag == fgtTag
        }
        let findVC = containerMap[index!]
//        findVC.value.vc.willMove(toParentViewController: nil)
//        findVC.value.vc.removeFromParentViewController()
        findVC.value.vc.view.isHidden = true

        totalHistory = totalHistory.filter { pageData in
            pageData.pi.pageTag != fgtTag
        }

        var replaceContainerID: String? = nil
        var replacePageDatas: [MGPageData]? = nil

        pageHistory.forEach{ container, pageDatas in
            let isContain = pageDatas.contains { pageData in
                return fgtTag == pageData.pi.pageTag
            }
            if isContain {
                replacePageDatas = pageDatas.filter { pageData in
                    return fgtTag != pageData.pi.pageTag
                }
                replaceContainerID = container
            }
        }

        if let container = replaceContainerID, let data = replacePageDatas {
            pageHistory[container] = data
        }
    }

    /*****************************外部接口 以上**********************************/

    /*
     功能: 跳轉頁面
     1. 檢查資料是否過期
     2. 頁面是否已有相同的 Fgt 顯示當中
        - 無 - 直接進行顯示
        - 有 - 直接送入 data
     */
    private func pageJump(_ data: MGPageData) {
        let request = data.rt
        if let rt = request, rt.isExpired {
            //資料過期, 需要重新發起網路request
            pageJump(rt)
            return
        }

        let pageInfo = data.pi

        //檢查設定, 若為節點則清除以前的歷史紀錄
        //若不加入歷史紀錄則不加入
        if (pageInfo.isChainNode) {
            totalHistory.removeAll()
            pageHistory.removeAll()
        }

        //檢查layout id上是否已有vc顯示中
        //有 -> 檢查 vc 是否相同
        //      - 是 -> 將 data 傳入, 不做其餘動作
        //      - 否 -> 初始化 vc 並替換
        //無 -> 直接 add vc
        let vcBuilder = getVCBuilder(pageInfo.containerId)

        if let vcBuilder = vcBuilder {

            //確認已經存在的vcBuilder是否與即將跳轉的vc相同
            if vcBuilder.tag == pageInfo.pageTag {
                //相同, 代表vc已存在, 直接傳入資料到 pageData
                vcBuilder.vc.view.isHidden = false
                putPageDataIfNeed(vcBuilder, pageData: data)

                //發送頁面切換通知
                sendPageChangedCallback(data)
                
            } else {
                //不同, 需要替換掉已存在的vcBuilder
                let toVC: VCBuilder
                if let vcTag = pageInfo.pageIdientfier {
                    //需要針對storyBoard裡面某個vc作初始化, 因此需要那個vc的identifier
                    toVC = VCBuilder(board: pageInfo.page, tag: pageInfo.pageTag, vc: pageInfo.page.instantiateViewController(withIdentifier: vcTag))
                } else {
                    toVC = VCBuilder(board: pageInfo.page, tag: pageInfo.pageTag, vc: pageInfo.page.instantiateInitialViewController()!)
                }

                //將已有的 fgt 做置換, 若存在歷史的話
                let fgtArray = pageHistory[pageInfo.containerId] ?? []

                pageHistory[pageInfo.containerId] = fgtArray.filter {
                    $0.pi.pageTag != pageInfo.pageTag
                }

                totalHistory = totalHistory.filter {
                    $0.pi.pageTag != pageInfo.pageTag
                }

                pageHistory[pageInfo.containerId]!.append(data)
                totalHistory.append(data)

                //傳入頁面資料給新的vc
                putPageDataIfNeed(toVC, pageData: data)

                changeVC(pageInfo, nowVC: vcBuilder, toVC: toVC)

                //發送頁面切換通知
                sendPageChangedCallback(data)

                containerMap[pageInfo.containerId] = toVC
            }

        } else {

            let toVC: VCBuilder
            if let vcTag = pageInfo.pageIdientfier {
                //需要針對storyBoard裡面某個vc作初始化, 因此需要那個vc的identifier
                toVC = VCBuilder(board: pageInfo.page, tag: pageInfo.pageTag, vc: pageInfo.page.instantiateViewController(withIdentifier: vcTag))
            } else {
                toVC = VCBuilder(board: pageInfo.page, tag: pageInfo.pageTag, vc: pageInfo.page.instantiateInitialViewController()!)
            }

            //傳入頁面資料給新的vc
            putPageDataIfNeed(toVC, pageData: data)

            changeVC(pageInfo, nowVC: nil, toVC: toVC)

            //發送頁面切換通知
            sendPageChangedCallback(data)

            pageHistory[pageInfo.containerId] = [data]
            totalHistory.append(data)
            containerMap[pageInfo.containerId] = toVC
        }



    }


    //將 pageData 傳入 vc 中, 假如有需要
    private func putPageDataIfNeed(_ vcBuilder: VCBuilder, pageData: MGPageData) {
        if let vcDataHelper = vcBuilder.vc as? MGFgtDataHelper {
            vcDataHelper.pageData(pageData, isFgtInit: false)
        }
    }

    //發送即將顯示通知
    private func sendDisplayActionIfNeed(_ vcBuilder: VCBuilder, status: Bool) {
        if let vcStatusHelper = vcBuilder.vc as? MGFgtStatusHelper {
            vcStatusHelper.willStatus(show: status)
        }
    }

    //發送頁面切換回調
    private func sendPageChangedCallback(_ pageData: MGPageData) {
        delegate?.fgtChange(pageData: pageData)
    }



    //得到要放到哪個vc下
    //如果container在第二層, 則所有父層的view都必須設定 restorationIdentifier 才會尋找往subView尋找
    private func getContainerView(_ inView: UIView, containerId: String) -> UIView? {
        if inView.restorationIdentifier ?? "" == containerId { return inView }
        else if inView.subviews.count == 0 { return nil }

        for v in inView.subviews {
            let identifier = v.restorationIdentifier
            if let id = identifier, let find = getContainerView(v, containerId: containerId) {
                return find
            }
        }
        return nil
    }


    //pageTag 為nil - 得到某個conatiner上面是否已經有vcBuilder存在
    private func getVCBuilder(_ containerId: String) -> VCBuilder? {
        if let vcBuilder = containerMap[containerId] {
            return vcBuilder
        }
        return nil
    }


    //切換vc顯示
    private func changeVC(_ pageInfo: MGPageInfo, nowVC: VCBuilder?, toVC: VCBuilder) {
        let containerView = getContainerView(baseContainerVC.view, containerId: pageInfo.containerId)

        guard let inView = containerView else {
            return
        }

        if let nowV = nowVC {
            //當前container有vc存在

            //先對舊vc呼叫隱藏動作通知, 假如有需要
            //再對新vc呼叫顯示動作通知, 假如有需要
            sendDisplayActionIfNeed(nowV, status: false)
            sendDisplayActionIfNeed(toVC, status: true)

            nowV.vc.willMove(toParentViewController: nil)
            baseContainerVC.addChildViewController(toVC.vc)
            toVC.vc.view.isHidden = false

            baseContainerVC.transition(
                from: nowV.vc,
                to: toVC.vc,
                duration: 0.2,
                options: UIViewAnimationOptions.transitionCrossDissolve,
                animations: nil,
                completion: { _ in
                    nowV.vc.removeFromParentViewController()
                    toVC.vc.didMove(toParentViewController: self.baseContainerVC)
                    toVC.vc.view.frame = inView.bounds
            })
        } else if toVC.vc.parent == nil {
            //當前container無vc存在, 且此vc沒有parentVC存在(即尚未加入), 需要做加入的動作
            //此處代表toVC從來沒加入過, 第一次不呼叫狀態通知
            baseContainerVC.addChildViewController(toVC.vc)
            inView.addSubview(toVC.vc.view)
            toVC.vc.didMove(toParentViewController: baseContainerVC)

            toVC.vc.view.frame = inView.bounds
        }
    }
}

extension MGFgtManager : MGApiHelperDelegate {
    func response(_ request: MGUrlRequest, success: Bool, requestCode: Int) {
        let isHandler = delegate?.jumpResponse(request: request, requestCode: requestCode, success: success) ?? false
        if !isHandler {
            if success {
                let pageData = MGPageData(rt: request, pi: request.pageInfo!)
                pageJump(pageData)
            } else {
                MGToastUtils.show("發生錯誤")
            }
        }
    }

    func timesUp() {}
}

//跳轉頁面相關回調
protocol MGVCManagerDelegate : class {

    //跳轉頁面回調
    func fgtChange(pageData: MGPageData)

    //跳轉頁面包含撈取api, 得到response之後, 跳轉頁面之前回調
    //回傳代表是否攔截回調
    func jumpResponse(request: MGUrlRequest, requestCode: Int, success: Bool) -> Bool
}
