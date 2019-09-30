# SwiftUIKit

A SwfitUI style UIKit

## Requirement

- Xcode 11

- Swift5.0

## Usage

#### Text

```swift
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
```

![image-20190930104031246](https://wx2.sinaimg.cn/large/70a5dc58gy1g7hcm123zlj20be027mxb.jpg)

Also support UITextField and UITextView, but tap/longPress gesture may conflict with own gesture

#### Font

The usage is the same as SwiftUI

```swift
Font().italic()
```

get UIFont

```
Font().italic().uiFont
```

