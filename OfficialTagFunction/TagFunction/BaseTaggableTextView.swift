//
//  TagableTextView.swift
//  OfficialTagFunction
//
//  Created by Phthphat on 12/6/19.
//  Copyright © 2019 phthphat. All rights reserved.
//  About it: https://gitlab.com/phthphat-share/taggable-uitextview

import Foundation
import UIKit

class BaseTaggableTextView<T, C: UITableViewCell>: UITextView, UITextViewDelegate, Taggable, UITableViewDataSource, UITableViewDelegate {
    
    //Tagable Properties
    var specialChar: Character = "@"
    var curTextToSearch = "" {
        didSet {
            if self.curTextToSearch.isEmpty {
                self.filteredData = self.rawData
            } else {
                self.filteredData = self.rawData.filter({
                    self.getText(of: $0).lowercased().contains(self.curTextToSearch.lowercased())
                })
            }
            self.listTagTbV.reloadData()
        }
    }
    private var maxHoverHeigh: CGFloat = 100
    var colorTaggedName: UIColor = .red
    private var filteredData: [T] = [] {
        didSet {
            heighConstraintListTagTbV.constant = CGFloat(self.filteredData.count) * rowHeight
        }
    }
    var rawData: [T] = []
    var rowHeight: CGFloat = 30
    var enterTagMode = false
    weak var delegateTag: TaggableDelegate?
    weak var dataSourceTag: TaggableDataSource? {
        didSet {
            guard let dataSource = self.dataSourceTag else { return }
            self.colorTaggedName = dataSource.colorOfTaggedName(sender: self)
            
            //Register cell
//            let cellInfo = dataSource.tagFunction(self, registerCellFor: self.listTagTbV)
//            cellClass = cellInfo.0
//            cellID = cellInfo.1
//            self.listTagTbV.register(cellClass, forCellReuseIdentifier: cellID)
        }
    }
    
    //TextView properties
    private var curText = ""
    private var cellID = "CellId"
    private var cellClass: AnyClass?
    private var curTagName = ""
    private var indexPointer: Int = 0
    
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
    
    func initView() {
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
        registerCell()
        listTagTbV.dataSource = self
        listTagTbV.delegate = self
    }
    
    func setData(data: [T]) {
        self.rawData = data
        triggerSearch()
        listTagTbV.reloadData()
    }
    
    //Override to user
    func getText(of model: T) ->  String {
        return ""
    }
    func setUpCell(cell: C, model: T) {
        
    }
    func registerCell() {
        self.cellID = String(describing: C.self)
        listTagTbV.register(C.self, forCellReuseIdentifier: cellID)
    }
    func getData() {}
    
    //Private function
    private func triggerSearch() {
        self.curTextToSearch += ""
    }
    
    // UITextViewDelegate
    func textViewDidChange(_ textView: UITextView) {
        let newText = textView.text ?? ""
        self.indexPointer = findPointerPosition(oldText: curText, newText: newText)
        curText = newText
        if canShowHover(text: newText, pointerPosition: indexPointer) {
            showHoverView()
            getData()
        } else {
            hideHoverView()
        }
        if enterTagMode {
            let listTag = text.listTagText()
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
            self.attributedText = convert(text.listTagText(), string: text)
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
    //UITableView Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = listTagTbV.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? C else {
            return UITableViewCell()
        }
        let model = self.filteredData[indexPath.row]
        setUpCell(cell: cell, model: model)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegateTag?.didChoose(indexPath: indexPath)
        self.hideHoverView()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.rowHeight
    }
}

extension BaseTaggableTextView: TaggableDelegate {
    func didChoose(indexPath: IndexPath) {
        let model = self.filteredData[indexPath.row]
        let listTag = text.listTagText()
        for i in 0..<listTag.count {
            let listRange = self.text.ranges(of: listTag[i])
            var stopMainLoop = false
            for j in 0..<listRange.count {
                let startIndex = self.text.distance(from: text.startIndex, to: listRange[j].lowerBound)
                let endIndex = self.text.distance(from: text.startIndex, to: listRange[j].upperBound)
                if endIndex >= self.indexPointer && startIndex <= self.indexPointer {
                    self.text = text.replacingOccurrences(of: String(self.specialChar) + self.curTagName, with: String(self.specialChar) + getText(of: model), options: .literal, range: listRange[j])
                    self.curText = self.text
                    self.setCursor(position: endIndex + (getText(of: model).count - self.curTagName.count))
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
