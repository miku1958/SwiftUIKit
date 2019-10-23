//
//  Text.swift
//  Font
//
//  Created by mikun on 2019/8/16.
//  Copyright © 2019 庄黛淳华. All rights reserved.
//

import UIKit
import SwiftUI

/// A view that displays one or more lines of read-only text.
@available(iOS 9.0, *)//OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public struct Text {
	fileprivate var _text: NSMutableAttributedString
	var useTap = false
	var useLongPress = false
	
	var lineLimit: Int?
	var minimumScaleFactor: CGFloat?
	
	private func attribute(_ key: NSAttributedString.Key) -> [(value: Any?, range: NSRange)]? {
		
		var index = 0
		var result: [(value: Any?, range: NSRange)] = []
		while index < _text.length {
			var range: NSRange = NSRange()
			let attribute = _text.attribute(key, at: index, effectiveRange: &range)
			if range.length > 0 {
				result.append((attribute, range))
				index += range.length
			} else {
				break
			}
		}
		return result
	}
	static var defaultFont: Font {
		Font.system(size: 17, weight: .regular)
	}
	public var text: NSAttributedString {
		if let atts = attribute(.font), !atts.isEmpty {
			for att in atts where att.value == nil {
				addAttribute(.font, value: Self.defaultFont.uiFont, range: att.range)
			}
		}
		let color = attribute(.foregroundColor)?.first?.value
		if let atts = attribute(.underlineColor) {
			for att in atts where (att.value as? NSNull) != nil {
				addAttribute(.underlineColor, value: color, range: att.range)
			}
		}
		if let atts = attribute(.strikethroughColor) {
			for att in atts where (att.value as? NSNull) != nil {
				addAttribute(.strikethroughColor, value: color, range: att.range)
			}
		}
		
		return _text
	}
	static func chekPlaceholderIn(string: inout String, to attStr: NSMutableAttributedString) {
		var finish = false
		while !finish {
			typealias Interceptor = String.StringInterpolation.Interceptor
			func appendImage(range: Range<String.Index>) {
				let prefix = string[string.startIndex ..< range.lowerBound]
				attStr.append(NSAttributedString(string: String(prefix)))
				
				/*handle image*/
				let image = Interceptor.default.cachingImage.removeFirst()
				
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
				attStr.append(NSAttributedString(string: String(prefix)))
				
				/*handle attributedString*/
				let attributed = Interceptor.default.cachingAttributedString.removeFirst()
				attStr.append(attributed)
				/*handle attributedString end*/
				
				string = String(string[range.upperBound ..< string.endIndex])
			}
			let range = [Interceptor.imagePlaceholder, Interceptor.attributedPlaceholder]
				.compactMap { string.range(of: $0) }
				.sorted { $0.lowerBound < $1.lowerBound }
				.first
			if let range = range {
				switch String(string[range]) {
				case Interceptor.imagePlaceholder:
					appendImage(range: range)
				case Interceptor.attributedPlaceholder:
					appendAttributeString(range: range)
				default: break
				}
				continue
			}
			
			finish = true
		}
	}
	static func createAttributed(string: String) -> NSMutableAttributedString {
		let attStr = NSMutableAttributedString()
		var string = string
		chekPlaceholderIn(string: &string, to: attStr)
		if !string.isEmpty {
			attStr.append(NSAttributedString(string: string))
		}
		let para = NSMutableParagraphStyle()
		para.lineSpacing = 2
		attStr.addAttributes([
			.paragraphStyle: para
		], range: NSRange(location: 0, length: attStr.length))
		return attStr
	}
	/// Creates an instance that displays `content` verbatim. 原样逐字返回字符串
	public init(verbatim content: String) {
		_text = Self.createAttributed(string: content)
	}
	
	/// Creates an instance that displays `content` verbatim. 先检查本地化, 如果没有再原样逐字返回字符串
	public init<S>(_ content: S) where S : StringProtocol {
		let str = String(content)
		_text = Self.createAttributed(string: Bundle.main.localizedString(forKey: str, value: str, table: nil))
	}
	
	/// Creates text that displays localized content identified by a key.
	///
	/// - Parameters:
	///     - key: The key for a string in the table identified by `tableName`.
	///     - tableName: The name of the string table to search. If `nil`, uses
	///       the table in `Localizable.strings`.
	///     - bundle: The bundle containing the strings file. If `nil`, uses the
	///       main `Bundle`.
	///     - comment: Contextual information about this key-value pair.
	public init(_ key: LocalizedStringKey, tableName: String? = nil, bundle: Bundle? = nil, comment: StaticString? = nil) {
		_text = Self.createAttributed(string: (bundle ?? Bundle.main).localizedString(forKey: key.value, value: nil, table: tableName))
	}
}


