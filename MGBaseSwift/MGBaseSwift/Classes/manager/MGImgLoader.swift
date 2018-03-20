//
//  MGImgLoader.swift
//  mgbaseproject
//
//  Created by Magical Water on 2018/2/18.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

public class MGImgLoader {

    static public func load(_ imageView: UIImageView, url: URL) {
        imageView.kf.setImage(with: url)
    }

    public static func load(_ url: URL, handler: @escaping (UIImage?) -> Void) {
        KingfisherManager.shared.retrieveImage(
            with: url,
            options: nil,
            progressBlock: nil
        ) { (image, error, cacheType, imageURL) -> () in
            handler(image)
        }
    }
}
