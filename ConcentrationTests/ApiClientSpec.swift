//
//  ApiClientSpec.swift
//  Concentration
//
//  Created by Shaun Rowe on 16/08/2017.
//  Copyright © 2017 Shaun Rowe. All rights reserved.
//

import Quick
import Nimble
import Moya
@testable import Concentration

func url(_ route: TargetType) -> String {
    return route.baseURL.appendingPathComponent(route.path).absoluteString
}


class ApiClientSpec: QuickSpec {

    override func spec() {
        
        describe("Given an ApiClient instance") {
            context("When getPhotos is called without specifying a number") {
                let client = ApiClient(withStubClosure: MoyaProvider<FiveHundredPx>.immediatelyStub)
                it("Then it should return 6 random and unique Photo models") {
                
                    waitUntil(timeout: 5.0) { done in
                    
                        client.getPhotos("kitten", next: { photos in
                            expect(photos).to(beAKindOf([Photo].self))
                            expect(photos.count).to(equal(6))
                            let set = Set<Photo>(photos)
                            expect(set.count).to(equal(6))
                        }, complete: {
                            done()
                        }, failure: { error in
                            fail("Request should not have failed")
                        })
                        
                    }
                    
                }
                
            }
            
            context("When getPhotos is called with a specified number") {
                let client = ApiClient(withStubClosure: MoyaProvider<FiveHundredPx>.immediatelyStub)
                it("Then it should return the correct number of random and unique Photo models") {
                    
                    waitUntil(timeout: 5.0) { done in
                        
                        client.getPhotos("kitten", count: 8, next: { photos in
                            expect(photos).to(beAKindOf([Photo].self))
                            expect(photos.count).to(equal(8))
                            let set = Set<Photo>(photos)
                            expect(set.count).to(equal(8))
                        }, complete: {
                            done()
                        }, failure: { error in
                            fail("Request should not have failed")
                        })
                        
                    }
                    
                }
                
            }
            
            context("When getPhotos is called") {
                let client = ApiClient(withFailureClosure: { (target: FiveHundredPx) -> Endpoint<FiveHundredPx> in
                    return Endpoint<FiveHundredPx>(url: url(target), sampleResponseClosure: { .networkResponse(400, "".data(using: .utf8)!) })
                })
                context("And the request fails") {
                    it("Then the failure closure should be called") {
                        waitUntil(timeout: 5.0) { done in
                            
                            client.getPhotos("kitten", next: { photos in
                                fail("The request should have failed")
                            }, complete: { 
                                fail("The request should have failed")
                            }, failure: { error in
                                expect(error).to(beAnInstanceOf(MoyaError.self))
                                done()
                            })
                            
                        }
                    }
                }
            }
            
        }
        
    }
    
}