extension Text {
	public static func + (lhs: Text, rhs: Text) -> Text {
		var text = lhs
		text._text = lhs._text.mutableCopy() as! NSMutableAttributedString
		text._text.append(rhs._text)
		text.useLongPress = lhs.useLongPress || rhs.useLongPress
		text.useTap = text.useTap || rhs.useTap
		text.lineLimit = rhs.lineLimit ?? lhs.lineLimit
		text.minimumScaleFactor = rhs.minimumScaleFactor ?? lhs.minimumScaleFactor
		return text
	}
	public static func + (lhs: Text, rhs: [Text]) -> Text {
		var text = lhs
		rhs.forEach {
			text = text + $0
		}
		return text
	}
}
extension Text {
	@discardableResult
	func addAttribute(_ key: NSAttributedString.Key, value: Any?, range: NSRange? = nil) -> Text {
		let range = range ?? NSRange(location: 0, length: _text.length)
		if let value = value {
			_text.addAttribute(key, value: value, range: range)
		} else {
			_text.removeAttribute(key, range: range)
		}
		return self
	}
	func changeParagraphStyle(_ handler: (NSMutableParagraphStyle) -> Void) -> Text {
		let para = _text.attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSParagraphStyle ?? NSMutableParagraphStyle()
		if let para = para as? NSMutableParagraphStyle {
			handler(para)
			return addAttribute(.paragraphStyle, value: para)
		} else if let para = para.mutableCopy() as? NSMutableParagraphStyle {
			handler(para)
			return addAttribute(.paragraphStyle, value: para)
		}
		return self
	}
}
extension Text {

	/// Sets the color of this text.
	///
	/// - Parameter color: The color to use when displaying this text.
	/// - Returns: Text that uses the color value you supply.
	public func foregroundColor(_ color: Color?) -> Text {
		addAttribute(.foregroundColor, value: color?.uiColor)
	}
	
	public func background(_ background: Color) -> Text {
		addAttribute(.backgroundColor, value: background.uiColor)
	}
	
	/// Sets the font to use when displaying this text.
	///
	/// - Parameter font: The font to use when displaying this text.
	/// - Returns: Text that uses the font you specify.
	public func font(_ font: Font?) -> Text {
		addAttribute(.font, value: font?.uiFont)
	}
	
	func handleFont(_ handler: (Font) -> Font) -> Text {
		if let uiFont = _text.attribute(.font, at: 0, effectiveRange: nil) as? UIFont {
			return font(handler(Font(uiFont)))
		} else {
			return font(handler(Self.defaultFont))
		}
	}
	/// Sets the font weight of this text.
	///
	/// - Parameter weight: One of the available font weights.
	/// - Returns: Text that uses the font weight you specify.
	public func fontWeight(_ weight: UIFont.Weight?) -> Text {
		handleFont {
			$0.weight(weight ?? .regular)
		}
	}
	
	/// Applies a bold font weight to this text.
	///
	/// - Returns: Bold text.
	public func bold() -> Text {
		handleFont {
			$0.bold()
		}
	}
	
	/// Applies italics to this text.
	///
	/// - Returns: Italic text.
	public func italic() -> Text {
		handleFont {
			$0.italic()
		}
	}
	
	/// Applies a strikethrough to this text.
	///
	/// - Parameters:
	///   - active: A Boolean value that indicates whether the text has a
	///     strikethrough applied.
	///   - color: The color of the strikethrough. If `color` is `nil`, the
	///     strikethrough uses the default foreground color.
	/// - Returns: Text with a line through its center.
	public func strikethrough(_ active: Bool = true, color: Color? = nil) -> Text {
		addAttribute(.strikethroughColor, value: active ? color?.uiColor : nil)
		addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue)

