//
//  ViewController.swift
//  Font
//
//  Created by mikun on 2019/8/16.
//  Copyright © 2019 庄黛淳华. All rights reserved.
//

import UIKit
import SwiftUIKit

class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		let label = UILabel()
		
		
label.swift.text =
	(Text("text1")
		.background(.black)
		+
		Text("text2")
		).foregroundColor(Color(.red))
		.onTapGesture { print("tap") }
	+
	Text("text3\(Text: #imageLiteral(resourceName: "icon_sale_member"), width: 17)")
		.foregroundColor(.yellow)
		.tracking(10)
	+
	Text("text4")
		.onLongPressGesture { print("longPress") }
		view.addSubview(label)
		label.frame.size = label.sizeThatFits(view.frame.size)
		label.center = view.center
	}
}

