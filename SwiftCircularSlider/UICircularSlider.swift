//
//  UICircularSlider.swift
//  SwiftCircularSlider
//
//  Created by Admin on 17.07.15.
//  Copyright (c) 2015 tarasova_aa. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

let π:CGFloat = CGFloat(M_PI)

@IBDesignable public class UICircularSlider: UIControl {
    
    private var renderer = Renderer()  
    private var gestureRecognizer: RotationGestureRecognizer!

    // MARK: API
    
    /**
    Contains a Boolean value indicating whether changes in the value of the slider
    generate continuous update events. The default value is `true`.
    */
    @IBInspectable public var continuous = true
    
    /**
    The minimum value of the slider. Defaults to 0.0.
    */
    @IBInspectable public var minimumValue: Float = 0.0
    
    /**
    The maximum value of the slider. Defaults to 60.0.
    */
    @IBInspectable public var maximumValue: Float = 60.0
    
    /**
    Contains the current value.
    */
    private var backingValue: Float = 0.0
    
    /** Contains the receiver’s current value. */
    public var value: Float {
        get { return backingValue }
        set { setValue(newValue, animated: false) }
    }

    /**
    Sets the value the slider should represent, with optional animation of the change.
    */
    public func setValue(value: Float, animated: Bool = false) {
            if(value != self.value) {
                self.backingValue = min(self.maximumValue, max(self.minimumValue, value))
                let angleRange = endAngle - startAngle
                let valueRange = CGFloat(maximumValue - minimumValue)
                let angle = CGFloat(value - minimumValue) / valueRange * angleRange + startAngle
                renderer.setPointerAngle(angle, animated: animated)
            }
    }
    /**
    Sets the color of slider's track.
    */
    @IBInspectable public var trackColor: UIColor = UIColor.blueColor(){
        didSet {
            renderer.trackColor = trackColor
            setNeedsDisplay()
            
        }
    }
    /**
    Sets the color of slider's pointer.
    */
    @IBInspectable public var pointerColor: UIColor = UIColor.blueColor(){
        didSet {
            renderer.pointerColor = pointerColor
            setNeedsDisplay()
        }
    }
    
    // MARK: UIView
    
    override public func prepareForInterfaceBuilder() {
        renderUI()
    }
    
    private func renderUI() {
        renderer.updateWithBounds(bounds)
        
        renderer.startAngle = -π * 5.0 / 4.0;
        renderer.endAngle = π / 4.0;
        renderer.pointerAngle = renderer.startAngle;
        
        layer.addSublayer(renderer.trackLayer)
        layer.addSublayer(renderer.pointerLayer)
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        gestureRecognizer = RotationGestureRecognizer(target: self, action: "handleGesture:")
        addGestureRecognizer(gestureRecognizer)
        renderUI()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
         gestureRecognizer = RotationGestureRecognizer(target: self, action: "handleGesture:")
       
        addGestureRecognizer(gestureRecognizer)
        renderUI()
    }
}

// MARK: - Renderer extension

public extension UICircularSlider {
    
    // MARK: API
    
    /**    
    Specifies the angle of the start of the track.
    */
    @IBInspectable public var startAngle: CGFloat{
        get {
            return renderer.startAngle
        }
        set {
            renderer.startAngle = newValue
        }
    }
    
    /**
    Specifies the end angle of the track.
    */
    @IBInspectable public var endAngle: CGFloat {
        get {
            return renderer.endAngle
        }
        set {
            renderer.endAngle = newValue
        }
    }
    /**
    Specifies the line width of the track
    */
    @IBInspectable public var trackWidth: CGFloat {
        get {
            return renderer.trackWidth
        }
        set {
            renderer.trackWidth = newValue
        }
    }
    /**
    Specifies the line width of the pointer
    */
    @IBInspectable public var pointerWidth: CGFloat {
        get {
            return renderer.pointerWidth
        }
        set {
            renderer.pointerWidth = newValue
        }
    }
    /**
    Specifies the length of the pointer in pixels
    */
    @IBInspectable public var pointerLength: CGFloat {
        get {
            return renderer.pointerLength
        }
        set {
            renderer.pointerLength = newValue
        }
    }
    
}
// MARK: Renderer

private class Renderer {
    
    var trackColor: UIColor = UIColor.blackColor() {
        didSet {
            trackLayer.strokeColor = trackColor.CGColor
            
        }
    }
    var pointerColor: UIColor = UIColor.blackColor() {
        didSet {
            pointerLayer.strokeColor = pointerColor.CGColor
        }
    }
    
    var trackWidth: CGFloat = 2 {
        didSet {
            trackLayer.lineWidth = trackWidth
            updateTrackShape()
            updatePointerShape()
        }
    }
    var pointerWidth: CGFloat = 2 {
        didSet {
            pointerLayer.lineWidth = pointerWidth
            //updateTrackShape()
            updatePointerShape()
        }
    }
    
    
    // MARK: Track Layer
    
    let trackLayer: CAShapeLayer = {
        var layer = CAShapeLayer.init()
        layer.fillColor = UIColor.clearColor().CGColor
        return layer
        }()
    
    var startAngle: CGFloat = -π * 5 / 4.0 {
        didSet {
            updateTrackShape()
        }
    }
    var endAngle: CGFloat = π / 4.0 {
        didSet {
            updateTrackShape()
        }
    }
    
    // MARK: Pointer Layer
    
    let pointerLayer = CAShapeLayer()
    
    var backingPointerAngle: CGFloat = -π * 5 / 4.0
    
    var pointerAngle: CGFloat {
        get { return backingPointerAngle }
        set { setPointerAngle(newValue, animated: false) }
    }
    