		if active && color == nil {
			addAttribute(.strikethroughColor, value: NSNull())
		}
		return self
	}
	
	/// Applies an underline to this text.
	///
	/// - Parameters:
	///   - active: A Boolean value that indicates whether the text has an
	///     underline.
	///   - color: The color of the underline. If `color` is `nil`, the
	///     underline uses the default foreground color.
	/// - Returns: Text with a line running along its baseline.
	public func underline(_ active: Bool = true, color: Color? = nil) -> Text {
		addAttribute(.underlineColor, value: active ? color?.uiColor : nil)
		addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue)
		
		if active && color == nil {
			addAttribute(.underlineColor, value: NSNull())
		}
		return self
	}
	
	/// Sets the kerning for this text.
	///
	/// - Parameter kerning: How many points the following character should be
	///   shifted from its default offset as defined by the current character's
	///   font in points; a positive kerning indicates a shift farther along
	///   and a negative kern indicates a shift closer to the current character.
	/// - Returns: Text with the specified amount of kerning.
	public func kerning(_ kerning: CGFloat) -> Text {
		addAttribute(.kern, value: kerning)
	}
	
	/// Sets the tracking for this text.
	///
	/// - Parameter tracking: The tracking attribute indicates how much
	///   additional space, in points, should be added to each character cluster
	///   after layout. The effect of this attribute is similar to `kerning()`
	///   but differs in that the added tracking is treated as trailing
	///   whitespace and a non-zero amount disables non-essential ligatures.
	/// - Returns: Text with the specified amount of tracking.
	///   If both `kerning()` and `tracking()` are present, `kerning()` will be
	///   ignored; `tracking()` will still be honored.
	///   Using kCTTrackingAttributeName imported in iOS 10, not working in iOS 9
	
	public func tracking(_ tracking: CGFloat) -> Text {
		if #available(iOS 10.0, *) {
			return addAttribute(kCTTrackingAttributeName as NSAttributedString.Key, value: tracking)
		} else {
			return self
		}
	}
	
	/// Sets the baseline offset for this text.
	///
	/// - Parameter baselineOffset: The amount to shift the text vertically
	///   (up or down) in relation to its baseline.
	/// - Returns: Text that's above or below its baseline.
	public func baselineOffset(_ baselineOffset: CGFloat) -> Text {
		addAttribute(.baselineOffset, value: baselineOffset)
	}
	
	/// Sets the shadow for this text.
	///
	/// - Parameter shadowOffset: offset in user space of the shadow from the original drawing
	/// - Parameter shadowBlurRadius: blur radius of the shadow in default user space units
	/// - Parameter shadowColor: color used for the shadow (default is black with an alpha value of 1/3)
	/// - Returns: Text that's above or below its shadow.
	public func shadow(_ shadowOffset: CGSize, shadowBlurRadius: CGFloat, shadowColor: Color? = nil) -> Text {
		let shadow = NSShadow()
		shadow.shadowOffset = shadowOffset
		shadow.shadowBlurRadius = shadowBlurRadius
		if let color = shadowColor?.uiColor {
			shadow.shadowColor = color
		}
		return addAttribute(.shadow, value: shadow)
	}
	
	/// Sets the shadow for this text.
	///
	/// - Parameter shadowOffset: offset in user space of the shadow from the original drawing
	/// - Parameter shadowBlurRadius: blur radius of the shadow in default user space units
	/// - Parameter shadowColor: color used for the shadow (default is black with an alpha value of 1/3)
	/// - Returns: Text that's above or below its shadow.
	public func shadow(_ shadowOffset: CGSize, shadowBlurRadius: CGFloat, shadowColor: UIColor) -> Text {
		return shadow(shadowOffset, shadowBlurRadius: shadowBlurRadius, shadowColor: Color(shadowColor))
	}
	
	/// Sets the shadow for this text.
	///
	/// - Parameter shadow: default NSShadow
	/// - Returns: Text that's above or below its shadow.
	public func shadow(_ shadow: NSShadow = NSShadow()) -> Text {
		return addAttribute(.shadow, value: shadow)
	}
}

extension Text {
	static let longPressKey = NSAttributedString.Key("longPressKey")
	typealias LongPressInfo = (minimumDuration: TimeInterval, maximumDistance: CGFloat, pressing: ((Bool) -> Void)?, action: () -> Void)
	
    /// Returns a version of `self` that will invoke `action` after
    /// recognizing a longPress gesture.
	public func onLongPressGesture(minimumDuration: TimeInterval = 0.5, maximumDistance: CGFloat = 10, pressing: ((Bool) -> Void)? = nil, perform action: @escaping () -> Void) -> Text {
		var text = self
		text.useLongPress = true
		let value: LongPressInfo = (minimumDuration, maximumDistance, pressing, action)
		return text.addAttribute(Self.longPressKey, value: value)
	}
	
