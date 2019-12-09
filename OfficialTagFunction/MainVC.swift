//
//  MainVC.swift
//  OfficialTagFunction
//
//  Created by Lucas Pham on 12/6/19.
//  Copyright © 2019 phthphat. All rights reserved.
//

import UIKit

struct User {
    var id: String
    var name: String
}

class MainVC: UIViewController {

    let tagTextView: AppTextView = {
        let tv = AppTextView()
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    func initView() {
        self.view.backgroundColor = .gray
        self.view.addSubview(tagTextView)
        self.tagTextView.frame = CGRect(x: 10, y: 300, width: 200, height: 30)
        self.tagTextView.dataSourceTag = self
        
        self.tagTextView.setData(data: [
            User(id: "1", name: "Hihi"),
            User(id: "2", name: "Ronaldo"),
            User(id: "3", name: "Messi")
        ])
    }
}

extension MainVC: TaggableDataSource {
    func tagFunction(_ sender: Any, cell: UITableViewCell, setUpCellWith model: User) {
        cell.textLabel?.text = model.name
    }
    
    func tagFunction(_ sender: Any, setAutoLayoutFor hoverView: UIView) {
        self.view.addSubview(hoverView)
        let constrains = [
            hoverView.topAnchor.constraint(greaterThanOrEqualTo: self.view.topAnchor, constant: 50),
            hoverView.bottomAnchor.constraint(equalTo: self.tagTextView.topAnchor),
            hoverView.leadingAnchor.constraint(equalTo: self.tagTextView.leadingAnchor),
            hoverView.trailingAnchor.constraint(equalTo: self.tagTextView.trailingAnchor),
        ]
        NSLayoutConstraint.activate(constrains)
    }
    
    func colorOfTaggedName(sender: Any) -> UIColor {
        return .purple
    }
}
