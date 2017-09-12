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
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        clearCollectionView()
        setupObservables()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = true
        resetGameBoard()
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
    
    deinit {
        clearCollectionView() //Bug with RxDatasources, so I need to do this :(
    }
    
}

//MARK: - Rx Observers and stuff
extension GameViewController: RxObservablesController {
    
    internal func setupObservables() {
        setupButtonObservables()
        setupEngineObservables()
    }
    
    fileprivate func setupButtonObservables() { //Handle all the clicks
        buttonStart.rx.tap.observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.start()
            }).disposed(by: disposables)
        
        buttonStop.rx.tap.observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                SVProgressHUD.show(withStatus: "Re-capturing kittens")
                self?.resetGameBoard()
            }).disposed(by: disposables)
        
        buttonHome.rx.tap.observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }).disposed(by: disposables)
    }
    
    fileprivate func setupEngineObservables() { //Setup the observer for the engine events
        engine.events.observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] event in
                switch event {
                case .start:
                    self?.startGameBoard() //Let's play!
                case .hide(let photos):
                    self?.hidePhotos(photos) //Make the kittens disappear
                case .end(let time):
                    self?.finish(time) //All done
                case .loaded:
                    self?.setupCollectionViewObservables() //We have captured the kittens, setup the collection view
                case .error(let error):
                    self?.showError(error) //Display an error alert if something has gone wrong
                case .disable:
                    self?.collectionView.isUserInteractionEnabled = false //Disable clicks on the collection view
                case .enable:
                    self?.collectionView.isUserInteractionEnabled = true //Enable clicks on the collection view
                }
            }).disposed(by: disposables)
    }
    
    fileprivate func clearCollectionView() {
        collectionView.delegate = nil
        collectionView.dataSource = nil //Clear the data source
        collectionView.reloadData()
        collectionView.isUserInteractionEnabled = false
    }
    
    fileprivate func setupCollectionViewObservables() { //Setup the collection view RxDatasource
        clearCollectionView()
        let photos = Observable.from(optional: engine.photos)        
        photos.observeOn(MainScheduler.instance)
            .bind(to: collectionView.rx.items(cellIdentifier: "PhotoCell")) { index, model, cell in //Bind the Observable photos to the collection view
                let cell = cell as! PhotoCollectionViewCell
                cell.imageViewBack.image = UIImage(named: "logo")
                cell.imageViewKitten.kf.setImage(with: URL(string: model.imageUrl))
            }.disposed(by: disposables)
        
        collectionView.rx.modelSelected(Photo.self).observeOn(MainScheduler.instance) //Handle the clickety clicks
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

//MARK: - GameEvent related
extension GameViewController {
    
    fileprivate func start() {
        engine.startGame()
        toggleButton(buttonStart, enabled: false)
        toggleButton(buttonStop, enabled: true)
    }
    
    fileprivate func finish(_ time: TimeInterval) { //End the game
        collectionView.isUserInteractionEnabled = false
        resetTimer()
        showEndGameAlert()
    }
    
    fileprivate func startGameBoard() { //Start the game
        collectionView.isUserInteractionEnabled = true
        playTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            guard let elapsed = self?.engine.elapsed else {
                return
            }
            self?.labelTimer.text = String(format: "%.1f", elapsed)
        }
    }
    
    fileprivate func resetGameBoard() { //Reset the game
        clearCollectionView()
        resetTimer()
        labelTimer.text = "0.0"
        toggleButton(buttonStart, enabled: true)
        toggleButton(buttonStop, enabled: false)
        engine.resetGame()
    }
    
    fileprivate func resetTimer() { //Reset the timer
        playTimer?.invalidate()
        playTimer = nil
    }
    
    fileprivate func toggleButton(_ button: UIButton, enabled: Bool) {
        button.isUserInteractionEnabled = enabled
        button.isEnabled = enabled
    }
    
    fileprivate func hidePhotos(_ photos: [Photo]) { //Hide the emitted photos in the event
        for photo in photos {
            guard let i = engine.indexForPhoto(photo) else { return }
            let cell = collectionView.cellForItem(at: IndexPath(item: i, section: 0)) as! PhotoCollectionViewCell
            cell.turn(false)
        }
    }
    
    fileprivate func showError(_ error: MoyaError) { //Oh noes! No kittens available
        let alert = UIAlertController(title: "Error", message: "Unfortunately an error has occurred capturing the kittens. No kittens were harmed due to this error.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        present(alert, animated: true) { [weak self] in
            self?.resetGameBoard()
        }
    }
    
    fileprivate func showEndGameAlert() { //Ask the player for their name
        let time = engine.elapsed
        let difficulty = engine.difficulty
        let alert = UIAlertController(title: "Complete", message: String(format: "%@ %.1f seconds", "Game completed in", time), preferredStyle: .alert)
        alert.addTextField { [weak self, weak alert] textField in
            textField.placeholder = "Name"
            textField.rx.text.orEmpty //Make sure that the save button is disabled until there has been some text input
                .observeOn(MainScheduler.instance).asObservable()
                .subscribe(onNext: { text in
                    let action = alert?.actions[0]
                    action?.isEnabled = text.characters.count > 0
                }).disposed(by: (self?.disposables)!)
        }
        alert.addAction(UIAlertAction(title: "Save", style: .default) { [weak self, weak alert, time, difficulty] action in
            let textField = alert?.textFields![0]
            guard let name = textField?.text else { return }
            self?.saveScore(name, time: time, difficulty: difficulty) //Save the score
//            self?.resetGame() //Reset the game
            action.isEnabled = false //Disable the button until we have some input in the textbox
        })
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
