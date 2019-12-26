//
//  UIView.swift
//  host
//
//  Created by mikun on 2019/8/25.
//
//

import UIKit

extension UIView {
	class LongPressGesture: UILongPressGestureRecognizer {
		var text: [NSRange] = []
		var pressing = false
		var didSentPressing = false
		func sendAllAction() {
			let targetActionPairs = value(forKey: "_targets") as? [NSObject] ?? []
			for var targetActionPair in targetActionPairs {
				guard let target = targetActionPair.value(forKey: "_target") as? NSObject else { continue }
				if target.isKind(of: NSClassFromString("UIGestureRecognizerTarget")!) {
					targetActionPair = target
				}

				let selector = NSSelectorFromString("_sendActionWithGestureRecognizer:");
				if targetActionPair.responds(to: selector) {
					targetActionPair.perform(selector, with: self)
				}
			}
		}
		override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
			super.touchesBegan(touches, with: event)
			pressing = true
			sendAllAction()
		}
		override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
			pressing = false
			super.touchesEnded(touches, with: event)
			if !didSentPressing {
				sendAllAction()
			}
			didSentPressing = false
		}
		override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
			pressing = false
			didSentPressing = false
			super.touchesCancelled(touches, with: event)
		}
	}
	class TapGesture: UITapGestureRecognizer {
		var text: [NSRange] = []
		
		private override init(target: Any?, action: Selector?) {
			super.init(target: target, action: action)
		}
		typealias ActionType = (_ location: CGPoint, _ text: [NSRange]) -> Void
		var actions = [ActionType]()
		convenience init(action: @escaping ActionType) {
			self.init()
			actions.append(action)
		}
		override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
			if let location = touches.first?.location(in: view) {
				actions.forEach {
					$0(location, text)
				}
			}
			super.touchesEnded(touches, with: event)
		}
	}
}

extension UIView {
	private class TapGestureRecognizer: UITapGestureRecognizer {
		var action: (UITapGestureRecognizer) -> Void
		init(action: @escaping (UITapGestureRecognizer) -> Void) {
			self.action = action
			super.init(target: nil, action: nil)
			addTarget(self, action: #selector(performAction))
		}
		@objc private func performAction() {
			action(self)
		}
	}
	
    /// Returns a version of `self` that will invoke `action` after
    /// recognizing a tap gesture.
	@discardableResult
	public func onTapGesture(count: Int = 1, perform action: @escaping () -> Void) -> Self {
		onTapGesture(count: count) { (_) in
			action()
		}
	}
    /// Returns a version of `self` that will invoke `action` after
    /// recognizing a tap gesture.
	@discardableResult
	public func onTapGesture(count: Int = 1, perform action: @escaping (UITapGestureRecognizer) -> Void) -> Self {
		let tap = TapGestureRecognizer(action: action)
		tap.numberOfTapsRequired = count
		addGestureRecognizer(tap)
		isUserInteractionEnabled = true
		return self
	}
}

extension UIView {
	class _Delegate<View>: NSObject, UIGestureRecognizerDelegate where View: UIView {
		weak var view: View?
		init(view: View?) {
			self.view = view
		}
		var _textStorage: NSTextStorage?
		var textStorage: NSTextStorage? {
			_textStorage
		}
		var _textContainer: NSTextContainer?
		var textContainer: NSTextContainer? {
			_textContainer
		}
		var _layoutManager: NSLayoutManager?
		var layoutManager: NSLayoutManager? {
			_layoutManager
		}
		func locationOfTouchInTextContainer(location: CGPoint, textBoundingBox: CGRect = .zero) -> CGPoint {
			location
		}
		@objc fileprivate func handleLongPressText(_ longPress: LongPressGesture) {
			if let info: Text.LongPressInfo = gestureWorkingInfo(location: longPress.location(in: view), texts: longPress.text, key: Text.longPressKey) {
				switch longPress.state {
				case .possible:
					if longPress.pressing {
						info.pressing?(true)
					}
				case .began:
					info.pressing?(false)
					longPress.didSentPressing = true
					info.action()
				case .failed:
					if !longPress.didSentPressing {
						info.pressing?(false)
					}
				default:
					break
				}
			}
		}
		public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
			return true
		}
	}
}

