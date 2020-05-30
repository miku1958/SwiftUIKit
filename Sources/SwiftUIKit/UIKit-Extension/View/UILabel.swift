//
//  UILabel.swift
//  Font
//
//  Created by mikun on 2019/8/17.
//  Copyright © 2019 庄黛淳华. All rights reserved.
//

import UIKit
extension UILabel {
	public struct SwiftUIKit {
		fileprivate weak var view: UILabel?
		
		fileprivate lazy var delegate = Delegate(view: view)
		
		fileprivate var tapGestrues: [Delegate.TapGesture] = []
		fileprivate var longPressGestrues: [Delegate.LongPressGesture] = []
//		public var defaultStyle
		public var text: Text? {
			didSet {
				guard let view = view else { return }
				text?.defaultFont = Font(view.font)
				view.attributedText = text?.text
				view.numberOfLines = text?.lineLimit ?? 0
				if let scale = text?.minimumScaleFactor {
					view.minimumScaleFactor = scale
				}
				delegate.config(text: text, tapGestrues: &tapGestrues, longPressGestrues: &longPressGestrues)
			}
		}
	}
}

extension UILabel {
	private static var SwiftUIKitKey: Void?
	public var swift: SwiftUIKit {
		get {
			var swift = objc_getAssociatedObject(self, &Self.SwiftUIKitKey) as? SwiftUIKit
			if swift == nil {
				swift = SwiftUIKit(view: self)
				self.swift = swift!
			}
			return swift!
		}
		set {
			objc_setAssociatedObject(self, &Self.SwiftUIKitKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
		}
	}
}
