//
//  UILabelTextStorage.swift
//  SwiftUIKit
//
//  Created by mikun on 2019/12/9.
//  
//

import UIKit
func UILabelTextStorage() -> NSTextStorage {
	let number = (0...9).randomElement() ?? 0
	let name = "NSString" + "\(number)" + "TextStorage"
	
	guard let typeClass = NSClassFromString(name.replacingOccurrences(of: "\(number)", with: "Drawing")) as? NSTextStorage.Type else {
		return NSTextStorage()
	 }
	return typeClass.init()
}
