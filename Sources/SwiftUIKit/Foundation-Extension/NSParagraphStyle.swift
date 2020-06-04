//
//  Text.swift
//  SwiftUIKit
//
//  Created by mikun on 2019/8/16.
//  Copyright © 2019 庄黛淳华. All rights reserved.
//

import UIKit

extension NSParagraphStyle {
	func mutableCopyIfNeed() -> NSMutableParagraphStyle {
		if let _para = self as? NSMutableParagraphStyle {
			return _para
		} else if let _para = self.mutableCopy() as? NSMutableParagraphStyle {
			return _para
		} else {
			return NSMutableParagraphStyle()
		}
	}
}
extension Optional where Wrapped == NSParagraphStyle {
	func mutableCopyIfNeed() -> NSMutableParagraphStyle {
		switch self {
		case .none:
			return NSMutableParagraphStyle()
		case .some(let para):
			return para.mutableCopyIfNeed()
		}
	}
}
