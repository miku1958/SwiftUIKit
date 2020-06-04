//
//  UITextField.swift
//  SwiftUIKit
//
//  Created by mikun on 2019/8/25.
//  Copyright © 2019 庄黛淳华. All rights reserved.
//

import UIKit
extension UITextField {
	public struct SwiftUIKit {
		weak var view: UITextField?
		
		fileprivate lazy var delegate = Delegate(view: view)
		
		fileprivate var tapGestrues: [Delegate.TapGesture] = []
		fileprivate var longPressGestrues: [Delegate.LongPressGesture] = []

		public var text: Text? {
			didSet {
				view?.attributedText = text?.text
				if let scale = text?.minimumScaleFactor {
					view?.contentScaleFactor = scale
				}
				delegate.config(text: text, tapGestrues: &tapGestrues, longPressGestrues: &longPressGestrues)
			}
		}
	}
}

extension UITextField {
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
