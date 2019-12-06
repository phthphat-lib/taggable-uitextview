//
//  Tagable.swift
//  OfficialTagFunction
//
//  Created by Lucas Pham on 12/6/19.
//  Copyright © 2019 phthphat. All rights reserved.
//

import Foundation
import UIKit

protocol Taggable {
    var specialChar: Character { get set }
    var colorTaggedName: UIColor  { get set }
    var enterTagMode: Bool  { get set }
    func showHoverView()
    func hideHoverView()
}

extension Taggable {
    func canShowHover(text: String, pointerPosition: Int) -> Bool {
        let _text = text[0..<( pointerPosition + 1 )]
        guard let lastChar = _text.last, _text.count > 1, _text.contains("@") else { return false }
        if lastChar == " " || lastChar == self.specialChar { return false }
        guard let lastSubStr = _text.split(separator: self.specialChar).last else { return false }
        if isTextContainCommonChar(text: String(lastSubStr)) {
            return true
        }
        return false
    }
    
    func findPointerPosition(oldText: String, newText: String) -> Int {
        var differentIndex = 0
        let smallestLength = oldText.count < newText.count ? oldText.count : newText.count
        for i in 0..<smallestLength {
            if oldText[i] != newText[i] {
                differentIndex = i
                break
            }
        }
        differentIndex = differentIndex == 0 ? (oldText.count < newText.count ? oldText.count : newText.count) : differentIndex
        return differentIndex
    }
    
    func updateAttributeText(curText: String) -> NSAttributedString {
        return self.convert(curText.findTagText(), string: curText)
    }
    
    func isTextContainCommonChar(text: String) -> Bool {
        var result = true
        text.forEach { (char) in
            var isCommon = (char >= "a" && char <= "y") || (char >= "A" && char <= "Y")
            isCommon = isCommon || (char >= "0" && char <= "9") || char == "_"
            result = result && isCommon
        }
        return result
    }
    
    func convert(_ hashElements:[String], string: String) -> NSAttributedString {

        let hasAttribute = [NSAttributedString.Key.foregroundColor: self.colorTaggedName, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)]

        let normalAttribute = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]

        let mainAttributedString = NSMutableAttributedString(string: string, attributes: normalAttribute)
        
        hashElements.forEach {
            string.ranges(of: $0).forEach { range in
                mainAttributedString.addAttributes(hasAttribute, range: NSRange(range: range, in: string))
            }
        }
        return mainAttributedString
    }
}

protocol TaggableDataSource: class {
    func tagFunction(_ sender: Any, setAutoLayoutFor hoverView: UIView)
    func colorOfTaggedName(sender: Any) -> UIColor
    func tagFunction(_ sender: Any, registerCellFor tableView: UITableView) -> (AnyClass, String)
}

protocol TaggableDelegate: class {
    func didChooseUser(user: User)
}




extension String {
    var length: Int {
        return count
    }

    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }

    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
}

extension String {
    func findTagText(specialChar: Character = "@") -> [String] {
        var arr_hasStrings:[String] = []
        let regex = try? NSRegularExpression(pattern: "(\(specialChar)[a-zA-Z0-9_]+)", options: [])
        if let matches = regex?.matches(in: self, options:[], range:NSMakeRange(0, self.count)) {
            for match in matches {
                arr_hasStrings.append(NSString(string: self).substring(with: NSRange(location:match.range.location, length: match.range.length )))
            }
        }
        return arr_hasStrings
    }
    func indices(of occurrence: String) -> [Int] {
        var indices = [Int]()
        var position = startIndex
        while let range = range(of: occurrence, range: position..<endIndex) {
            let i = distance(from: startIndex,
                             to: range.lowerBound)
            indices.append(i)
            let offset = occurrence.distance(from: occurrence.startIndex,
                                             to: occurrence.endIndex) - 1
            guard let after = index(range.lowerBound, offsetBy: offset, limitedBy: endIndex) else {
                break
            }
            position = index(after: after)
        }
        return indices
    }
    func ranges(of searchString: String) -> [Range<String.Index>] {
        let _indices = indices(of: searchString)
        let count = searchString.count
        return _indices.map({ index(startIndex, offsetBy: $0)..<index(startIndex, offsetBy: $0+count) })
    }

}
extension NSRange {
    private init(string: String, lowerBound: String.Index, upperBound: String.Index) {
        let utf16 = string.utf16

        let lowerBound = lowerBound.samePosition(in: utf16)
        let location = utf16.distance(from: utf16.startIndex, to: lowerBound!)
        let length = utf16.distance(from: lowerBound!, to: upperBound.samePosition(in: utf16)!)

        self.init(location: location, length: length)
    }

    init(range: Range<String.Index>, in string: String) {
        self.init(string: string, lowerBound: range.lowerBound, upperBound: range.upperBound)
    }

    init(range: ClosedRange<String.Index>, in string: String) {
        self.init(string: string, lowerBound: range.lowerBound, upperBound: range.upperBound)
    }
}
