//
//  Text.swift
//  Font
//
//  Created by mikun on 2019/8/16.
//  Copyright © 2019 庄黛淳华. All rights reserved.
//

import UIKit

public protocol TextProtocol {
	var mainText: Text { get }
}

/// A view that displays one or more lines of read-only text.
@available(iOS 9.0, *)//OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public struct Text {
	fileprivate var _text: NSMutableAttributedString
	var useTap = false
	var useLongPress = false
	
	var lineLimit: Int?
	var minimumScaleFactor: CGFloat?
	
	/// 查找_text里所有subString里key对应的属性
	private func attribute(_ key: NSAttributedString.Key) -> [(value: Any?, range: NSRange)]? {
		var index = 0
		var result: [(value: Any?, range: NSRange)] = []
		while index < _text.length {
			var range: NSRange = NSRange()
			let attribute = _text.attribute(key, at: index, effectiveRange: &range)
			result.append((attribute, range))
			index += range.length
		}
		return result
	}
	var defaultFont = Font.system(size: 17, weight: .regular)
	public var text: NSAttributedString {
		if let atts = attribute(.font), !atts.isEmpty {
			for att in atts where att.value == nil {
				addAttribute(.font, value: defaultFont.uiFont, range: att.range)
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

	/// Creates an instance that displays `content` verbatim. 原样逐字返回字符串
	public init(verbatim content: LocalizedStringKey) {
		_text = content.attritubedString()
	}
	
	/// Creates an instance that displays `content` verbatim. 先检查本地化, 如果没有再原样逐字返回字符串
	public init(_ content: LocalizedStringKey) {
		_text = content.attritubedString(withlocalized: Bundle.main, tableName: nil, useDefaultValue: true)
	}
	public typealias LocalizedStringKey = String
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
		_text = key.attritubedString(withlocalized: bundle, tableName: tableName, useDefaultValue: false)
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
	public static func += (lhs: inout Text, rhs: Text) {
		lhs = lhs + rhs
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
		guard _text.length > 0 else { return self }
		let para = (_text.attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSParagraphStyle).mutableCopyIfNeed()
		handler(para)
		addAttribute(.paragraphStyle, value: para)
		return self
	}
}
extension TextProtocol {
	
	/// Sets the color of this text.
	///
	/// - Parameter color: The color to use when displaying this text.
	/// - Returns: Text that uses the color value you supply.
	public func foregroundColor(_ color: UIColor?) -> Text {
		mainText.addAttribute(.foregroundColor, value: color)
	}
	
	public func background(_ background: UIColor) -> Text {
		mainText.addAttribute(.backgroundColor, value: background)
	}
	
	/// Sets the font to use when displaying this text.
	///
	/// - Parameter font: The font to use when displaying this text.
	/// - Returns: Text that uses the font you specify.
	public func font(_ font: Font?) -> Text {
		mainText.addAttribute(.font, value: font?.uiFont)
	}
	
	/// Sets the font to use when displaying this text.
	///
	/// - Parameter font: The font to use when displaying this text.
	/// - Returns: Text that uses the font you specify.
	public func font(_ font: UIFont?) -> Text {
		mainText.addAttribute(.font, value: font)
	}
	
	func handleFont(_ handler: (Font) -> Font) -> Text {
		let text = mainText
		if let uiFont = text._text.attribute(.font, at: 0, effectiveRange: nil) as? UIFont {
			return font(handler(Font(uiFont)))
		} else {
			return font(handler(text.defaultFont))
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
	public func strikethrough(_ active: Bool = true, color: UIColor? = nil) -> Text {
		let text = mainText
		text.addAttribute(.strikethroughColor, value: active ? color : nil)
		text.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue)
		
		if active && color == nil {
			text.addAttribute(.strikethroughColor, value: NSNull())
		}
		return text
	}
	
	/// Applies an underline to this text.
	///
	/// - Parameters:
	///   - active: A Boolean value that indicates whether the text has an
	///     underline.
	///   - color: The color of the underline. If `color` is `nil`, the
	///     underline uses the default foreground color.
	/// - Returns: Text with a line running along its baseline.
	public func underline(_ active: Bool = true, color: UIColor? = nil) -> Text {
		let text = mainText
		text.addAttribute(.underlineColor, value: active ? color : nil)
		text.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue)
		
		if active && color == nil {
			text.addAttribute(.underlineColor, value: NSNull())
		}
		return text
	}
	
	/// Sets the kerning for this text.
	///
	/// - Parameter kerning: How many points the following character should be
	///   shifted from its default offset as defined by the current character's
	///   font in points; a positive kerning indicates a shift farther along
	///   and a negative kern indicates a shift closer to the current character.
	/// - Returns: Text with the specified amount of kerning.
	public func kerning(_ kerning: CGFloat) -> Text {
		mainText.addAttribute(.kern, value: kerning)
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
		let text = mainText
		if #available(iOS 10.0, *) {
			return text.addAttribute(kCTTrackingAttributeName as NSAttributedString.Key, value: tracking)
		} else {
			return text
		}
	}
	
	/// Sets the baseline offset for this text.
	///
	/// - Parameter baselineOffset: The amount to shift the text vertically
	///   (up or down) in relation to its baseline.
	/// - Returns: Text that's above or below its baseline.
	public func baselineOffset(_ baselineOffset: CGFloat) -> Text {
		mainText.addAttribute(.baselineOffset, value: baselineOffset)
	}
	
	/// Sets the shadow for this text.
	///
	/// - Parameter shadowOffset: offset in user space of the shadow from the original drawing
	/// - Parameter shadowBlurRadius: blur radius of the shadow in default user space units
	/// - Parameter shadowColor: color used for the shadow (default is black with an alpha value of 1/3)
	/// - Returns: Text that's above or below its shadow.
	public func shadow(_ shadowOffset: CGSize, shadowBlurRadius: CGFloat, shadowColor: UIColor? = nil) -> Text {
		let shadow = NSShadow()
		shadow.shadowOffset = shadowOffset
		shadow.shadowBlurRadius = shadowBlurRadius
		if let color = shadowColor {
			shadow.shadowColor = color
		}
		return mainText.addAttribute(.shadow, value: shadow)
	}

	/// Adds a shadow to this view.
    ///
    /// - Parameters:
    ///   - color: The shadow's color.
    ///   - radius: The shadow's size.
    ///   - x: A horizontal offset you use to position the shadow relative to
    ///     this view.
    ///   - y: A vertical offset you use to position the shadow relative to
    ///     this view.
    /// - Returns: A view that adds a shadow to this view.
	public func shadow(color: UIColor = UIColor(.sRGB, white: 0, opacity: 0.33), radius: CGFloat, x: CGFloat = 0, y: CGFloat = 0) -> Text {
		shadow(CGSize(width: x, height: y), shadowBlurRadius: radius, shadowColor: color)
	}
	
	/// Sets the shadow for this text.
	///
	/// - Parameter shadow: default NSShadow
	/// - Returns: Text that's above or below its shadow.
	public func shadow(_ shadow: NSShadow) -> Text {
		return mainText.addAttribute(.shadow, value: shadow)
	}
}

extension Text {
	static let longPressKey = NSAttributedString.Key("longPressKey")
	typealias LongPressInfo = (minimumDuration: TimeInterval, maximumDistance: CGFloat, pressing: ((Bool) -> Void)?, action: () -> Void)
	static let tapKey = NSAttributedString.Key("tapKey")
	typealias TapInfo = (count: Int, action: () -> Void)
}

extension TextProtocol {
    /// Returns a version of `self` that will invoke `action` after
    /// recognizing a longPress gesture.
	public func onLongPressGesture(minimumDuration: TimeInterval = 0.5, maximumDistance: CGFloat = 10, pressing: ((Bool) -> Void)? = nil, perform action: @escaping () -> Void) -> Text {
		var text = mainText
		text.useLongPress = true
		let value: Text.LongPressInfo = (minimumDuration, maximumDistance, pressing, action)
		return text.addAttribute(Text.longPressKey, value: value)
	}
	
    /// Returns a version of `self` that will invoke `action` after
    /// recognizing a tap gesture.
	public func onTapGesture(count: Int = 1, perform action: @escaping () -> Void) -> Text {
		var text = mainText
		text.useTap = true
		let value: Text.TapInfo = (count, action)
		return text.addAttribute(Text.tapKey, value: value)
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
	public enum Alignment : Hashable, CaseIterable {
		
		case leading
		
		case center
		
		case trailing
	}
}

extension TextProtocol {
    /// Sets the alignment of multiline text in this view.
    ///
    /// - Parameter alignment: A value you use to align lines of text to the
    ///   left, right, or center.
    /// - Returns: A view that aligns the lines of multiline `Text` instances
    ///   it contains.
	public func multilineTextAlignment(_ alignment: Text.Alignment) -> Text {
		mainText.changeParagraphStyle { (para) in
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
	public func truncationMode(_ mode: Text.TruncationMode) -> Text {
		mainText.changeParagraphStyle { (para) in
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
		mainText.changeParagraphStyle { (para) in
			para.lineSpacing = lineSpacing
		}
	}
    /// Sets the amount of height of each line of text in this view.
    ///
    /// - Parameter lineHeight: The amount of height of each line
    public func lineHeight(_ lineHeight: CGFloat) -> Text {
		mainText.changeParagraphStyle { (para) in
			para.maximumLineHeight = lineHeight
			para.minimumLineHeight = lineHeight
		}
	}
	
	/// Sets the amount of height of each line of text in this view.
	///
	/// - Parameter lineHeight: The range of height of each line
	public func lineHeight(_ lineHeight: ClosedRange<CGFloat>) -> Text {
		mainText.changeParagraphStyle { (para) in
			para.maximumLineHeight = lineHeight.upperBound
			para.minimumLineHeight = lineHeight.lowerBound
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
		mainText.changeParagraphStyle { (para) in
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
		var text = mainText
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
		var text = mainText
		text.minimumScaleFactor = factor
		return text
	}
}
extension Text {
	public var count: Int {
		_text.length
	}
}


extension Text: TextProtocol {
	public var mainText: Text {
		self
	}
}

extension Text: ExpressibleByStringLiteral {
	public init(stringLiteral value: String) {
		self.init(value)
	}
	public init(_ convertible: CustomStringConvertible) {
		self.init("\(convertible)")
	}
}

extension Text: Equatable {
	public static func == (lhs: Self, rhs: Self) -> Bool {
		lhs._text == rhs._text
	}
}

extension String: TextProtocol {
	public var mainText: Text {
		Text(self)
	}
}

extension Array: TextProtocol where Element: TextProtocol {
	public var mainText: Text {
		reduce(Text(""), {
			$0.mainText + $1.mainText
		})
	}
}
