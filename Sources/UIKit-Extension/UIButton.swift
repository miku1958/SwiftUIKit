//
//  UIButton.swift
//  SwiftUIKit
//
//  Created by mikun on 2019/10/18.
//  
//

import Foundation

extension UIButton {
	private static var actionKey = 0
    /// Creates an instance for triggering `action`.
    ///
    /// - Parameters:
    ///     - action: The action to perform when `self` is triggered.
    ///     - label: A view that describes the effect of calling `action`.
	public convenience init(action: @escaping () -> Void/*, label: () -> Text*/) {
		self.init()
		addTarget(self, action: #selector(performAction), for: .touchUpInside)
		objc_setAssociatedObject(self, &Self.actionKey, action, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
	}
	@objc private func performAction() {
		if let existing = objc_getAssociatedObject(self, &Self.actionKey) as? () -> Void {
            existing()
        }
	}
}
