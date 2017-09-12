//
//  ViewController.swift
//  Concentration
//
//  Created by Shaun Rowe on 28/07/2017.
//  Copyright © 2017 Shaun Rowe. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class HomeViewController: UIViewController {
    
    let disposables = DisposeBag()
    
    @IBOutlet weak var buttonEasy: UIButton!
    @IBOutlet weak var buttonMedium: UIButton!
    @IBOutlet weak var buttonHard: UIButton!
    @IBOutlet weak var buttonHighScores: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        setupObservables()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

}

extension HomeViewController: RxObservablesController {
    
    internal func setupObservables() {
        buttonEasy.rx.tap.observeOn(MainScheduler.instance)
            .subscribe(onNext:{ [weak self] in
                self?.showGameController(1)
            }).disposed(by: disposables)
        
        buttonMedium.rx.tap.observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.showGameController(2)
            }).disposed(by: disposables)
        
        buttonHard.rx.tap.observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.showGameController(3)
            }).disposed(by: disposables)
        
        buttonHighScores.rx.tap.observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.showHighScoresController()
            }).disposed(by: disposables)
    }
    
    fileprivate func showGameController(_ difficulty: Int) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "controller_game") as! GameViewController
        controller.difficulty = difficulty
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    fileprivate func showHighScoresController() {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "controller_high_scores") as! HighScoresViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
}
