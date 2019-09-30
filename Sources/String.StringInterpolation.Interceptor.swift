//
//  String.StringInterpolation.Interceptor.swift
//  Font
//
//  Created by mikun on 2019/8/23.
//  Copyright © 2019 庄黛淳华. All rights reserved.
//

import UIKit

public extension String.StringInterpolation {
	class Interceptor {
		static let `default` = Interceptor()
		
		static let imagePlaceholder = "*&^SwiftUIKit.Text.image*&^"
		static let attributedPlaceholder = "*&^SwiftUIKit.Text.attributedString*&^"
		
		lazy var cachingImage: [(image: UIImage, width: CGFloat?, height: CGFloat?, offset: CGFloat)] = []
		lazy var cachingAttributedString: [NSAttributedString] = []
	}
	public mutating func appendInterpolation(Text: UIImage, width: CGFloat? = nil, height: CGFloat? = nil, offset: CGFloat = -2) {
		appendLiteral(Interceptor.imagePlaceholder)
		Interceptor.default.cachingImage.append((Text, width, height, offset))
	}
	public mutating func appendInterpolation(Text: NSAttributedString) {
		appendLiteral(Interceptor.attributedPlaceholder)
		Interceptor.default.cachingAttributedString.append(Text)
	}
	
	//编译器bug, 当存在两条并且其中一条有多个参数的时候, 自动补全就不显示那条多参数的, 所以这里加一条方便提示, 等这个bug修了可以去掉
	public mutating func appendInterpolation(Text: UIImage) {
		appendLiteral(Interceptor.imagePlaceholder)
		Interceptor.default.cachingImage.append((Text, nil, nil, -2))
	}
}
