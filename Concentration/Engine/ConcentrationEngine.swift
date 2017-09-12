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

enum GameEvent: Equatable {
    case loaded
    case start
    case disable
    case enable
    case end(TimeInterval)
    case hide([Photo])
    case error(MoyaError)
    
    // Equatable, mainly used for unit testing to ensure that the PublishSubject emits the correct events
    static func ==(lhs: GameEvent, rhs: GameEvent) -> Bool{
        switch(lhs, rhs) {
        case (.end, .end):
            return true
        case (let .hide(photos1), let .hide(photos2)):
            return photos1 == photos2
        case (.start, .start):
            return true
        case (.loaded, .loaded):
            return true
        case (let .error(error1), let .error(error2)):
            return error1.errorDescription == error2.errorDescription
        case (.disable, .disable), (.enable, .enable):
            return true
        default:
            return false
        }
    }
}

class ConcentrationEngine {
    
    let client: ApiClient
    let events = PublishSubject<GameEvent>()
    
    init(_ client: ApiClient) {
        self.client = client
    }
    
    var difficulty = 1 //1 = easy, 2 = normal, 3 = hard
    var difficultyPretty: String {
        get {
            return difficulty == 1 ? "Easy" : (difficulty == 2 ? "Medium" : "Hard")
        }
    }
    
    var photos: [Photo] = [Photo]()
    private var revealedPhotos: [Photo] = [Photo]()
    
    private var startTime: Date?
    var elapsed: TimeInterval {
        get {
            guard let start = startTime else {
                return -1
            }
            return Date().timeIntervalSince(start)
        }
    }
    
    func prepareGame(_ difficulty: Int) { //Setup the game emitting the event when we've loaded the kittens
        self.difficulty = difficulty
        fetchKittens()
    }
    
    func startGame() { //Start a new game
        startTime = Date()
        events.onNext(.start)
    }
    
    func stopGame() { //Stop the game an emit the time
        events.onNext(.end(elapsed))
        events.onCompleted()
    }
    
    func resetGame() { //Reset the game state
        startTime = nil
        revealedPhotos.removeAll()
        photos.removeAll()
        fetchKittens()
    }
    
    func selectPhoto(_ photo: Photo?) { //Process the selected photo
        guard let photo = photo else { return }

        if self.revealedPhotos.count % 2 == 0 { //There are an even number of revealed photos so this must be an unmatched Photo
            revealedPhotos.append(photo)
        } else {
            events.onNext(.disable)
            guard let currentPhoto = self.revealedPhotos.last else { return }
            if !isMatch(photo, currentPhoto) { //It's not a match so hide the kittens
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.75) { [weak self] in
                    let photo2 = self?.revealedPhotos.removeLast()
                    self?.events.onNext(.hide([photo, photo2!]))
                    self?.events.onNext(.enable)
                }
            } else {
                revealedPhotos.append(photo)
                events.onNext(.enable)
            }
        }
        
        if revealedPhotos.count == photos.count { //All the photos are matched so let's stop the game
            stopGame()
        }
    }
    
    func isMatch(_ photo1: Photo, _ photo2: Photo) -> Bool {
        return photo1.match(photo2);
    }
    
    func indexForPhoto(_ photo: Photo) -> Int? { //Get the array position for the Photo
        for i in 0...photos.count-1 {
            if photos[i] == photo {
                return i
            }
        }
        return nil
    }
    
    private func fetchKittens() { //Gets me some cute kittens
        loadPhotos({ [weak self] in
            self?.events.onNext(.loaded)
        }) { [weak self] error in
            self?.events.onNext(.error(error))
        }
    }
    
    private func loadPhotos(_ complete: @escaping () -> Void, failure: @escaping (MoyaError) -> Void) {
        let count = self.difficulty == 1 ? 6 : (difficulty == 2 ? 8 : 10) //Set the number of photos to return based on the difficulty
        client.getPhotos("kitten", count: count, next: { [weak self] photos in
            var duped = [Photo]()
            for photo in photos {
                duped.append(contentsOf: [photo, Photo(photo.id, imageUrl: photo.imageUrl)])
            }
            self?.photos = duped.randomised
        }, complete: {
            complete()
        }) { error in
            failure(error)
        }
    }
    
}
