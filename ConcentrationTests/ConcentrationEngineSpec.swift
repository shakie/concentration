//
//  ConcentrationEngineSpec.swift
//  Concentration
//
//  Created by Shaun Rowe on 14/08/2017.
//  Copyright © 2017 Shaun Rowe. All rights reserved.
//

import Foundation
import Quick
import Nimble
import Moya
import RxTest
import RxBlocking
import RxNimble
import RxSwiftExt
import RxCocoa
@testable import Concentration

class ConcentrationEngineSpec: QuickSpec {
 
    override func spec() {
        
        let client = ApiClient(withStubClosure: MoyaProvider<FiveHundredPx>.immediatelyStub)
        let scheduler = TestScheduler(initialClock: 0)
        var observer: TestableObserver<GameEvent>!
        var engine: ConcentrationEngine!
        
        describe("Given a ConcentrationEngine") {
            
            context("When prepareGame is called") {
                beforeEach {
                    observer = scheduler.createObserver(GameEvent.self)
                    engine = ConcentrationEngine(client)
                    engine.events.subscribe(observer)
                    engine.prepareGame(1)
                }
                
                it("Then the events subject emits GameEvent.loaded") {
                    expect(observer.events[0].value.element!) == GameEvent.loaded
                }
                
            }
            
            
            context("When startGame is called") {
                beforeEach {
                    observer = scheduler.createObserver(GameEvent.self)
                    engine = ConcentrationEngine(client)
                    engine.events.subscribe(observer)
                    engine.prepareGame(1)
                    engine.startGame()
                }
                
                it("Then the timer is started") {
                    expect(engine.elapsed).to(beGreaterThan(-1))
                }
                
                it("Then the photos are loaded from the 500px API") {
                    expect(engine.photos.count).to(equal(12))
                }
                
                it("Then the playing flag is set to true") {
                    expect(engine.playing).to(beTrue())
                }
                
                it("Then the events subject emits GameEvent.start") {
                    expect(observer.events[1].value.element!) == GameEvent.start
                }
                
            }
            
            context("When stopGame is called") {
                
                beforeEach {
                    observer = scheduler.createObserver(GameEvent.self)
                    engine = ConcentrationEngine(client)
                    engine.events.subscribe(observer)
                    engine.prepareGame(1)
                    engine.startGame()
                    engine.stopGame()
                }
                
                it("Then playing flag is set to false") {
                    expect(engine.playing).to(beFalse())
                }
                
                it("Then the events subject emits GameEvent.end") {
                    expect(observer.events[2].value.element!) == GameEvent.end(-1.0)
                }
            }

            context("When comparing two Photo models") {
                
                beforeEach {
                    engine = ConcentrationEngine(client)
                }
                
                context("And the two photos are the same") {
                    let photo1 = Photo("12345", imageUrl: "http://url.com/img.jpg")
                    let photo2 = Photo("12345", imageUrl: "http://url.com/img.jpg")
                    
                    it("Then isMatch will return true") {
                        expect{engine.isMatch(photo1, photo2)}.to(equal(true))
                    }
                }
                
                context("And the two photos are not the same") {
                    let photo1 = Photo("12345", imageUrl: "http://url.com/img.jpg")
                    let photo2 = Photo("54321", imageUrl: "http://url.com/img2.jpg")
                    
                    it("Then isMatch will return false") {
                        expect{engine.isMatch(photo1, photo2)}.to(equal(false))
                    }
                }
                
            }
            
        }
        
    }
    
}
