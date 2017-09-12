//
//  HighScoresViewController.swift
//  Concentration
//
//  Created by Shaun Rowe on 28/07/2017.
//  Copyright © 2017 Shaun Rowe. All rights reserved.
//

import UIKit
import RealmSwift
import RxDataSources
import RxSwift
import RxCocoa

class HighScoresViewController: UIViewController {
    
    let disposables = DisposeBag()
    
    @IBOutlet weak var buttonHome: UIButton!
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupTableView()
        buttonHome.rx.tap.observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.navigationController?.popToRootViewController(animated: true)
            }).disposed(by: disposables)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private func setupTableView() {
        let realm = try! Realm()
        let scores = realm.objects(GameResult.self).sorted(byKeyPath: "time", ascending: true)
        if scores.count > 0 {
            var s = [GameResult]()
            let limit = scores.count >= 10 ? 10 : scores.count
            for i in 0..<limit {
                s.append(scores[i])
            }
            tableView.dataSource = nil
            Observable<[GameResult]>.just(s).observeOn(MainScheduler.instance)
                .bind(to: tableView.rx.items(cellIdentifier: "HighScoreCell")) { index, model, cell in
                    cell.textLabel?.text = model.name
                    let formatter = NumberFormatter()
                    formatter.maximumFractionDigits = 2
                    formatter.minimumIntegerDigits = 1
                    cell.detailTextLabel?.text = "\(formatter.string(for: model.time)!) seconds (\(model.difficulty == 1 ? "Easy" : (model.difficulty == 2 ? "Medium" : "Hard")))"
                }.disposed(by: disposables)
        }
    }

}