    var pointerLength: CGFloat = 6{
        didSet {
            updateTrackShape()
            updatePointerShape()
        }
    }
    
    func setPointerAngle(angle: CGFloat, animated: Bool = false) {
        CATransaction()
        CATransaction.setDisableActions(true)
        pointerLayer.transform = CATransform3DMakeRotation(angle, 0, 0, 1)
        if animated {
            let midAngle = (max(pointerAngle, angle) - min(pointerAngle, angle)) / 2 + min(pointerAngle, angle)
            let animation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
            animation.duration = 0.3
            animation.values = [pointerAngle, midAngle, angle]
            animation.keyTimes = [0, 0.5, 1.0]
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            
            pointerLayer.addAnimation(animation, forKey: nil)
        }
        CATransaction.commit()
        self.backingPointerAngle = angle
    }
    
    // MARK: Update Logic
    
    func updateTrackShape() {
        let center = CGPoint(x: trackLayer.bounds.width / 2, y: trackLayer.bounds.height / 2)
        let offset = trackWidth/2.0 
        let radius = min(trackLayer.bounds.width, trackLayer.bounds.height) / 2 - offset
        let ring = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        trackLayer.lineCap=kCALineCapRound;
        trackLayer.path = ring.CGPath
        
    }
    
    func updatePointerShape() {
        let pointer = UIBezierPath()
        pointer.moveToPoint(CGPoint(x: pointerLayer.bounds.width - pointerLength - trackWidth/2, y: pointerLayer.bounds.height / 2))
        pointer.addLineToPoint(CGPoint(x: pointerLayer.bounds.width - trackWidth - 3, y: pointerLayer.bounds.height / 2))
        
        pointerLayer.lineCap=kCALineCapRound;
        pointerLayer.path = pointer.CGPath
    }
    
    func updateWithBounds(bounds: CGRect) {
        trackLayer.bounds = bounds
        trackLayer.position = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        updateTrackShape()
        
        pointerLayer.bounds = trackLayer.bounds
        pointerLayer.position = trackLayer.position
        updatePointerShape()
    }
    
    // MARK: Lifecycle
    
    init() {
        trackLayer.fillColor = UIColor.clearColor().CGColor
        pointerLayer.fillColor = UIColor.clearColor().CGColor
        trackLayer.lineWidth = trackWidth
        pointerLayer.lineWidth = pointerWidth
        trackLayer.strokeColor = trackColor.CGColor
        pointerLayer.strokeColor = pointerColor.CGColor
    }
    
}

// MARK: - Rotation Gesture Recogniser extension

private extension UICircularSlider {
    
    dynamic func handleGesture(gesture: RotationGestureRecognizer) {
        let midPointAngle = (2 * π + startAngle - endAngle) / 2.0 + endAngle
        
        var boundedAngle = gesture.touchAngle
        if boundedAngle > midPointAngle {
            boundedAngle -= 2 * π
        }
        else if boundedAngle < (midPointAngle - 2 * π) {
            boundedAngle += 2 * π
        }
        
        boundedAngle = min(endAngle, max(startAngle, boundedAngle))
        var boundedValue = valueForAngle(boundedAngle)
        
        setValue(boundedValue)
        
        if continuous {
            sendActionsForControlEvents(.ValueChanged)
        }
        else {
            if gesture.state == .Ended || gesture.state == UIGestureRecognizerState.Cancelled {
                sendActionsForControlEvents(.ValueChanged)
            }
        }
    }
    
}

class RotationGestureRecognizer: UIPanGestureRecognizer {
    
    var touchAngle: CGFloat = 0
    var currentAngle: CGFloat = 0;
    var previousAngle:CGFloat = 0;
    
    var clockwise:Bool = true;

    
    // MARK: UIGestureRecognizerSubclass
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent!) {
        super.touchesBegan(touches, withEvent: event)
        updateTouchAngleWithTouches(touches)
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent!) {
        super.touchesMoved(touches, withEvent: event)
        previousAngle = touchAngle
        updateTouchAngleWithTouches(touches)
    }
    
    func updateTouchAngleWithTouches(touches: Set<NSObject>) {
        let touch = touches.first as! UITouch
        let touchPoint = touch.locationInView(view)
        
        
        touchAngle = calculateAngleToPoint(touchPoint)
        currentAngle = touchAngle
        getRotationDirection()
    }
    
    func calculateAngleToPoint(point: CGPoint) -> CGFloat {
        let centerOffset = CGPoint(x: point.x - CGRectGetMidX(view!.bounds), y: point.y - CGRectGetMidY(view!.bounds))
        return atan2(centerOffset.y, centerOffset.x)
    }
    
    func getRotationDirection(){
        if currentAngle > previousAngle {
            clockwise = true
        }
        else {
            clockwise = false
        }
    }
    
    // MARK: Lifecycle
    
    override init(target: AnyObject, action: Selector) {
        super.init(target: target, action: action)
        maximumNumberOfTouches = 1
        minimumNumberOfTouches = 1
    }
}


// MARK: - Utilities extenstion

private extension UICircularSlider{
    
    // MARK: Value/Angle conversion
    
    func valueForAngle(angle: CGFloat) -> Float {
        let angleRange = Float(endAngle - startAngle)
        let valueRange = maximumValue - minimumValue
        return Float(Int(Float(angle - startAngle) / angleRange * valueRange + minimumValue))
    }
    
    func angleForValue(value: Float) -> CGFloat {
        let angleRange = endAngle - startAngle
        let valueRange = CGFloat(maximumValue - minimumValue)
        return CGFloat(self.value - minimumValue) / valueRange * angleRange + startAngle
    }
    
}
