//
//  ApiClient.swift
//  GitHubAPIForRxSwift
//
//  Created by Isami Odagiri on 2020/09/14.
//  Copyright © 2020 Isami Odagiri. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper
import RxSwift

class ApiCliant {
    private static let successRange = 200..<500
    private static let contentType = ["application/json"]
    
    static func call<T, V>(_ request: T, _ disposeBag: DisposeBag,
                           onSuccess: @escaping (V) -> Void, onError: @escaping (Error) -> Void)
        where T : BaseRequestProtocol, V == T.ResponseType, T.ResponseType : Mappable {
            _ = observe(request)
                .subscribe(onSuccess: { onSuccess($0)},
                           onError: { onError($0) })
                .disposed(by: disposeBag)
    }
    
    private static func observe<T, V>(_ request: T) -> Single<V>
       where T: BaseRequestProtocol, V: Mappable, T.ResponseType == V {

          return Single<V>.create { observer in
            let calling = callForJson(request) { response, error  in
                    if let response = response {
                        observer(.success(response))
                    }
                    
                    if let error = error {
                        observer(.error(error))
                    }
                }
                return Disposables.create() { calling.cancel() }
       }
    }
    
    private static func callForJson<T, V>(_ request: T, completion: @escaping (V?, Error?) -> Void) -> DataRequest
        where T: BaseRequestProtocol, V: Mappable, T.ResponseType == V {

            return customAlamofire(request).responseJSON { response in
                    switch response.result {
                    case .success(let result): completion(mappingJson(request, result), nil)
                    case .failure(let error): completion(nil, error)
                    }
            }
    }
    
    private static func mappingJson<T, V>(_ request: T, _ result: Any) -> V?
        where T: BaseRequestProtocol, V: Mappable, T.ResponseType == V {
            return Mapper<V>().map(JSONObject: result)
    }
    
    static func callToArray<T, V>(_ request: T, _ disposeBag: DisposeBag,
                           onSuccess: @escaping ([V]) -> Void, onError: @escaping (Error) -> Void)
        where T : BaseRequestProtocol, V == T.ResponseType, T.ResponseType : Mappable {

            _ = observeToArray(request)
                .subscribe(onSuccess: { onSuccess($0)},
                           onError: { onError($0) })
                .disposed(by: disposeBag)
    }
    
    private static func observeToArray<T, V>(_ request: T) -> Single<[V]>
       where T: BaseRequestProtocol, V: Mappable, T.ResponseType == V {

          return Single<[V]>.create { observer in
            let calling = callForJsonToArray(request) { response, error  in
                    if let response = response {
                        observer(.success(response))
                    }
                    
                    if let error = error {
                        observer(.error(error))
                    }
                }
                return Disposables.create() { calling.cancel() }
       }
    }

    private static func callForJsonToArray<T, V>(_ request: T, completion: @escaping ([V]?, Error?) -> Void) -> DataRequest
        where T: BaseRequestProtocol, V: Mappable, T.ResponseType == V {

            return customAlamofire(request).responseJSON { response in
                    switch response.result {
                    case .success(let result): completion(mappingJsonToArray(request, result), nil)
                    case .failure(let error): completion(nil, error)
                    }
            }
    }
    
    private static func mappingJsonToArray<T, V>(_ request: T, _ result: Any) -> [V]?
        where T: BaseRequestProtocol, V: Mappable, T.ResponseType == V {
            return Mapper<V>().mapArray(JSONObject: result)
    }

    private static func customAlamofire<T>(_ request: T) -> DataRequest
        where T: BaseRequestProtocol {

            return AF
                .request(request)
                .validate(statusCode: successRange)
                .validate(contentType: contentType)
    }
}
