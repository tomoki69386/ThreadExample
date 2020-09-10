//
//  ViewController.swift
//  Thread
//
//  Created by 築山朋紀 on 2020/09/10.
//  Copyright © 2020 築山朋紀. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    
    var presenter = Presenter()
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.success.debug().drive().disposed(by: disposeBag)
        
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.rowHeight = 44
        tableView.frame = view.bounds
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1000
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        let backgroundColors: [UIColor] = [.red, .black, .blue, .green, .brown, .cyan, .darkGray, .gray, .link, .yellow, .orange]
        cell.backgroundColor = backgroundColors.randomElement()
        return cell
    }
}

class Presenter {
    
    var success: Driver<String>
    
    init() {
        
        let backgroundScheduler = ConcurrentDispatchQueueScheduler(qos: .background)
        let interactor = Interactor()
        
        self.success = Observable<Void>
            .just(())
            .observeOn(backgroundScheduler) // ここをコメントアウトすると(メインスレッド実行)Interactor.somethingの処理が終わるまでTableViewが表示されない
            .flatMapFirst({ _ -> Observable<String> in
                return interactor.something()
            })
            .debug()
            .filter { $0 == "1000000" }
            .asDriver(onErrorDriveWith: .empty())
        
    }
}

class Interactor {
    func something() -> Observable<String> {
        return Observable.create({ observer in
            
            for number in 0...1000000 {
                observer.onNext("\(number)")
                if number == Int.max {
                    observer.onCompleted()
                }
            }
            
            return Disposables.create()
        })
    }
}