extension UIView._Delegate {
	func gestureWorkingInfo<T>(location: CGPoint, texts: [NSRange], key: NSAttributedString.Key) -> T? {
		guard let layoutManager = layoutManager, let textContainer = textContainer else { return nil }
		let location = locationOfTouchInTextContainer(location: location, textBoundingBox: layoutManager.usedRect(for: textContainer))
		let characterTapped = layoutManager.characterIndex(for: location, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)

		var range = NSRange()
		let attribute = layoutManager.textStorage?.attributes(at: characterTapped, effectiveRange: &range)
		
		//FIX:    某些时候因为字体问题导致被切分, 比如[开通会员,]里[开通会员]用的字体是PingFangSC, [,]用的字体是SFUI然后被分开
		if texts.contains(where: {
			$0.contains(range.lowerBound) && $0.contains(range.upperBound-1)
		}) {
			return attribute?[key] as? T
		}
		return nil
	}
	typealias TapGesture = UIView.TapGesture
	typealias LongPressGesture = UIView.LongPressGesture
	func config(text: Text?, tapGestrues: inout [TapGesture], longPressGestrues: inout [LongPressGesture]) {
		guard let text = text, let view = view else { return }
		if text.useTap {
			view.isUserInteractionEnabled = true

			text.text.enumerateAttributes(in: NSRange(location: 0, length: text.text.length), options: []) { (attPair, range, boolPointer) in
				guard let info = attPair[Text.tapKey] as? Text.TapInfo else { return }
				if let tap = tapGestrues.filter({ (tap) -> Bool in
					tap.numberOfTapsRequired == info.count
				}).first {
					tap.text.append(range)
					return
				}

				let tap = TapGesture { [weak self] (location, texts) in
					guard let self = self else { return }
					if let info: Text.TapInfo = self.gestureWorkingInfo(location: location, texts: texts, key: Text.tapKey) {
						info.action()
					}
				}

				tap.numberOfTapsRequired = info.count

				tap.delegate = self

				tap.text.append(range)
				tapGestrues.append(tap)
				view.addGestureRecognizer(tap)
			}
		}

		if text.useLongPress {
			view.isUserInteractionEnabled = true

			text.text.enumerateAttributes(in: NSRange(location: 0, length: text.text.length), options: []) { (attPair, range, boolPointer) in
				guard let info = attPair[Text.longPressKey] as? Text.LongPressInfo else { return }
				if let press = longPressGestrues.filter({ (press) -> Bool in
					press.minimumPressDuration == info.minimumDuration &&
						press.allowableMovement == info.maximumDistance
				}).first {
					press.text.append(range)
					return
				}

				let press = LongPressGesture(target: self, action: #selector(handleLongPressText(_:)))

				press.minimumPressDuration = info.minimumDuration
				press.allowableMovement = info.maximumDistance

				press.delegate = self

				press.text.append(range)
				longPressGestrues.append(press)
				view.addGestureRecognizer(press)
			}
		}
		tapGestrues.removeAll {
			if $0.text.isEmpty {
				$0.view?.removeGestureRecognizer($0)
			}
			return $0.text.isEmpty
		}
		longPressGestrues.removeAll {
			if $0.text.isEmpty {
				$0.view?.removeGestureRecognizer($0)
			}
			return $0.text.isEmpty
		}
	}
}

// MARK: - Swift 存在一个bug, 当Class使用范型并声明在某个类型里时, 子类如果不在同一个文件里, 初始化会crash
extension UITextField.SwiftUIKit {
	class Delegate: UIView._Delegate<UITextField> {
		override var textContainer: NSTextContainer? {
			guard _textContainer == nil else { return _textContainer }
			let textContainer = NSTextContainer()
			textContainer.lineFragmentPadding = 0.0
			if let view = view {
				textContainer.size = view.bounds.size
				textContainer.maximumNumberOfLines = 1// 这里是唯一和UILabel不同的地方, 其他地方都是相同的
			}
			_textContainer = textContainer
			return _textContainer
		}

