//
//  TagableTextView.swift
//  OfficialTagFunction
//
//  Created by Lucas Pham on 12/6/19.
//  Copyright © 2019 phthphat. All rights reserved.
//

import Foundation
import UIKit

class TaggableTextView: UITextView, UITextViewDelegate, Taggable {
    //Tagable Properties
    var specialChar: Character = "@"
    var curTextToSearch = "" {
        didSet {
            self.filteredData = self.rawData.filter({ $0.name.lowercased().contains(self.curTextToSearch.lowercased()) })
            self.listTagTbV.reloadData()
        }
    }
//    var hoverFrame: CGRect = .zero
    private var maxHoverHeigh: CGFloat = 100
    var colorTaggedName: UIColor = .red
    private var filteredData: [User] = [] {
        didSet {
            heighConstraintListTagTbV.constant = CGFloat(self.filteredData.count) * rowHeight
        }
    }
    var rawData: [User] = []
    var rowHeight: CGFloat = 30
    var enterTagMode = false
    weak var delegateTag: TaggableDelegate?
    weak var dataSourceTag: TaggableDataSource? {
        didSet {
            guard let dataSource = self.dataSourceTag else { return }
            self.colorTaggedName = dataSource.colorOfTaggedName(sender: self)
            
            //Register cell
            let cellInfo = dataSource.tagFunction(self, registerCellFor: self.listTagTbV)
            cellClass = cellInfo.0
            cellID = cellInfo.1
            self.listTagTbV.register(cellClass, forCellReuseIdentifier: cellID)
        }
    }
    
    //TextView properties
    fileprivate var curText = ""
    fileprivate var cellID = ""
    fileprivate var cellClass: AnyClass?
    fileprivate var curTagName = ""
    fileprivate var indexPointer: Int = 0
    
    // View
    let hoverView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .yellow
        return v
    }()
    let listTagTbV: UITableView = {
        let tbV = UITableView()
        tbV.backgroundColor = .red
        tbV.translatesAutoresizingMaskIntoConstraints = false
        return tbV
    }()
    
    private var heighConstraintListTagTbV: NSLayoutConstraint!
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        initView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initView()
    }
    
    private func initView() {
        heighConstraintListTagTbV = listTagTbV.heightAnchor.constraint(equalToConstant: 0)
        heighConstraintListTagTbV.isActive = true
        
        hoverView.addSubview(listTagTbV)
        let constrains = [
            hoverView.topAnchor.constraint(equalTo: listTagTbV.topAnchor),
            hoverView.bottomAnchor.constraint(equalTo: listTagTbV.bottomAnchor),
            hoverView.leadingAnchor.constraint(equalTo: listTagTbV.leadingAnchor),
            hoverView.trailingAnchor.constraint(equalTo: listTagTbV.trailingAnchor),
        ]
        NSLayoutConstraint.activate(constrains)
        delegate = self //UITextViewDelegate, if you want to use its delegate in your class, please call textViewDidChange below
        delegateTag = self //Similar above
        listTagTbV.dataSource = self
        listTagTbV.delegate = self
    }
    
    func setData(data: [User]) {
        self.filteredData = data
        self.rawData = data
        listTagTbV.reloadData()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let newText = textView.text ?? ""
        self.indexPointer = findPointerPosition(oldText: curText, newText: newText)
        curText = newText
        if canShowHover(text: newText, pointerPosition: indexPointer) {
            showHoverView()
        } else {
            hideHoverView()
        }
        if enterTagMode {
            let listTag = text.findTagText()
            for i in 0..<listTag.count {
                let listRange = self.text.ranges(of: listTag[i])
                var stopMainLoop = false
                for j in 0..<listRange.count {
                    let startIndex = self.text.distance(from: text.startIndex, to: listRange[j].lowerBound)
                    let endIndex = self.text.distance(from: text.startIndex, to: listRange[j].upperBound)
                    if endIndex >= self.indexPointer && startIndex <= self.indexPointer {
                        self.curTagName = listTag[i].replacingOccurrences(of: String(specialChar), with: "")
                        stopMainLoop = true
                        break
                    }
                }
                if stopMainLoop { break }
            }
            curTextToSearch = self.curTagName
        } else {
            self.curTagName = ""
        }
        updateAttributeText()
    }
    func updateAttributeText() {
        let text = self.text ?? ""
        if let preAttributedRange: UITextRange = selectedTextRange {
            self.attributedText = convert(text.findTagText(), string: text)
            selectedTextRange = preAttributedRange
        }
    }
    
    func resetCurTagName() {
        self.curTagName = ""
        self.curTextToSearch = ""
    }
    func setCursor(position: Int) {
        let position = self.position(from: beginningOfDocument, offset: position)!
        selectedTextRange = textRange(from: position, to: position)
    }
    
    func showHoverView() {
        guard let currentView = UIApplication.shared.keyWindow else { return }
        currentView.addSubview(self.hoverView)
        self.hoverView.translatesAutoresizingMaskIntoConstraints = false
        self.dataSourceTag?.tagFunction(self, setAutoLayoutFor: self.hoverView)
        enterTagMode = true
    }
    func hideHoverView() {
        self.hoverView.removeFromSuperview()
        self.curTextToSearch = ""
        enterTagMode = false
    }
}

extension TaggableTextView: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID)
        cell?.textLabel?.text = self.filteredData[indexPath.row].name
        cell?.backgroundColor = .red
        return cell ?? UITableViewCell()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = self.filteredData[indexPath.row]
        self.delegateTag?.didChooseUser(user: user)
        self.hideHoverView()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.rowHeight
    }
}

extension TaggableTextView: TaggableDelegate {
    func didChooseUser(user: User) {
        let listTag = text.findTagText()
        for i in 0..<listTag.count {
            let listRange = self.text.ranges(of: listTag[i])
            var stopMainLoop = false
            for j in 0..<listRange.count {
                let startIndex = self.text.distance(from: text.startIndex, to: listRange[j].lowerBound)
                let endIndex = self.text.distance(from: text.startIndex, to: listRange[j].upperBound)
                if endIndex >= self.indexPointer && startIndex <= self.indexPointer {
                    self.text = text.replacingOccurrences(of: String(self.specialChar) + self.curTagName, with: String(self.specialChar) + user.name, options: .literal, range: listRange[j])
                    self.curText = self.text
                    self.setCursor(position: endIndex + (user.name.count - self.curTagName.count))
                    stopMainLoop = true
                    break
                }
            }
            if stopMainLoop { break }
        }
        
        self.resetCurTagName()
        self.updateAttributeText()
    }
}
