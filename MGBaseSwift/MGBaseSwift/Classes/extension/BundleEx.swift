//
//  BundleEx.swift
//  MGBaseProject
//
//  Created by Magical Water on 2018/2/20.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation

extension Bundle {

    //不可讓其他專案調用, 所以不是public
    static internal var project: Bundle {
        get { return Bundle(for: MGBaseProjectClass.self) }
    }

    //可讓其他專案調用, 傳入某個class, 藉由此class所屬的專案獲得專案的Bundle
    public static func getProjectBundle(_ byClass: AnyClass) -> Bundle {
        return Bundle(for: byClass)
    }
}


//此類無任何作用, 單純方便獲取到此專案的Bundle
class MGBaseProjectClass {}
