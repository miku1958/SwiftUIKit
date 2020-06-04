//
//  NSAttributedString.swift
//  SwiftUIKit
//
//  Created by 庄黛淳华 on 2020/6/4.
//

import UIKit

extension NSAttributedString {
	var fullRange: NSRange {
		NSRange(location: 0, length: self.length)
	}
}

extension NSAttributedString.Key {
	static let attachmentOffset = NSAttributedString.Key(rawValue: "NSTextAttachment.offset")
}
