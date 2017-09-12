//
//  GameViewController.swift
//  Concentration
//
//  Created by Shaun Rowe on 15/08/2017.
//  Copyright © 2017 Shaun Rowe. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Kingfisher
import SVProgressHUD
import Moya
import RealmSwift

class GameViewController: UIViewController {
    
    let disposables = DisposeBag()
    let engine = ConcentrationEngine(ApiClient())
    
    @IBOutlet weak var buttonStart: UIButton!
    @IBOutlet weak var buttonStop: UIButton!
    @IBOutlet weak var buttonHome: UIButton!
    @IBOutlet weak var labelGameInfo: UILabel!
    @IBOutlet weak var labelTimer: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var difficulty: Int?
    var difficultyLevel: Int {
        get {
            guard let level = difficulty else {
                return 1 //Default to easy if for some reason we don't have a difficulty set
            }
            return level
        }
    }
    var playTimer: Timer?
    var photos: Observable<[Photo]>?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = true
        resetGame()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        SVProgressHUD.showInfo(withStatus: "Capturing kittens")
        engine.prepareGame(difficultyLevel)
        labelGameInfo.text = "Difficulty: \(engine.difficultyPretty)"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}

//MARK: - Rx Observers
extension GameViewController {
    
    fileprivate func setupObservers() {
        setupButtonObservers()
        setupEngineObservers()
    }
    
    fileprivate func setupButtonObservers() { //Setup the button tap observers
        buttonStart.rx.tap.observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.engine.startGame()
                self?.buttonStart.isUserInteractionEnabled = false
                self?.buttonStop.isUserInteractionEnabled = true
            }).disposed(by: disposables)
        
        buttonStop.rx.tap.observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                SVProgressHUD.show(withStatus: "Re-capturing kittens")
                self?.engine.resetGame()
                self?.resetGame()
            }).disposed(by: disposables)
        
        buttonHome.rx.tap.observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }).disposed(by: disposables)
    }
    
    fileprivate func setupEngineObservers() { //Setup the observer for the engine events
        engine.events.observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] event in
                switch event {
                case .start:
                    self?.startGame()
                case .hide(let photos):
                    self?.hidePhotos(photos)
                case .end(let time):
                    self?.endGame(time)
                case .loaded:
                    self?.setupCollectionView()
                case .error(let error):
                    self?.showError(error)
                case .disable:
                    self?.collectionView.isUserInteractionEnabled = false
                case .enable:
                    self?.collectionView.isUserInteractionEnabled = true
                }
            }).disposed(by: disposables)
    }
    
}

//MARK: - GameEvent related
extension GameViewController {
    
    fileprivate func startGame() { //Start the game
        collectionView.isUserInteractionEnabled = true
        playTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            guard let elapsed = self?.engine.elapsed else {
                return
            }
            self?.labelTimer.text = String(format: "Time: %.1f", elapsed)
        }
    }
    
    fileprivate func endGame(_ time: TimeInterval) { //End the game
        collectionView.isUserInteractionEnabled = false
        resetTimer()
        showEndGameAlert()
    }
    
    fileprivate func resetGame() { //Reset the game
        resetTimer()
        labelTimer.text = "Time: 0.0"
        buttonStart.isUserInteractionEnabled = true
        buttonStop.isUserInteractionEnabled = false
        SVProgressHUD.dismiss()
    }
    
    fileprivate func resetTimer() { //Reset the timer
        playTimer?.invalidate()
        playTimer = nil
    }
    
    fileprivate func hidePhotos(_ photos: [Photo]) { //Hide the emitted photos in the event
        for photo in photos {
            guard let i = engine.indexForPhoto(photo) else { return }
            let cell = collectionView.cellForItem(at: IndexPath(item: i, section: 0)) as! PhotoCollectionViewCell
            cell.turn(false)
        }
    }
    
    fileprivate func showError(_ error: MoyaError) { //Oh noes! No kittens available
        let alert = UIAlertController(title: "Error", message: "Unfortunately an error has occurred getting the kittens.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func showEndGameAlert() { //Ask the player for their name
        let elapsed = engine.elapsed
        let alert = UIAlertController(title: "Complete", message: String(format: "%@ %.1f seconds", "Game completed in", elapsed), preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            let textField = alert.textFields![0] as UITextField
            guard let name = textField.text else { return }
            self?.saveScore(name, time: elapsed, difficulty: (self?.engine.difficulty)!)
            self?.resetGame()
        }
        saveAction.isEnabled = false
        alert.addAction(saveAction)
        
        alert.addTextField { [weak self] textField in
            textField.placeholder = "Name"
            textField.rx.text.orEmpty
                .observeOn(MainScheduler.instance).asObservable()
                .subscribe(onNext: { text in
                    saveAction.isEnabled = text.characters.count > 0
                }).disposed(by: (self?.disposables)!)
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { [weak self] action in
            self?.navigationController?.popViewController(animated: true)
        })
        
        self.present(alert, animated: true, completion: nil)
    }
    
    fileprivate func saveScore(_ name: String, time: TimeInterval, difficulty: Int) {
        let realm = try! Realm()
        let result = GameResult(value: ["name": name, "time": time, "difficulty": difficulty])
        
        try! realm.write {
            realm.add(result)
        }
        let controller = storyboard?.instantiateViewController(withIdentifier: "controller_high_scores") as! HighScoresViewController
        navigationController?.pushViewController(controller, animated: true)
    }
    
}

//MARK: - UICollectionViewDelegate
extension GameViewController {
    
    fileprivate func setupCollectionView() { //Setup the collectio view datasource
        collectionView.dataSource = nil
        photos = Observable.just(engine.photos)
        photos?.observeOn(MainScheduler.instance)
            .bind(to: collectionView.rx.items(cellIdentifier: "PhotoCell")) { index, model, cell in
                let cell = cell as! PhotoCollectionViewCell
                cell.imageViewBack.image = UIImage(named: "logo")
                cell.imageViewKitten.kf.setImage(with: URL(string: model.imageUrl))
        }.disposed(by: disposables)
        
        collectionView.rx.modelSelected(Photo.self).observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] photo in
            guard let i = self?.engine.indexForPhoto(photo) else { return }
            let cell = self?.collectionView.cellForItem(at: IndexPath(item: i, section: 0)) as! PhotoCollectionViewCell
            if cell.revealed { return }
            cell.turn(true)
            self?.engine.selectPhoto(photo)
        }).disposed(by: disposables)
        
        SVProgressHUD.dismiss()
    }
    
}
