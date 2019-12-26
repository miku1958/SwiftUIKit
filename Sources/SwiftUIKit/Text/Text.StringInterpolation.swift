//
//  String.StringInterpolation.Interceptor.swift
//  Font
//
//  Created by mikun on 2019/8/23.
//  Copyright © 2019 庄黛淳华. All rights reserved.
//

import UIKit

extension Text {
	public struct StringInterpolation {
		private let content: Content
	}
}
extension Text.StringInterpolation {
	public struct Content {
		var cachedString = ""
		var cachingImage: [(image: UIImage, width: CGFloat?, height: CGFloat?, offset: CGFloat)] = []
		var cachingAttributedString: [NSAttributedString] = []
	}
}
extension Text.StringInterpolation.Content {
	struct Placeholder {
		static let image = "*&^SwiftUIKit.Text.image*&^"
		static let attributedString = "*&^SwiftUIKit.Text.attributedString*&^"
	}
}
extension Text.StringInterpolation: ExpressibleByStringInterpolation {
	public init(stringInterpolation: Content) {
		content = stringInterpolation
	}
	
	public init(stringLiteral value: String) {
		content = Content(cachedString: value)
	}
}
extension Text.StringInterpolation.Content: StringInterpolationProtocol {
	public init(literalCapacity: Int, interpolationCount: Int) {
		cachedString = ""
	}
	public mutating func appendLiteral(_ literal: String) {
		cachedString += literal
	}
	public mutating func appendInterpolation(_ image: UIImage, width: CGFloat? = nil, height: CGFloat? = nil, offset: CGFloat = -2) {
		appendLiteral(Placeholder.image)
		cachingImage.append((image, width, height, offset))
	}
	public mutating func appendInterpolation(_ attStr: NSAttributedString) {
		appendLiteral(Placeholder.attributedString)
		cachingAttributedString.append(attStr)
	}
}
extension Text.StringInterpolation {
	func attritubedString(withlocalized bundle: Bundle? = nil, tableName: String? = nil, useDefaultValue: Bool) -> NSMutableAttributedString {
		checkPlaceholder(in: content.cachedString) {
			(bundle ?? Bundle.main).localizedString(forKey: $0, value: useDefaultValue ? $0 : nil, table: tableName)
		}
	}
	func attritubedString() -> NSMutableAttributedString {
		checkPlaceholder(in: content.cachedString) { $0 }
	}
	func checkPlaceholder(in string: String, handlePlainString: (String) -> String) -> NSMutableAttributedString {
		let attStr = NSMutableAttributedString()
		var cachingImage = content.cachingImage
		var cachingAttributedString = content.cachingAttributedString
		var string = string
		var finish = false
		while !finish {
			func appendImage(range: Range<String.Index>) {
				let prefix = string[string.startIndex ..< range.lowerBound]
				attStr.append(NSAttributedString(string: handlePlainString(String(prefix))))
				
				/*handle image*/
				let image = cachingImage.removeFirst()
				
				let atr = NSMutableAttributedString(string: "\u{FFFC}")

				let attach = NSTextAttachment()
				attach.image = image.image
				
				let imgWidth = image.image.size.width
				let imgHeight = image.image.size.height
				var size: CGSize
				switch (image.width, image.height) {
				case (nil, nil):
					size = image.image.size
				case let (.some(width), .some(height)):
					size = CGSize(width: width, height: height)
				case let (.some(width), nil):
					size = CGSize(width: width, height: width / imgWidth * imgHeight)
				case let (nil, .some(height)):
					size = CGSize(width: height / imgHeight * imgWidth, height: height)
				}

				let bounds = CGRect(origin: CGPoint(x: 0, y: image.offset), size: size)
				
				attach.bounds = bounds
				atr.setAttributes([.attachment: attach], range: NSRange(location: 0, length: atr.length))
				attStr.append(atr)
				/*handle image end*/
				
				string = String(string[range.upperBound ..< string.endIndex])
			}
			func appendAttributeString(range: Range<String.Index>) {
				let prefix = string[string.startIndex ..< range.lowerBound]
				attStr.append(NSAttributedString(string: handlePlainString(String(prefix))))
				
				/*handle attributedString*/
				let attributed = cachingAttributedString.removeFirst()
				attStr.append(attributed)
				/*handle attributedString end*/
				
				string = String(string[range.upperBound ..< string.endIndex])
			}
			let range = [Content.Placeholder.image, Content.Placeholder.attributedString]
				.compactMap { string.range(of: $0) }
				.sorted { $0.lowerBound < $1.lowerBound }
				.first
			if let range = range {
				switch String(string[range]) {
				case Content.Placeholder.image:
					appendImage(range: range)
				case Content.Placeholder.attributedString:
					appendAttributeString(range: range)
				default: break
				}
				continue
			}
			
			finish = true
		}
		if !string.isEmpty {
			attStr.append(NSAttributedString(string: handlePlainString(string)))
		}
		let para = NSMutableParagraphStyle()
		para.lineSpacing = 2
		attStr.addAttributes([
			.paragraphStyle: para
		], range: NSRange(location: 0, length: attStr.length))
		return attStr
	}
}

extension Text.StringInterpolation.Content {
	
	public mutating func appendInterpolation<Subject>(_ subject: Subject, formatter: Formatter? = nil) where Subject : ReferenceConvertible {

		appendLiteral(Placeholder.attributedString)
		let para = NSMutableParagraphStyle()
		para.lineSpacing = 2
		let atts = [
			NSAttributedString.Key.paragraphStyle: para
		]
		let subject = subject as Any
		let attstr = formatter?.attributedString(for: subject, withDefaultAttributes: atts) ?? NSMutableAttributedString(string: "\(subject)", attributes: atts)
		cachingAttributedString.append(attstr)
	}

	public mutating func appendInterpolation<Subject>(_ subject: Subject, formatter: Formatter? = nil) where Subject : NSObject {

		appendLiteral(Placeholder.attributedString)
		let para = NSMutableParagraphStyle()
		para.lineSpacing = 2
		let atts = [
			NSAttributedString.Key.paragraphStyle: para
		]
		let subject = subject as Any
		let attstr = formatter?.attributedString(for: subject, withDefaultAttributes: atts) ?? NSMutableAttributedString(string: "\(subject)", attributes: atts)
		cachingAttributedString.append(attstr)
	}
}
extension Text.StringInterpolation.Content {
	//编译器bug, 当存在两条并且其中一条有多个参数的时候, 自动补全就不显示那条多参数的, 所以这里加一条方便提示, 等这个bug修了可以去掉
	public mutating func appendInterpolation(_ image: UIImage) {
		appendLiteral(Placeholder.image)
		cachingImage.append((image, nil, nil, -2))
	}
}
