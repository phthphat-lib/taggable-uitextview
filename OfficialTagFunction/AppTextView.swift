//
//  AppTextView.swift
//  OfficialTagFunction
//
//  Created by Lucas Pham on 12/8/19.
//  Copyright © 2019 phthphat. All rights reserved.
//

import Foundation
import UIKit

class AppTextView: BaseTaggableTextView<User, UITableViewCell> {
    override func getText(of model: User) -> String {
        return model.name
    }
    override func setUpCell(cell: UITableViewCell, model: User) {
        cell.textLabel?.text = model.name
    }
    override func getData() {
        
    }
}
