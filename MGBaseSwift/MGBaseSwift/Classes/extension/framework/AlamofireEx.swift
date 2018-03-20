//
//  AlamofireEx.swift
//  mgbaseproject
//
//  Created by Magical Water on 2018/1/30.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireImage

//Alamofire 相關擴展
//目的在於 網路 request 禁止快取
extension Alamofire.SessionManager {

    func requestWithoutCache(
        _ url: URLConvertible, method: HTTPMethod = .get,
        parameters: Parameters? = nil, encoding: ParameterEncoding = URLEncoding.default,
        headers: HTTPHeaders? = nil
        ) -> DataRequest {
            do {
                var urlRequest = try URLRequest(url: url, method: method, headers: headers)
                urlRequest.cachePolicy = .reloadIgnoringCacheData // <<== Cache disabled
                let encodedURLRequest = try encoding.encode(urlRequest, with: parameters)
                return request(encodedURLRequest)
            } catch {
                print(error)
                return request(URLRequest(url: URL(string: "http://example.com/wrong_request")!))
            }
    }

    //使用上傳檔案, 並且等待檔案上傳好
    func uploadData(_ url: URL, method: HTTPMethod,
                    data: [String:Any], param: [String:String],
                    header: HTTPHeaders) -> SessionManager.MultipartFormDataEncodingResult {

        let semaphore = DispatchSemaphore(value: 0)
        var result: SessionManager.MultipartFormDataEncodingResult!
        upload(multipartFormData: { multipartFormData in

            //先上傳檔案
            for (k,v) in data {


                if let data = v as? Data {
                    multipartFormData.append(data, withName: k,fileName: "file.jpg", mimeType: "image/jpg")
                } else if let img = v as? UIImage {
                    let jpegData = UIImageJPEGRepresentation(img, 1.0)!
                    multipartFormData.append(jpegData, withName: k,fileName: "file.jpg", mimeType: "image/jpg")
                } else if let string = v as? String, let data = string.data(using: String.Encoding.utf8) {
                    multipartFormData.append(data, withName: k)
                } else if let url = v as? URL {
                    multipartFormData.append(url, withName: k)
                }
            }

            //接著上傳post參數
            for (k,v) in param {
                if let data = v.data(using: String.Encoding.utf8) {
                    multipartFormData.append(data, withName: k)
                }
            }

        }, usingThreshold: UInt64.init(),
           to: url,
           method: method,
           headers: header) { encodingResult in
            result = encodingResult
            semaphore.signal()
        }

        _ = semaphore.wait(timeout: DispatchTime.distantFuture)

        return result
    }

}


//目的 - request 的同步需求
extension DataRequest {


    //同步等待資料返回
    public func response<T: DataResponseSerializerProtocol>(responseSerializer: T) -> DataResponse<T.SerializedObject> {
        let semaphore = DispatchSemaphore(value: 0)
        var result: DataResponse<T.SerializedObject>!
        self.response(queue: DispatchQueue.global(qos: .default), responseSerializer: responseSerializer) { response in
            result = response
            semaphore.signal()
        }
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)

        return result
    }


    //同步等待字串資料返回
    public func responseString(_ encoding: String.Encoding? = nil) -> DataResponse<String> {
        return response(responseSerializer: DataRequest.stringResponseSerializer(encoding: encoding))
    }



   //同步等待圖片返回
    public func responseImage(_ scale: CGFloat = 1) -> DataResponse<Image> {
        let semaphore = DispatchSemaphore(value: 0)
        var result: DataResponse<Image>!
        self.responseImage(imageScale: scale, inflateResponseImage: true, queue: DispatchQueue.global(qos: .default)) { responseImage in
            result = responseImage
            semaphore.signal()
        }
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)

        return result
    }


    //同步等待資料返回
    public func responseData() -> DefaultDataResponse {
        let semaphore = DispatchSemaphore(value: 0)
        var result: DefaultDataResponse!
        self.response { responseData in
            result = responseData
            semaphore.signal()
        }
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)

        return result
    }



}








