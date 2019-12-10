//
//  ViewTest.swift
//  ViewTest
//
//  Created by mikun on 2019/8/16.
//  
//

import XCTest
@testable import SwiftUIKit

class ViewTest: XCTestCase {
	func testUILabelTextStorage(){
		let storage = UILabelTextStorage()
		XCTAssert(NSStringFromClass(storage.classForCoder) == "NSStringDrawingTextStorage")
	}
}
