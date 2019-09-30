//
//  FontTest.swift
//  FontTest
//
//  Created by mikun on 2019/8/16.
//  
//

import XCTest
@testable import SwiftUIKit

class FontTest: XCTestCase {

	func testFont_TextStyle() {
		let fontAttri = Font.system(.body).uiFont.fontDescriptor.fontAttributes as NSDictionary
		let uiFontAtt = UIFont.preferredFont(forTextStyle: .body).fontDescriptor.fontAttributes
		
		XCTAssert(fontAttri.isEqual(to: uiFontAtt))
	}
	
	func testFont_italic() {
		let fontAttri = Font().italic().uiFont.fontDescriptor.fontAttributes as NSDictionary
		let uiFontAtt = UIFont.italicSystemFont(ofSize: 18).fontDescriptor.fontAttributes
		
		XCTAssert(fontAttri.isEqual(to: uiFontAtt))
	}
	func getSettings(uiFont: UIFont) -> [[UIFontDescriptor.FeatureKey: Int]] {
		let fontAttri = uiFont.fontDescriptor.fontAttributes
		return fontAttri[.featureSettings] as? [[UIFontDescriptor.FeatureKey: Int]] ?? []
	}
	func tryTestFont_lowercaseSmallCaps(uifont: UIFont = Font().lowercaseSmallCaps().uiFont) {
		let settings = getSettings(uiFont: uifont)
		XCTAssert(settings.contains([
			UIFontDescriptor.FeatureKey.featureIdentifier : kLowerCaseType,
			UIFontDescriptor.FeatureKey.typeIdentifier : kLowerCaseSmallCapsSelector
		]))
	}
	func tryTestFont_uppercaseSmallCaps(uifont: UIFont = Font().uppercaseSmallCaps().uiFont) {
		let settings = getSettings(uiFont: uifont)
		XCTAssert(settings.contains([
			UIFontDescriptor.FeatureKey.featureIdentifier : kUpperCaseType,
			UIFontDescriptor.FeatureKey.typeIdentifier : kUpperCaseSmallCapsSelector
		]))
		
	}
	
	func testFont_lowercaseSmallCaps() {
		tryTestFont_lowercaseSmallCaps()
	}
	func testFont_uppercaseSmallCaps() {
		tryTestFont_uppercaseSmallCaps()
	}
	func testFont_smallCaps() {
		let font = Font().smallCaps().uiFont
		tryTestFont_lowercaseSmallCaps(uifont: font)
		tryTestFont_uppercaseSmallCaps(uifont: font)
	}
	func testFont_monospacedDigit(){
		
		let fontAttri = Font().monospacedDigit().uiFont.fontDescriptor.fontAttributes as NSDictionary
		let uiFontAtt = UIFont.monospacedDigitSystemFont(ofSize: 18, weight: .regular).fontDescriptor.fontAttributes
		
		XCTAssert(fontAttri.isEqual(to: uiFontAtt))
	}
	func testFont_weight(){
		
		let fontAttri = Font().weight(.light).uiFont.fontDescriptor.fontAttributes as NSDictionary
		let uiFontAtt = UIFont.systemFont(ofSize: 18, weight: .light).fontDescriptor.fontAttributes
		
		XCTAssert(fontAttri.isEqual(to: uiFontAtt))
	}
	func testFont_bold(){
		
		let fontAttri = Font().bold().uiFont.fontDescriptor.fontAttributes as NSDictionary
		let uiFontAtt = UIFont.boldSystemFont(ofSize: 18).fontDescriptor.fontAttributes
		
		XCTAssert(fontAttri.isEqual(to: uiFontAtt))
	}
	func testFont_system1(){
		
		let fontAttri = Font.system(size: 20, weight: .heavy, design: .rounded)
			.uiFont.fontDescriptor.fontAttributes as NSDictionary
		let uiFontAtt = UIFont(descriptor: UIFont.systemFont(ofSize: 20, weight: .heavy)
			.fontDescriptor.withDesign(.rounded)!, size: 20).fontDescriptor.fontAttributes
		/*UIKit 在处理 withDesign 的时候会先生成:
		{
			NSCTFontTraitsAttribute =     {
				NSCTFontProportionTrait = 0;
				NSCTFontSlantTrait = 0;
				NSCTFontSymbolicTrait = 16386;
				NSCTFontUIFontDesignTrait = NSCTFontUIFontDesignRounded;
				NSCTFontWeightTrait = "0.5600000023841858";
			};
			NSFontSizeAttribute = 20;
		}
		这个时候用fontDescriptor..object(forKey: .init(rawValue: "NSCTFontUIUsageAttribute"))是能拿到heavy的信息的
		*/
		// 用UIFont(descriptor) 重新生成 UIFont 会省略多余的东西并把 NSCTFontUIUsageAttribute 重新显示出来:
		/*
		{
			NSCTFontTraitsAttribute =     {
				NSCTFontUIFontDesignTrait = NSCTFontUIFontDesignRounded;
			};
			NSCTFontUIUsageAttribute = CTFontSystemUIRoundedHeavy;
			NSFontSizeAttribute = 20;
		}
		*/
		XCTAssert(fontAttri.isEqual(to: uiFontAtt))
	}
	func testFont_system2(){
		let allCase: [Font.TextStyle] = [
			.largeTitle,
			.title,
			.headline,
			.subheadline,
			.body,
			.callout,
			.footnote,
			.caption
		]
		for style in allCase {
			let fontAttri = Font.system(style, design: .serif)
				.uiFont.fontDescriptor.fontAttributes as NSDictionary
			let uiFontAtt = UIFont(descriptor:
				UIFont.preferredFont(forTextStyle: style.uiFontTextStyle)
					.fontDescriptor.withDesign(.serif)!, size: 0).fontDescriptor.fontAttributes
			
			XCTAssert(fontAttri.isEqual(to: uiFontAtt))
		}

	}
	func testFont_custom(){
		
		let fontAttri = Font.custom("PingFang SC", size: 30)
			.uiFont.fontDescriptor.fontAttributes as NSDictionary
		let uiFontAtt = UIFont(name: "PingFang SC", size: 30)?
			.fontDescriptor.fontAttributes
		
		XCTAssert(fontAttri.isEqual(to: uiFontAtt!))
	}
}
