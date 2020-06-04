//
//  Color.swift
//  SwiftUIKit
//
//  Created by mikun on 2019/8/16.
//  Copyright © 2019 庄黛淳华. All rights reserved.
//

import UIKit

extension UIColor {
	public enum RGBColorSpace {
		
		case sRGB

		@available(iOS 10.0, *)//, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
		case sRGBLinear

		@available(iOS 9.3, *)//, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
		case displayP3
	}
	
	public convenience init(_ colorSpace: RGBColorSpace = .sRGB, red: CGFloat, green: CGFloat, blue: CGFloat, opacity: CGFloat = 1) {
		var space = CGColorSpace.sRGB
		switch colorSpace {
		case .sRGB:
			space = CGColorSpace.sRGB
		case .sRGBLinear:
			if #available(iOS 10.0, *) {
				space = CGColorSpace.linearSRGB
			}
		case .displayP3:
			if #available(iOS 9.3, *) {
				space = CGColorSpace.displayP3
			}
		}
		let comps = [red, green, blue, opacity]
		self.init(cgColor: CGColor(colorSpace: CGColorSpace(name: space)!, components: comps)!)
	}
	
	public convenience init(_ colorSpace: RGBColorSpace = .sRGB, white: CGFloat, opacity: CGFloat = 1) {
		self.init(colorSpace, red: white, green: white, blue: white, opacity: opacity)
	}
}

extension UIColor {
	
//	public static let pink = Color(color: .pink)
	

	@available(iOS 13, *)//, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
	public static let primary = UIColor.label

	@available(iOS 13, *)//, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
	public static let secondary = UIColor.secondaryLabel
}


extension UIColor {
	public func opacity(_ opacity: CGFloat) -> UIColor {
		return withAlphaComponent(opacity)
	}
}
