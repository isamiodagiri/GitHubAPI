//
//  ApiClient.swift
//  GitHubAPIForRxSwift
//
//  Created by Isami Odagiri on 2020/09/14.
//  Copyright © 2020 Isami Odagiri. All rights reserved.
//

import UIKit
import Alamofire
import RxAlamofire
import ObjectMapper
import RxSwift

class ApiCliant {
    private static let successRange = 200..<400
    private static let contentType = ["application/json"]

    static func call<T, V>(_ request: T, _ disposeBag: DisposeBag,
                           onNext: @escaping (V) -> Void, onError: @escaping (Error) -> Void)
        where T : BaseRequestProtocol, V == T.ResponseType, T.ResponseType : Mappable {

            _ = observe(request)
                .subscribe(onSuccess: { onNext($0)},
                           onError: { onError($0) })
                .disposed(by: disposeBag)
    }

    private static func observe<T, V>(_ request: T) -> Single<V>
       where T: BaseRequestProtocol, V: Mappable, T.ResponseType == V {

          return Single<V>.create { observer in
                let calling = callForJson(request) { response in
                      switch response {
                         case .success(let result): observer(.success(result as! V))
                         case .failure(let error): observer(.error(error))
                      }
                }

                return Disposables.create() { calling.cancel() }
       }
    }

    private static func callForJson<T, V>(_ request: T, completion: @escaping (ApiResult) -> Void) -> DataRequest
        where T: BaseRequestProtocol, V: Mappable, T.ResponseType == V {

            return customAlamofire(request).responseJSON { response in
                    switch response.result {
                    case .success(let result): completion(.success(mappingJson(request, result as! Parameters)))
                    case .failure(let error): completion(.failure(error))
                    }

            }
    }

    private static func customAlamofire<T>(_ request: T) -> DataRequest
        where T: BaseRequestProtocol {

            return AF
                .request(request)
                .validate(statusCode: successRange)
                .validate(contentType: contentType)
    }

    private static func mappingJson<T, V>(_ request: T, _ result: Parameters) -> V
        where T: BaseRequestProtocol, V: Mappable, T.ResponseType == V {

            return Mapper<V>().map(JSON: result)!
    }
}

/* APIレスポンスの結果分岐
 success: ObjectMapperに対応したレスポンスモデルを返す
 failure: サーバーからのエラーログを返す
 */
// MARK: - ResultType
enum ApiResult {
    case success(Mappable)
    case failure(Error)
}
