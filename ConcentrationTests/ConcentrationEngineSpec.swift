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
@testable import Concentration

class ConcentrationEngineSpec: QuickSpec {
 
    override func spec() {
        
        describe("Given a ConcentrationEngine") {
            
            let client = ApiClient(withStubClosure: MoyaProvider<FiveHundredPx>.immediatelyStub)
            let engine = ConcentrationEngine(client)
           
            context("When startGame is called") {
                engine.startGame(1) { error in
                }
                
                it("Then the timer is started") {
                    expect(engine.elapsed).to(beGreaterThan(-1))
                }
                
                it("Then the photos are loaded from the 500px API") {
                    expect(engine.photos.count).to(equal(6))
                }
                
                it("Then the playing flag is set to true") {
                    expect(engine.playing).to(beTrue())
                }
                
                it("Then the events subject emits GameEvents.start") {
                    let result = try! engine.events.toBlocking().first()
                    expect(result).to(equal(GameEvent.start))
                }
                
            }
            
            context("When comparing two Photo models") {
                
                context("And the two photos are the same") {
                    let photo1 = Photo("12345", image_url: "http://url.com/img.jpg")
                    let photo2 = Photo("12345", image_url: "http://url.com/img.jpg")
                    
                    it("Then isMatch will return true") {
                        expect{engine.isMatch(photo1: photo1, photo2: photo2)}.to(equal(true))
                    }
                }
                
                context("And the two photos are not the same") {
                    let photo1 = Photo("12345", image_url: "http://url.com/img.jpg")
                    let photo2 = Photo("54321", image_url: "http://url.com/img2.jpg")
                    
                    it("Then isMatch will return false") {
                        expect{engine.isMatch(photo1: photo1, photo2: photo2)}.to(equal(false))
                    }
                }
                
            }
            
        }
        
    }
    
}