		override var textStorage: NSTextStorage? {
			guard _textStorage == nil else { return _textStorage }
			_textStorage = UILabelTextStorage()
			return _textStorage
		}
		override var layoutManager: NSLayoutManager? {
			guard _layoutManager == nil else {
				if let text = view?.attributedText {
					textStorage?.setAttributedString(text)
				}
				return _layoutManager
			}
			let layoutManager = NSLayoutManager()
			layoutManager.addTextContainer(textContainer!)

			textStorage?.addLayoutManager(layoutManager)
			if let text = view?.attributedText {
				textStorage?.setAttributedString(text)
			}
			
			_layoutManager = layoutManager
			return layoutManager
		}
		override func locationOfTouchInTextContainer(location: CGPoint, textBoundingBox: CGRect = .zero) -> CGPoint {
			guard let view = view else { return location }
			var alignmentOffset: CGFloat!
			switch view.textAlignment {
			case .left, .natural, .justified:
				alignmentOffset = 0.0
			case .center:
				alignmentOffset = 0.5
			case .right:
				alignmentOffset = 1.0
			@unknown default: break
			}
			let xOffset = ((view.bounds.size.width - textBoundingBox.size.width) * alignmentOffset) - textBoundingBox.origin.x
			let yOffset = ((view.bounds.size.height - textBoundingBox.size.height) * alignmentOffset) - textBoundingBox.origin.y
			return CGPoint(x: location.x - xOffset, y: location.y - yOffset)
		}
	}
}
extension UILabel.SwiftUIKit {
	class Delegate: UIView._Delegate<UILabel> {
		override var textContainer: NSTextContainer? {
			guard _textContainer == nil else { return _textContainer }
			let textContainer = NSTextContainer()
			textContainer.lineFragmentPadding = 0.0
			if let view = view {
				textContainer.size = view.bounds.size
				textContainer.lineBreakMode = view.lineBreakMode
				textContainer.maximumNumberOfLines = view.numberOfLines
			}
			_textContainer = textContainer
			return _textContainer
		}
		override var textStorage: NSTextStorage? {
			guard _textStorage == nil else { return _textStorage }
			_textStorage = UILabelTextStorage()
			return _textStorage
		}
		override var layoutManager: NSLayoutManager? {
			guard _layoutManager == nil else {
				if let text = view?.attributedText {
					textStorage?.setAttributedString(text)
				}
				return _layoutManager
			}
			let layoutManager = NSLayoutManager()
			layoutManager.addTextContainer(textContainer!)

			textStorage?.addLayoutManager(layoutManager)
			if let text = view?.attributedText {
				textStorage?.setAttributedString(text)
			}
			
			_layoutManager = layoutManager
			return layoutManager
		}
		override func locationOfTouchInTextContainer(location: CGPoint, textBoundingBox: CGRect = .zero) -> CGPoint {
			guard let view = view else { return location }
			var alignmentOffset: CGFloat!
			switch view.textAlignment {
			case .left, .natural, .justified:
				alignmentOffset = 0.0
			case .center:
				alignmentOffset = 0.5
			case .right:
				alignmentOffset = 1.0
			@unknown default: break
			}
			let xOffset = ((view.bounds.size.width - textBoundingBox.size.width) * alignmentOffset) - textBoundingBox.origin.x
			let yOffset = ((view.bounds.size.height - textBoundingBox.size.height) * alignmentOffset) - textBoundingBox.origin.y
			return CGPoint(x: location.x - xOffset, y: location.y - yOffset)
		}
	}
}

extension UITextView.SwiftUIKit {
	class Delegate: UIView._Delegate<UITextView> {
		override var textContainer: NSTextContainer? {
			view?.textContainer
		}
		
		override var layoutManager: NSLayoutManager? {
			return view?.layoutManager
		}
	}
}
