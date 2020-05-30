//
//  String.StringInterpolation.Interceptor.swift
//  Font
//
//  Created by mikun on 2019/8/23.
//  Copyright © 2019 庄黛淳华. All rights reserved.
//

import UIKit
class Interceptor {
	static let `default` = Interceptor()
	
	lazy var cachingImage: [String: (image: UIImage, width: CGFloat?, height: CGFloat?, offset: CGFloat)] = [:]
	lazy var cachingAttributedString: [String: NSAttributedString] = [:]
	
	enum Placeholder {
		case image
		case attributedString
		
		var begin: String {
			switch self {
			case .image:
				return "\u{FFF9}\u{FFFC}\u{FFFA}"
			case .attributedString:
				return "\u{FFF9}\u{FFFC}\u{FFFC}\u{FFFA}"
			}
		}
		static let end = "\u{FFFB}\u{FFFC}\u{FFFA}"
		func new(_ obj: CustomStringConvertible) -> String {
			begin + "\(obj)" + Self.end
		}
	}
}

extension String.StringInterpolation {
	public mutating func appendInterpolation(_ image: UIImage?, width: CGFloat? = nil, height: CGFloat? = nil, offset: CGFloat = -2) {
		guard let image = image else { return }
		let placeholder = Interceptor.Placeholder.image.new(image)
		appendLiteral(placeholder)
		Interceptor.default.cachingImage[placeholder] = (image, width, height, offset)
	}
	public mutating func appendInterpolation(_ image: UIImage, width: CGFloat? = nil, height: CGFloat? = nil, offset: CGFloat = -2) {
		let placeholder = Interceptor.Placeholder.image.new(image)
		appendLiteral(placeholder)
		Interceptor.default.cachingImage[placeholder] = (image, width, height, offset)
	}

	public mutating func appendInterpolation(_ attStr: NSAttributedString) {
		let placeholder = Interceptor.Placeholder.attributedString.new(attStr)
		appendLiteral(placeholder)
		Interceptor.default.cachingAttributedString[placeholder] = attStr
	}
}
extension String {
	func attritubedString(withlocalized bundle: Bundle? = nil, tableName: String? = nil, useDefaultValue: Bool) -> NSMutableAttributedString {
		checkPlaceholder(in: self) {
			(bundle ?? Bundle.main).localizedString(forKey: $0, value: useDefaultValue ? $0 : nil, table: tableName)
		}
	}
	func attritubedString() -> NSMutableAttributedString {
		checkPlaceholder(in: self) { $0 }
	}
	func checkPlaceholder(in string: String, handlePlainString: (String) -> String) -> NSMutableAttributedString {
		let attStr = NSMutableAttributedString()
		var string = string
		var finish = false
		while !finish {
			func appendImage(range: Range<String.Index>) {
				let prefix = string[string.startIndex ..< range.lowerBound]
				attStr.append(NSAttributedString(string: handlePlainString(String(prefix))))
				defer {
					string = String(string[range.upperBound ..< string.endIndex])
				}
				let key = String(string[range])
				guard let image = Interceptor.default.cachingImage.removeValue(forKey: key) else { return }
				
				/*handle image*/
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
			}
			func appendAttributeString(range: Range<String.Index>) {
				let prefix = string[string.startIndex ..< range.lowerBound]
				attStr.append(NSAttributedString(string: handlePlainString(String(prefix))))
				defer {
					string = String(string[range.upperBound ..< string.endIndex])
				}
				let key = String(string[range])
				guard let attributed = Interceptor.default.cachingAttributedString.removeValue(forKey: key) else { return }
				
				/*handle attributedString*/
				attStr.append(attributed)
				/*handle attributedString end*/
			}
			let beginRange = [Interceptor.Placeholder.image.begin, Interceptor.Placeholder.attributedString.begin]
				.compactMap { string.range(of: $0) }
				.sorted { $0.lowerBound < $1.lowerBound }
				.first
			if let beginRange = beginRange, let endRange = string.range(of: Interceptor.Placeholder.end) {
				let range = Range<String.Index>(uncheckedBounds: (beginRange.lowerBound, endRange.upperBound))
				switch String(string[beginRange]) {
				case Interceptor.Placeholder.image.begin:
					appendImage(range: range)
				case Interceptor.Placeholder.attributedString.begin:
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

extension String.StringInterpolation {

	public mutating func appendInterpolation<Subject>(_ subject: Subject, formatter: Formatter? = nil) where Subject : ReferenceConvertible {
		let placeholder = Interceptor.Placeholder.attributedString.new("\(subject)")
		appendLiteral(placeholder)
		let para = NSMutableParagraphStyle()
		para.lineSpacing = 2
		let atts = [
			NSAttributedString.Key.paragraphStyle: para
		]
		let subject = subject as Any
		let attstr = formatter?.attributedString(for: subject, withDefaultAttributes: atts) ?? NSMutableAttributedString(string: "\(subject)", attributes: atts)
		Interceptor.default.cachingAttributedString[placeholder] = attstr
	}
	
	public mutating func appendInterpolation<Subject>(_ subject: Subject, formatter: Formatter? = nil) where Subject : NSObject {
		let placeholder = Interceptor.Placeholder.attributedString.new("\(subject)")
		appendLiteral(placeholder)
		let para = NSMutableParagraphStyle()
		para.lineSpacing = 2
		let atts = [
			NSAttributedString.Key.paragraphStyle: para
		]
		let subject = subject as Any
		let attstr = formatter?.attributedString(for: subject, withDefaultAttributes: atts) ?? NSMutableAttributedString(string: "\(subject)", attributes: atts)
		Interceptor.default.cachingAttributedString[placeholder] = attstr
	}
}
extension String.StringInterpolation {
	//编译器bug, 当存在两条并且其中一条有多个参数的时候, 自动补全就不显示那条多参数的, 所以这里加一条方便提示, 等这个bug修了可以去掉
	public mutating func appendInterpolation(_ image: UIImage?) {
		guard let image = image else { return }
		let placeholder = Interceptor.Placeholder.image.new(image)
		appendLiteral(placeholder)
		Interceptor.default.cachingImage[placeholder] = (image, nil, nil, -2)
	}
}
