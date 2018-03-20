//
//  RSwiftEx.swift
//  MGBaseProject
//
//  Created by Magical Water on 2018/2/20.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation
//import Rswift


//對於RSwift使用多國語言字串的擴展, 傳入語系專屬code, 獲取到當前專案下的多國語言對應字串
//皆只能在當下專案使用, 因此不public跟open
//extension StringResource {
//
//    func locale(_ code: MGLocaleManager.LocaleCode = .base) -> String {
//        let path = Bundle.project.path(forResource: code.rawValue, ofType: "lproj")
//        if let p = path {
//            let bundle = Bundle(path: p)
//            return NSLocalizedString(key, tableName: tableName, bundle: bundle!, value: "", comment: "")
//        } else {
//            return NSLocalizedString(key, comment: "")
//        }
//    }
//
//    //直接轉為NSString
//    func localeNS(_ code: MGLocaleManager.LocaleCode = .base) -> NSString {
//        return locale(code) as NSString
//    }
//
//}

