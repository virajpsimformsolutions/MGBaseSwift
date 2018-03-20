//
//  MGFgtStatusHelper.swift
//  mgbaseproject
//
//  Created by Magical Water on 2018/2/5.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation

//幫助 VC 在顯示, 隱藏時的調用
public protocol MGFgtStatusHelper {
    //即將顯示或隱藏
    func willStatus(show: Bool)

    //已經顯示或隱藏
    func didStatus(show: Bool)
}
