//
//  ConcentrationEngine.swift
//  Concentration
//
//  Created by Shaun Rowe on 16/08/2017.
//  Copyright © 2017 Shaun Rowe. All rights reserved.
//

import Foundation
import Moya
import RxSwift

enum GameEvent {
    case start
    case end(TimeInterval)
    case show([Photo])
    case hide([Photo])
}

class ConcentrationEngine {
    
    let client: ApiClient
    let events = PublishSubject<GameEvent>()
    
    init(_ client: ApiClient) {
        self.client = client
    }
    
    var difficulty = 1 //1 = easy, 2 = normal, 3 = hard
    var players: [Player] = [Player]()
    var photos: [Photo] = [Photo]()
    var playing = false
    
    private var turnedPhotos: [Photo] = [Photo]()
    
    private var startTime: Date?
    var elapsed: TimeInterval {
        get {
            guard let start = startTime else {
                return -1
            }
            return Date().timeIntervalSince(start)
        }
    }
    
    func startGame(_ level: Int, failure: @escaping (MoyaError) -> Void) {
        difficulty = level
        startTime = Date.init()
        playing = true
        loadPhotos({ [unowned self] in
            self.events.onNext(.start)
        }) { (error) in
            failure(error)
        }
    }
    
    func stopGame() {
        startTime = nil
        playing = false
        photos.removeAll()
        turnedPhotos.removeAll()
        events.onNext(.end(elapsed))
    }
    
    func selectPhoto(_ photo: Photo?) {
        guard let photo = photo else { return }
        
        events.onNext(.show([photo]))
        if self.turnedPhotos.count % 2 != 0 {
            turnedPhotos.append(photo)
        } else {
            let currentPhoto = self.photos.last
            if photo != currentPhoto {
                turnedPhotos.append(photo)
            } else {
                events.onNext(.hide([photo, self.turnedPhotos.removeLast()]))
            }
        }
        
        if turnedPhotos.count == photos.count {
            stopGame()
        }
    }
    
    func isMatch(photo1: Photo, photo2: Photo) -> Bool {
        return photo1 == photo2;
    }
    
    func indexForPhoto(_ photo: Photo) -> Int? {
        for i in 0...photos.count-1 {
            if photos[i] == photo {
                return i
            }
        }
        return nil
    }
    
    func photoAtIndex(_ index: Int) -> Photo? {
        if index < photos.count {
            return photos[index]
        }
        
        return nil
    }
    
    func loadPhotos(_ complete: @escaping () -> Void, failure: @escaping (MoyaError) -> Void) {
        let count = self.difficulty == 1 ? 6 : (difficulty == 2 ? 8 : 10)
        client.getPhotos("kitten", count: count, next: { [unowned self] photos in
            self.photos = photos
            }, complete: {
                complete()
        }) { error in
            failure(error)
        }
    }
    
}
