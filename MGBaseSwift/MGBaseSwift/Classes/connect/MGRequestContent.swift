//
//  MGRequestContent.swift
//  mgbaseproject
//
//  Created by Magical Water on 2018/1/30.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation

/*
 構件網路要求的內容,
 使用的連接類型 (GET, POST)
 連接的網址 (URL)
 CustomStringConvertible - 繼承此類別, 自定義 toString
 */
public class MGRequestContent: CustomStringConvertible {

    //自定義的 toString
    public var description: String {
        return "反序列化(\(String(describing: deserialize))), 連線(\(method)) - 位址: \(scheme)://\(host)\(path), 參數: \(paramSource)"
    }

    public var scheme: String // http 或者 https
    public var host: String //主機域名
    public var path: String //uri路徑
    public var method: Method //用什麼方式連接, GET 或 POST

    //要求頭
    public var headers: [String:String] = [:]

    //要求的參數
    public var params: [String:String] {
        get {
            if paramSource.isEmpty { return [:] }
            var l: [String:String] = [:]
            for (k,v) in paramSource {
                switch (v) {
                case is String:
                    l[k] = v as? String
                default:
                    let map = v as! [String:String]
                    for (num, innerV) in map {
                        l["\(k)[\(num)]"] = innerV
                    }
                }
            }
            return l
        }
    }

    //需要上傳的檔案
    public var uploads: [String:Any]? {
        get {
            if uploadSource.isEmpty { return nil }
            var l: [String:Any] = [:]
            for (k,v) in uploadSource {
                switch (v) {
                case is Dictionary<String, Any>:
                    let map = v as! [String:Any]
                    for (num, innerV) in map {
                        l["\(k)[\(num)]"] = innerV
                    }
                default:
                    l[k] = v
                }
            }
            return l
        }
    }

    //參數是否為 Json 格式
    public var paramIsJson: Bool = false

    //通常搭配資料庫lib, 是否從本地資料庫拉出相對應的 class 所儲存的資料
    public var locale: MGLocalCache = MGLocalCache() //本地的快取設定, 默認關閉

    //發起 request 時是否要快取
    public var network: Bool = true //網路的快取設定, 默認開啟

    public var deserialize: MGJsonDeserializeDelegate.Type? = nil  //需要反序列化的 class

    //這邊處存內部已有的 param key, 對應到已經加入多少個, 方便取出時加入陣列字串
    private var paramSource: [String:Any] = [:]

    //同 paramSource, 差別在於此參數專給 paramSource
    private var uploadSource: [String:Any] = [:]

    public init(_ scheme: MGRequestContent.Scheme,
         host: String,
         path: String,
         method: MGRequestContent.Method = MGRequestContent.Method.get) {
        self.scheme = scheme.rawValue
        self.host = host
        self.path = path
        self.method = method
    }

    public func setDeserialize(_ c: MGJsonDeserializeDelegate.Type) -> MGRequestContent {
        deserialize = c
        return self
    }

    public func setParamIsJson(_ isJson: Bool) -> MGRequestContent {
        self.paramIsJson = isJson
        return self
    }


    //取出 url
    public func getURL() -> URL? {
        let urlString = "\(scheme)://\(host)\(path)"
        return URL(string: urlString)
    }

    //加入參數
    public func addParam(_ key: String, value: String, array: Bool) -> MGRequestContent {
        if array {
            var innerArray: [String: Any] = paramSource[key] == nil ? [:] : paramSource[key]! as! [String: Any]
            innerArray["\(innerArray.count)"] = value
            paramSource[key] = innerArray
        } else {
            paramSource[key] = value
        }
        return self
    }

    //加入多個參數
    public func addParams(_ key: String, value: [String]) -> MGRequestContent {
        value.forEach { (v) in
            _ = addParam(key, value: v, array: true)
        }
        return self
    }


    //加入上傳的檔案
    public func addUpload(_ key: String, value: Any, array: Bool) -> MGRequestContent {
        if array {
            var innerArray: [String: Any] = uploadSource[key] == nil ? [:] : uploadSource[key]! as! [String: Any]
            innerArray["\(innerArray.count)"] = value
            uploadSource[key] = innerArray
        } else {
            uploadSource[key] = value
        }
        return self
    }

    //加入多個上傳的檔案
    public func addUploads(_ key: String, value: [Any]) -> MGRequestContent {
        value.forEach { (v) in
            _ = addUpload(key, value: v, array: true)
        }
        return self
    }

    //本地的快取設定
    public struct MGLocalCache {
        var load: Bool = false
        var save: Bool = false
    }

    //是 http 還是 https
    public enum Scheme: String {
        case http = "http"
        case https = "https"
    }

    //Requst Method
    public enum Method {
        case get
        case post
    }

}
