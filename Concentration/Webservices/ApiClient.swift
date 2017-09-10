//
//  ApiClient.swift
//  Concentration
//
//  Created by Shaun Rowe on 28/07/2017.
//  Copyright © 2017 Shaun Rowe. All rights reserved.
//

import Foundation
import Moya
import RxSwift

struct ApiClient {
    
    let provider: RxMoyaProvider<FiveHundredPx>
    let disposeBag = DisposeBag()
    
    init() {
        self.provider = RxMoyaProvider<FiveHundredPx>()
    }
    
    func getPhotos(_ search: String, count: Int = 6, next: @escaping ([Photo]) -> Void, complete: @escaping () -> Void, failure: @escaping (MoyaError) -> Void) {
        self.provider.request(.search(term: search))
            .filterSuccessfulStatusCodes()
            .map(to: Search.self).subscribe(
                onNext: { (response) -> Void in
                    var photos = response.photos
                    next(photos.shuffle().choose(count))
                },
                onError: { (error) -> Void in
                    guard let error = error as? MoyaError else {
                        return
                    }
                    failure(error)
                }, onCompleted: {
                    complete()
                }
        ).disposed(by: self.disposeBag)
    }
    
    //
    //For testing
    init(withStubClosure closure: @escaping MoyaProvider<FiveHundredPx>.StubClosure) {
        self.provider = RxMoyaProvider<FiveHundredPx>(stubClosure: closure)
    }
    
    init(withFailureClosure closure: @escaping (_ target: FiveHundredPx) -> Endpoint<FiveHundredPx>) {
        self.provider = RxMoyaProvider<FiveHundredPx>(endpointClosure: closure, stubClosure: MoyaProvider.immediatelyStub)
    }
    
}

extension Array {

    var shuffled: Array {
        var elements = self
        return elements.shuffle()
    }

    @discardableResult
    mutating func shuffle() -> Array {
        indices.dropLast().forEach {
            guard case let index = Int(arc4random_uniform(UInt32(count - $0))) + $0, index != $0 else { return }
            swap(&self[$0], &self[index])
        }
        return self
    }

    func choose(_ n: Int) -> Array { return Array(shuffled.prefix(n)) }
}
