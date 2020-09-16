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

// MARK: - Base API Protocol
protocol BaseAPIProtocol {
    associatedtype ResponseType // レスポンスの型

    var method: HTTPMethod { get } // get,post,delete などなど
    var baseURL: URL { get } // APIの共通呼び出し元。 ex "https://~~~"
    var path: String { get } // リクエストごとのパス
    var headers: HTTPHeaders? { get } // ヘッダー情報
//    var decode: (Data) throws -> ResponseType { get } // デコードの仕方
}

extension BaseAPIProtocol {

    var baseURL: URL {
        return URL(string: UrlConfig.baseURL)!
    }

    var headers: HTTPHeaders? {
        return nil
    }

    var decode: (Data) throws -> ResponseType { // decoderはあとで用意するので注意
        return { try JSONDecoder.decoder.decode(ResponseType.self, from: $0) }
    }
}

// MARK: - BaseRequestProtocol
protocol BaseRequestProtocol: BaseAPIProtocol, URLRequestConvertible {
    var parameters: Parameters? { get }
    var encoding: URLEncoding { get }
}

extension BaseRequestProtocol {
    var encoding: URLEncoding {
        return URLEncoding.default
    }

//    func asURLRequest() throws -> URLRequest {
//        var urlRequest = URLRequest(url: baseURL.appendingPathComponent(path))
//        urlRequest.httpMethod = method.rawValue
//        urlRequest.headers = headers ?? HTTPHeaders()
//        urlRequest.timeoutInterval = TimeInterval(30)
//
//        if let params = parameters {
//            urlRequest = try encoding.encode(urlRequest, with: params)
//        }
//
//        return urlRequest
//    }

}



// MARK: - API Cliant
class APICliant {

    // MARK: Private Static Variables
    private static let successRange = 200..<400
    private static let contentType = ["application/json"]


    // MARK: Static Methods

    // 実際に呼び出すのはこれだけ。（rxを隠蔽化しているだけなので、observeでも大丈夫）
    static func call<T, V>(_ request: T, _ disposeBag: DisposeBag,
                           onNext: @escaping (V) -> Void, onError: @escaping (Error) -> Void)
        where T : BaseRequestProtocol, V == T.ResponseType, T.ResponseType : Mappable {

            _ = observe(request)
                .observeOn(MainScheduler.instance)
                .subscribe(onSuccess: { onNext($0)},
                           onError: { onError($0) })
                .disposed(by: disposeBag)
    }

    static func observe<T, V>(_ request: T) -> Single<V>
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

    // Alamofire呼び出し部分
    static func callForJson<T, V>(_ request: T, completion: @escaping (APIResult) -> Void) -> DataRequest
        where T: BaseRequestProtocol, V: Mappable, T.ResponseType == V {

            return customAlamofire(request).responseJSON { response in
                    switch response.result {
                    case .success(let result): completion(.success(mappingJson(request, result as! Parameters)))
                    case .failure(let error): completion(.failure(error))
                    }

            }
    }

    // Alamofireのメソッドのみ切り出した部分
    static func customAlamofire<T>(_ request: T) -> DataRequest
        where T: BaseRequestProtocol {

            return AF
                .request(request)
                .validate(statusCode: successRange)
                .validate(contentType: contentType)
    }
    /// Jsonをレスポンスモデルに mappingするメソッド
    static func mappingJson<T, V>(_ request: T, _ result: Parameters) -> V
        where T: BaseRequestProtocol, V: Mappable, T.ResponseType == V {

        // 必ずmappingされるので「！」を使用
        return Mapper<V>().map(JSON: result)!
    }
}

/* APIレスポンスの結果分岐

 success: ObjectMapperに対応したレスポンスモデルを返す
 failure: サーバーからのエラーログを返す

 */

// MARK: - ResultType
enum APIResult {
    case success(Mappable)
    case failure(Error)
}
