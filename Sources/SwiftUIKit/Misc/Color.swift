//
//  Color.swift
//  Font
//
//  Created by mikun on 2019/8/16.
//  Copyright © 2019 庄黛淳华. All rights reserved.
//

import UIKit

/// An environment-dependent color.
///
/// A `Color` is a late-binding token - its actual value is only resolved
/// when it is about to be used in a given environment. At that time it is
/// resolved to a concrete value.
@available(iOS 9.0, *)//, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public struct Color : Hashable, CustomStringConvertible {
	private let color: UIColor
	public var uiColor: UIColor {
		color
	}
	/// Hashes the essential components of this value by feeding them into the
	/// given hasher.
	///
	/// Implement this method to conform to the `Hashable` protocol. The
	/// components used for hashing must be the same as the components compared
	/// in your type's `==` operator implementation. Call `hasher.combine(_:)`
	/// with each of these components.
	///
	/// - Important: Never call `finalize()` on `hasher`. Doing so may become a
	///   compile-time error in the future.
	///
	/// - Parameter hasher: The hasher to use when combining the components
	///   of this instance.
//	public func hash(into hasher: inout Hasher)
	
	/// Returns a Boolean value indicating whether two values are equal.
	///
	/// Equality is the inverse of inequality. For any values `a` and `b`,
	/// `a == b` implies that `a != b` is `false`.
	///
	/// - Parameters:
	///   - lhs: A value to compare.
	///   - rhs: Another value to compare.
	public static func == (lhs: Color, rhs: Color) -> Bool {
		return lhs.color.cgColor.components == rhs.color.cgColor.components && lhs.color.cgColor.colorSpace == rhs.color.cgColor.colorSpace
	}
	
	/// A textual representation of this instance.
	///
	/// Calling this property directly is discouraged. Instead, convert an
	/// instance of any type to a string by using the `String(describing:)`
	/// initializer. This initializer works with any type, and uses the custom
	/// `description` property for types that conform to
	/// `CustomStringConvertible`:
	///
	///     struct Point: CustomStringConvertible {
	///         let x: Int, y: Int
	///
	///         var description: String {
	///             return "(\(x), \(y))"
	///         }
	///     }
	///
	///     let p = Point(x: 21, y: 30)
	///     let s = String(describing: p)
	///     print(s)
	///     // Prints "(21, 30)"
	///
	/// The conversion of `p` to a string in the assignment to `s` uses the
	/// `Point` type's `description` property.
	public var description: String {
		""
	}
	
	/// The hash value.
	///
	/// Hash values are not guaranteed to be equal across different executions of
	/// your program. Do not save hash values to use during a future execution.
	///
	/// - Important: `hashValue` is deprecated as a `Hashable` requirement. To
	///   conform to `Hashable`, implement the `hash(into:)` requirement instead.
//	public var hashValue: Int { get }
}

extension Color {
	
	public enum RGBColorSpace {
		
		case sRGB

		@available(iOS 10.0, *)//, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
		case sRGBLinear

		@available(iOS 9.3, *)//, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
		case displayP3
	}
	
	public init(_ colorSpace: Color.RGBColorSpace = .sRGB, red: CGFloat, green: CGFloat, blue: CGFloat, opacity: CGFloat = 1) {
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
		color = UIColor(cgColor: CGColor(colorSpace: CGColorSpace(name: space)!, components: comps)!)
	}
	
	public init(_ colorSpace: Color.RGBColorSpace = .sRGB, white: CGFloat, opacity: CGFloat = 1) {
		self.init(colorSpace, red: white, green: white, blue: white, opacity: opacity)
	}
	
	public init(hue: CGFloat, saturation: CGFloat, brightness: CGFloat, opacity: CGFloat = 1) {
		color = UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: opacity)
	}
}

extension Color {
	
	/// A color that represents the accent color in the environment it is
	/// evaluated.
	///
	/// If an explicit value hasn't been set, the default system accent color
	/// will be used.
//	public static var accentColor: Color { get }
}

extension Color {
	/// A set of colors that are used by system elements and applications.
	public static let clear = Color(color: .clear)
	
	public static let black = Color(color: .black)
	
	public static let white = Color(color: .white)
	
	public static let gray = Color(color: .gray)
	
	public static let red = Color(color: .red)
	
	public static let green = Color(color: .green)
	
	public static let blue = Color(color: .blue)
	
	public static let orange = Color(color: .orange)
	
	public static let yellow = Color(color: .yellow)
	
//	public static let pink = Color(color: .pink)
	
	public static let purple = Color(color: .purple)

	@available(iOS 13, *)//, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
	public static let primary = Color(color: .label)

	@available(iOS 13, *)//, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
	public static let secondary = Color(color: .secondaryLabel)
}

//extension Color : ShapeStyle {
//}
@available(iOS 11.0, *)//, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
extension Color {
	/// Creates a named color.
	///
	/// - Parameters:
	///   - name: the name of the color resource to lookup.
	///   - bundle: the bundle to search for the color resource in.
	public init(_ name: String, bundle: Bundle? = nil) {
		color = UIColor(named: name, in: bundle, compatibleWith: nil) ?? .clear
	}
}

@available(OSX, unavailable)
extension Color {
	/// Creates a color from an instance of `UIColor`.
	public init(_ color: UIColor) {
		self.color = color
	}
}

extension Color {
	public func opacity(_ opacity: CGFloat) -> Color {
		return Color(color: color.withAlphaComponent(opacity))
	}
}