	static let tapKey = NSAttributedString.Key("tapKey")
	typealias TapInfo = (count: Int, action: () -> Void)
	
    /// Returns a version of `self` that will invoke `action` after
    /// recognizing a tap gesture.
	public func onTapGesture(count: Int = 1, perform action: @escaping () -> Void) -> Text {
		var text = self
		text.useTap = true
		let value: TapInfo = (count, action)
		return text.addAttribute(Self.tapKey, value: value)
	}
}

extension Text {
	/// How text is truncated when a line of text is too long to fit into the
	/// available space.
	public enum TruncationMode {
		
		case head
		
		case tail
		
		case middle
	}
	public enum TextAlignment : Hashable, CaseIterable {

		case leading

		case center

		case trailing
	}
    /// Sets the alignment of multiline text in this view.
    ///
    /// - Parameter alignment: A value you use to align lines of text to the
    ///   left, right, or center.
    /// - Returns: A view that aligns the lines of multiline `Text` instances
    ///   it contains.
	public func multilineTextAlignment(_ alignment: TextAlignment) -> Text {
		changeParagraphStyle { (para) in
			switch alignment {
			case .leading:
				para.alignment = .left
			case .center:
				para.alignment = .center
			case .trailing:
				para.alignment = .right
			}
		}
	}


    /// Sets the truncation mode for lines of text that are too long to fit in
    /// the available space.
    ///
    /// Use the `truncationMode(_:)` modifier to determine whether text in a
    /// long line is truncated at the beginning, middle, or end. Truncation
    /// adds an ellipsis (…) to the line when removing text to indicate to
    /// readers that text is missing.
    ///
    /// - Parameter mode: The truncation mode.
    /// - Returns: A view that truncates text at different points in a line
    ///   depending on the mode you select.
	public func truncationMode(_ mode: TruncationMode) -> Text {
		changeParagraphStyle { (para) in
			switch mode {
			case .head:
				para.lineBreakMode = .byTruncatingHead
			case .tail:
				para.lineBreakMode = .byTruncatingTail
			case .middle:
				para.lineBreakMode = .byTruncatingMiddle
			}
		}
	}


    /// Sets the amount of space between lines of text in this view.
    ///
    /// - Parameter lineSpacing: The amount of space between the bottom of one
    ///   line and the top of the next line.
    public func lineSpacing(_ lineSpacing: CGFloat) -> Text {
		changeParagraphStyle { (para) in
			para.lineSpacing = lineSpacing
		}
	}


    /// Sets whether text in this view can compress the space between characters
    /// when necessary to fit text in a line.
    ///
    /// - Parameter flag: A Boolean value that indicates whether the space
    ///   between characters compresses when necessary.
    /// - Returns: A view that can compress the space between characters when
    ///   necessary to fit text in a line.
	public func allowsTightening(_ flag: Bool) -> Text {
		changeParagraphStyle { (para) in
			para.allowsDefaultTighteningForTruncation = flag
		}
	}


    /// Sets the maximum number of lines that text can occupy in this view.
    ///
    /// The line limit applies to all `Text` instances within this view. For
    /// example, an `HStack` with multiple pieces of text longer than three
    /// lines caps each piece of text to three lines rather than capping the
    /// total number of lines across the `HStack`.
    ///
    /// - Parameter number: The line limit. If `nil`, no line limit applies.
    /// - Returns: A view that limits the number of lines that `Text` instances
    ///   display.
    ///
    /// - Note: a non-nil `number` less than 1 will be treated as 1.
	public func lineLimit(_ number: Int?) -> Text {
		var text = self
		text.lineLimit = number
		return text
	}


    /// Sets the minimum amount that text in this view scales down to fit in the
    /// available space.
    ///
    /// Use the `minimumScaleFactor(_:)` modifier if the text you place in a
    /// view doesn't fit and it's okay if the text shrinks to accommodate.
    /// For example, a label with a `minimumScaleFactor` of `0.5` draws its
    /// text in a font size as small as half of the actual font if needed.
    ///
    /// - Parameter factor: A fraction between 0 and 1 (inclusive) you use to
    ///   specify the minimum amount of text scaling that this view permits.
    /// - Returns: A view that limits the amount of text downscaling.
	public func minimumScaleFactor(_ factor: CGFloat) -> Text {
		var text = self
		text.minimumScaleFactor = factor
		return text
	}
}
