//
//  TextTest.swift
//  Test
//
//  Created by mikun on 2019/8/18.
//  
//

import XCTest
@testable import SwiftUIKit

class TextTest: XCTestCase {
	func test_defaultText() {
		let para = NSMutableParagraphStyle()
		para.lineSpacing = 2
		XCTAssert(Text("abc").text.isEqual(to: NSAttributedString(string: "abc", attributes: [.paragraphStyle: para, .font: Text.defaultFont.uiFont])))
	}
	func test_localized() {
		XCTAssert(Text("首页", tableName: nil, bundle: Bundle(for: Self.self), comment: nil).text.string == "home")
		XCTAssert(Text(verbatim: "首页").text.string == "首页")
	}
	func test_function() {
		var text = Text("testString")
		
		XCTAssert(text.text.attributes(at: 0, effectiveRange: nil)[.font] as? UIFont == Text.defaultFont.uiFont)
		
		text = text.foregroundColor(Color.red)
		XCTAssert(text.text.attributes(at: 0, effectiveRange: nil)[.foregroundColor] as? UIColor == .red)
		
		text = text.background(Color.black)
		XCTAssert(text.text.attributes(at: 0, effectiveRange: nil)[.backgroundColor] as? UIColor == .black)
			
		_={
			let fontSize = CGFloat.random(in: 0..<100)
			let font = UIFont.systemFont(ofSize: fontSize)
			text = text.font(Font(font))
			XCTAssert(text.text.attributes(at: 0, effectiveRange: nil)[.font] as? UIFont == font)
		}()
		
		_={
			let font1 = text.text.attributes(at: 0, effectiveRange: nil)[.font] as! UIFont
			text = text.fontWeight(.heavy)
			let font2 = text.text.attributes(at: 0, effectiveRange: nil)[.font] as! UIFont
			XCTAssert(font2 == Font(font1).weight(.heavy).uiFont)
		}()
		
		_={
			let font1 = text.text.attributes(at: 0, effectiveRange: nil)[.font] as! UIFont
			text = text.bold()
			let font2 = text.text.attributes(at: 0, effectiveRange: nil)[.font] as! UIFont
			XCTAssert(font2 == Font(font1).bold().uiFont)
		}()
		
		
		_={
			let font1 = text.text.attributes(at: 0, effectiveRange: nil)[.font] as! UIFont
			text = text.italic()
			let font2 = text.text.attributes(at: 0, effectiveRange: nil)[.font] as! UIFont
			XCTAssert(font2 == Font(font1).italic().uiFont)
		}()
		_={
			let text = text.strikethrough(false, color: .blue)
			XCTAssert(text.text.attributes(at: 0, effectiveRange: nil)[.strikethroughColor] == nil)
		}()
		_={
			let text = text.strikethrough(true, color: .clear)
			XCTAssert(text.text.attributes(at: 0, effectiveRange: nil)[.strikethroughColor] as? UIColor == .clear)
		}()
		_={
			let text = text.strikethrough(true, color: nil)
			XCTAssert(text.text.attributes(at: 0, effectiveRange: nil)[.strikethroughColor] as? UIColor == .red)
		}()
		
		_={
			let text = text.underline(false, color: .gray)
			XCTAssert(text.text.attributes(at: 0, effectiveRange: nil)[.underlineColor] == nil)
		}()
		_={
			let text = text.underline(true, color: .green)
			XCTAssert(text.text.attributes(at: 0, effectiveRange: nil)[.underlineColor] as? UIColor == .green)
		}()
		_={
			let text = text.underline(true, color: nil)
			XCTAssert(text.text.attributes(at: 0, effectiveRange: nil)[.underlineColor] as? UIColor == .red)
		}()

		let kerning = CGFloat.random(in: 0..<100)
		text = text.kerning(kerning)
		XCTAssert(text.text.attributes(at: 0, effectiveRange: nil)[.kern] as? CGFloat == kerning)
		
		
		let tracking = CGFloat.random(in: 0..<100)
		text = text.tracking(tracking)
		XCTAssert(text.text.attributes(at: 0, effectiveRange: nil)[kCTTrackingAttributeName as NSAttributedString.Key] as? CGFloat == tracking)
		
		let baselineOffset = CGFloat.random(in: -100..<100)
		text = text.baselineOffset(baselineOffset)
		XCTAssert(text.text.attributes(at: 0, effectiveRange: nil)[.baselineOffset] as? CGFloat == baselineOffset)
		
		let minimumDuration = TimeInterval.random(in: 0..<100)
		let maximumDistance = CGFloat.random(in: 0..<100)
		text = text.onLongPressGesture(minimumDuration: minimumDuration, maximumDistance: maximumDistance, pressing: { (pressing) in
			
		}, perform: {
			
		})
		text = text.onTapGesture {
			
		}
		
		text = text.multilineTextAlignment(.center)
		XCTAssert((text.text.attributes(at: 0, effectiveRange: nil)[.paragraphStyle] as? NSParagraphStyle)?.alignment == .center)
		text = text.multilineTextAlignment(.leading)
		XCTAssert((text.text.attributes(at: 0, effectiveRange: nil)[.paragraphStyle] as? NSParagraphStyle)?.alignment == .left)
		text = text.multilineTextAlignment(.trailing)
		XCTAssert((text.text.attributes(at: 0, effectiveRange: nil)[.paragraphStyle] as? NSParagraphStyle)?.alignment == .right)
		
		
		text = text.truncationMode(.head)
		XCTAssert((text.text.attributes(at: 0, effectiveRange: nil)[.paragraphStyle] as? NSParagraphStyle)?.lineBreakMode == .byTruncatingHead)
		text = text.truncationMode(.middle)
		XCTAssert((text.text.attributes(at: 0, effectiveRange: nil)[.paragraphStyle] as? NSParagraphStyle)?.lineBreakMode == .byTruncatingMiddle)
		text = text.truncationMode(.tail)
		XCTAssert((text.text.attributes(at: 0, effectiveRange: nil)[.paragraphStyle] as? NSParagraphStyle)?.lineBreakMode == .byTruncatingTail)
		
		let lineSpacing = CGFloat.random(in: 0..<100)
		text = text.lineSpacing(lineSpacing)
		XCTAssert((text.text.attributes(at: 0, effectiveRange: nil)[.paragraphStyle] as? NSParagraphStyle)?.lineSpacing == lineSpacing)
		
		text = text.allowsTightening(true)
		XCTAssert((text.text.attributes(at: 0, effectiveRange: nil)[.paragraphStyle] as? NSParagraphStyle)?.allowsDefaultTighteningForTruncation == true)
		text = text.allowsTightening(false)
		XCTAssert((text.text.attributes(at: 0, effectiveRange: nil)[.paragraphStyle] as? NSParagraphStyle)?.allowsDefaultTighteningForTruncation == false)
		
		let label = UILabel()
		label.swift.text = text
		XCTAssert(label.numberOfLines == 0)
		XCTAssert(label.minimumScaleFactor == 0)
		
		let lineLimit = Int.random(in: 0..<100)
		text = text.lineLimit(lineLimit)
		
		// it seem like apple's weird bug, if I use CGFloat.random(in: 0..<1) and It always has diffent value after I set label.minimumScaleFactor
		let minimumScaleFactor = CGFloat(Float.random(in: 0..<1))
		text = text.minimumScaleFactor(minimumScaleFactor)
		
		label.swift.text = text
		XCTAssert(label.numberOfLines == lineLimit)
		XCTAssert(label.minimumScaleFactor == minimumScaleFactor)
	}
	func test_Image() {
		let image = UIImage(contentsOfFile: Bundle(for: Self.self).path(forResource: "applecare-products@2x.png", ofType: nil)!)!
		
		_={
			let width = CGFloat.random(in: 0..<100)
			let offset = CGFloat.random(in: 0..<100)
			let att = Text("\(image, width: width, offset: offset)").text.attributes(at: 0, effectiveRange: nil)
			guard
				let attachment = att[.attachment] as? NSTextAttachment
			else {
				XCTFail()
				return
			}
			XCTAssert(attachment.image == image)
			XCTAssert(attachment.bounds.origin.y == offset)
			let size = CGSize(width: width, height: width / image.size.width * image.size.height)
			XCTAssert(attachment.bounds.size == size)
		}()
		
		_={
			let height = CGFloat.random(in: 0..<100)
			let att = Text("\(image, height: height)").text.attributes(at: 0, effectiveRange: nil)
			guard
				let attachment = att[.attachment] as? NSTextAttachment
			else {
				XCTFail()
				return
			}
			XCTAssert(attachment.image == image)
			XCTAssert(attachment.bounds.origin.y == -2)
			let size = CGSize(width: height / image.size.height * image.size.width, height: height)
			XCTAssert(attachment.bounds.size == size)
		}()
		_={
			let height = CGFloat.random(in: 0..<100)
			let width = CGFloat.random(in: 0..<100)
			let att = Text("\(image, width: width, height: height)").text.attributes(at: 0, effectiveRange: nil)
			guard
				let attachment = att[.attachment] as? NSTextAttachment
			else {
				XCTFail()
				return
			}
			let size = CGSize(width: width, height: height)
			XCTAssert(attachment.bounds.size == size)
		}()
		_={
			let att = Text("\(image)").text.attributes(at: 0, effectiveRange: nil)
			guard
				let attachment = att[.attachment] as? NSTextAttachment
			else {
				XCTFail()
				return
			}
			XCTAssert(attachment.bounds.size == image.size)
		}()
	}
	func test_Attribute() {
		let attributeStr = NSAttributedString(string: "testStr", attributes: [.foregroundColor:UIColor.red])
		let testAttStr = attributeStr.mutableCopy() as! NSMutableAttributedString
		
		let para = NSMutableParagraphStyle()
		para.lineSpacing = 2
		testAttStr.addAttributes([.paragraphStyle: para, .font: Text.defaultFont.uiFont], range: NSRange(location: 0, length: testAttStr.length))
		
		XCTAssert(Text("\(attributeStr)").text == testAttStr)
	}

}
