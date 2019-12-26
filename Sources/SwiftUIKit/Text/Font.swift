//
//  Font.swift
//  FontDemo
//
//  Created by mikun on 2019/8/16.
//  Copyright © 2019 庄黛淳华. All rights reserved.
//

import UIKit

@available(iOS 9.0, *)//, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public struct Font {
	private var _customFont: UIFont?
	private var _size: CGFloat = 18
	private var _weight: UIFont.Weight?
	private var _useMonospacedDigit = false
	private var _style: UIFont.TextStyle?
	private var _traits: UIFontDescriptor.SymbolicTraits = []
	private var _design: Any? //UIFontDescriptor.SystemDesign
	private var _lowercaseSmallCaps = false
	private var _uppercaseSmallCaps = false
	
	///create UIFont object
	var uiFont: UIFont {
		var font: UIFont
		if let _customFont = _customFont {
			font = _customFont;
		} else if let _style = _style {
			font = UIFont.preferredFont(forTextStyle: _style)
		} else {
			font = UIFont.systemFont(ofSize: _size, weight: _weight ?? .regular)
		}

		var fontDes = font.fontDescriptor;
		
		if let _weight = _weight {
			var traits = fontDes.object(forKey: .traits) as? [UIFontDescriptor.TraitKey: Any] ?? [:]
			traits[.weight] = _weight
			fontDes.addingAttributes([.traits: traits])
		}
		
		if !_traits.isEmpty {
			fontDes = fontDes.withSymbolicTraits(_traits) ?? fontDes
		}
		
		if #available(iOS 13.0, *), let _design = _design as? UIFontDescriptor.SystemDesign {
			fontDes = fontDes.withDesign(_design) ?? fontDes
		}
		if (_useMonospacedDigit) {
			fontDes = fontDes.addingAttributes([
				.featureSettings: [
						[
							UIFontDescriptor.FeatureKey.featureIdentifier : kNumberSpacingType,
							UIFontDescriptor.FeatureKey.typeIdentifier : kDefaultLowerCaseSelector
						]
				]
			])
		}
		if (_lowercaseSmallCaps) {
			// source: https://stackoverflow.com/questions/4810409/does-coretext-support-small-caps
			fontDes = fontDes.addingAttributes([
				.featureSettings: [
						[
							UIFontDescriptor.FeatureKey.featureIdentifier : kLowerCaseType,
							UIFontDescriptor.FeatureKey.typeIdentifier : kLowerCaseSmallCapsSelector
						]
				]
			])
		}
		if (_uppercaseSmallCaps) {
			fontDes = fontDes.addingAttributes([
				.featureSettings: [
						[
							UIFontDescriptor.FeatureKey.featureIdentifier : kUpperCaseType,
							UIFontDescriptor.FeatureKey.typeIdentifier : kUpperCaseSmallCapsSelector
						]
				]
			])
		}
		return UIFont(descriptor: fontDes, size: 0)
	}
}

extension Font {

    /// Create a version of `self` that is italic.
	public func italic() -> Font {
		var font = self
		font._traits.formUnion(.traitItalic)
		return font
	}

    /// Create a version of `self` that uses both lowercase and uppercase small
    /// capitals.
    ///
    /// - See Also: `Font.lowercaseSmallCaps()` and `Font.uppercaseSmallCaps()`
    ///   for more details.
	public  func smallCaps() -> Font {
		var font = self
		font._lowercaseSmallCaps = true;
		font._uppercaseSmallCaps = true;
		return font
	}

    /// Create a version of `self` that uses lowercase small capitals.
    /// This feature turns lowercase characters into small capitals with
    /// OpenType or AAT feature. It is generally used for display lines set in
    /// large & small caps, such as titles. Glyphs related to small capitals,
    /// such as oldstyle figures, may be included.
	public func lowercaseSmallCaps() -> Font {
		var font = self
		font._lowercaseSmallCaps = true;
		return font
	}

    /// Create a version of `self` that uses uppercase small capitals.
    /// This feature turns capital characters into small capitals. It is
    /// generally used for words which would otherwise be set in all caps, such
    /// as acronyms, but which are desired in small-cap shape to avoid
    /// disrupting the flow of text.
	public func uppercaseSmallCaps() -> Font {
		var font = self
		font._uppercaseSmallCaps = true;
		return font
	}

    /// Create a version of `self` that uses monospace digits.
	public func monospacedDigit() -> Font {
		var font = self
		font._useMonospacedDigit = true;
		return font
	}

    /// Create a version of `self` that has the specified `weight`.
	public func weight(_ weight: UIFont.Weight) -> Font {
		var font = self
		font._weight = weight;
		return font
	}

    /// Create a version of `self` that is bold.
	public func bold() -> Font {
		var font = self
		font._traits.formUnion(.traitBold)
		return font
	}
}

extension Font {
    /// Create a font with the large title text style.
	@available(iOS 11, *)
	public static let largeTitle = Font.system(.largeTitle)

    /// Create a font with the title text style.
    public static let title = Font.system(.title)

    /// Create a font with the headline text style.
    public static var headline = Font.system(.headline)

    /// Create a font with the subheadline text style.
    public static var subheadline = Font.system(.subheadline)

    /// Create a font with the body text style.
    public static var body = Font.system(.body)

    /// Create a font with the callout text style.
    public static var callout = Font.system(.callout)

    /// Create a font with the footnote text style.
    public static var footnote = Font.system(.footnote)

    /// Create a font with the caption text style.
    public static var caption = Font.system(.caption)

	
    /// Create a system font with the given `style`.
	public static func system(_ style: TextStyle) -> Font {
		var font = Font()
		font._style = style.uiFontTextStyle
		return font
	}

    /// Create a system font with the given `size`, `weight` and `design`.
	public static func system(size: CGFloat, weight: UIFont.Weight = .regular) -> Font {
		var font = Font()
		font._size = size
		font._weight = weight
		return font
	}

    /// Create a custom font with the given `name` and `size`.
	public static func custom(_ name: String, size: CGFloat) -> Font {
		var font = Font()
		font._customFont = UIFont(name: name, size: size)
		font._size = size
		return font
	}

    /// Create a custom font with the given CTFont.
	public init(_ font: CTFont) {
		_customFont = font as UIFont
	}
	init(_ font: UIFont) {
		_customFont = font
	}

    /// A dynamic text style to use for fonts.
	public enum TextStyle {
		
		@available(iOS 11, *)
        case largeTitle

        case title

        case headline

        case subheadline

        case body

        case callout

        case footnote

        case caption
		
		var uiFontTextStyle: UIFont.TextStyle {
			switch self {
			case .largeTitle:
				if #available(iOS 11.0, *) {
					return .largeTitle
				}
			case .title:
				return .title1
			case .headline:
				return .headline
			case .subheadline:
				return .subheadline
			case .body:
				return .body
			case .callout:
				return .callout
			case .footnote:
				return .footnote
			case .caption:
				return .caption1
			}
			return UIFont.TextStyle(rawValue: "")
		}
    }
}



@available(iOS 13, *)//, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
extension Font {
	
    /// Create a system font with the given `style`and `design`
	public static func system(_ style: TextStyle, design: UIFontDescriptor.SystemDesign) -> Font {
		var font = Font.system(style)
		font._design = design
		return font
	}
	
	public static func system(size: CGFloat, weight: UIFont.Weight = .regular, design: UIFontDescriptor.SystemDesign) -> Font {
		var font = Font.system(size: size, weight: weight)
		font._design = design
		return font
	}
}
