//
//  TestScheduler+record.swift
//  Concentration
//
//  Created by Shaun Rowe on 11/09/2017.
//  Copyright © 2017 Shaun Rowe. All rights reserved.
//

import Foundation
import RxTest
import RxSwift

extension TestScheduler {
    /// Creates a `TestableObserver` instance which immediately subscribes
    /// to the `source` and disposes the subscription at virtual time 100000.
    func record<O: ObservableConvertibleType>(_ source: O) -> TestableObserver<O.E> {
        let observer = self.createObserver(O.E.self)
        let disposable = source.asObservable().bind(to: observer)
        self.scheduleAt(100000) {
            disposable.dispose()
        }
        return observer
    }
}
