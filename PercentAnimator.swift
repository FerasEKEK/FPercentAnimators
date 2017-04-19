//
//  PercentAnimator.swift
//  PercentAnimator
//
//  Created by Apple on 4/19/17.
//  Copyright © 2017 Firas Al Khatib Al Khalidi. All rights reserved.
//

import Foundation
import UIKit
protocol PercentAnimator {
    associatedtype type : Any
    func value(atPercent p: Double) -> type
}
class NumberAnimator: PercentAnimator{

    init(minValue: CGFloat, maxValue: CGFloat) {
        self.minValue = minValue
        self.maxValue = maxValue
    }
    typealias type = CGFloat
    var minValue: CGFloat = 0{
        didSet{
            if maxValue <= minValue{
                maxValue = minValue + 1
            }
        }
    }
    var maxValue: CGFloat = 1{
        didSet{
            if maxValue <= minValue{
                minValue = maxValue - 1
            }
        }
    }
    internal func value(atPercent p: Double) -> CGFloat {
        return minValue+((CGFloat(p)*(maxValue - minValue)))
    }
}

class BezierAnimator: PercentAnimator{
    typealias type = CGPoint
    var startingPoint: CGPoint = CGPoint.zero
    var endingPoint: CGPoint = CGPoint.zero
    func value(atPercent p: Double) -> CGPoint {
        return CGPoint.zero
    }
    init(startingPoint: CGPoint, endingPoint: CGPoint){
        self.startingPoint = startingPoint
        self.endingPoint = endingPoint
    }
}
class LinearBezierAnimator: BezierAnimator{
    override func value(atPercent p: Double) -> CGPoint {
        let x = startingPoint.x + CGFloat(p)*(endingPoint.x - startingPoint.x)
        let y = startingPoint.y + CGFloat(p)*(endingPoint.y - startingPoint.y)
        return CGPoint(x: x, y: y)
    }
}
class CubicBezierAnimator: BezierAnimator{
    var firstControlPoint: CGPoint = CGPoint.zero
    var secondControlPoint: CGPoint = CGPoint.zero
    init(startingPoint: CGPoint, endingPoint: CGPoint, firstControlPoint: CGPoint, secondControlPoint: CGPoint) {
        super.init(startingPoint: startingPoint, endingPoint: endingPoint)
        self.firstControlPoint = firstControlPoint
        self.secondControlPoint = secondControlPoint
    }
    override func value(atPercent p: Double) -> CGPoint {
        let xFirstExpression = pow((1-p), 3)*Double(startingPoint.x)
        let xSecondExpresion = 3*pow((1-p),2)*p*Double(firstControlPoint.x)
        let xThirdExpression = 3*(1-p)*p*p*Double(secondControlPoint.x)
        let xFourthExpression = pow(p, 3)*Double(endingPoint.x)
        let x = xFirstExpression+xSecondExpresion+xThirdExpression+xFourthExpression
        let yFirstExpression = pow((1-p), 3)*Double(startingPoint.y)
        let ySecondExpresion = 3*pow((1-p),2)*p*Double(firstControlPoint.y)
        let yThirdExpression = 3*(1-p)*p*p*Double(secondControlPoint.y)
        let yFourthExpression = pow(p, 3)*Double(endingPoint.y)
        let y = yFirstExpression+ySecondExpresion+yThirdExpression+yFourthExpression
        return CGPoint(x: x, y: y)
    }
    func getOrientation(atPercent p: Double) -> CGPoint{
        let xFirstExpression = 3*pow((1-p), 2) * Double(firstControlPoint.x - startingPoint.x)
        let xSecondExpression = 6*(1-p)*p * Double(secondControlPoint.x - firstControlPoint.x)
        let xThirdExpression = 3*pow(p, 2) * Double(endingPoint.x - secondControlPoint.x)
        let x = xFirstExpression + xSecondExpression + xThirdExpression
        let yFirstExpression = 3*pow((1-p), 2) * Double(firstControlPoint.y - startingPoint.y)
        let ySecondExpression = 6*(1-p)*p * Double(secondControlPoint.y - firstControlPoint.y)
        let yThirdExpression = 3*pow(p, 2) * Double(endingPoint.y - secondControlPoint.y)
        let y = yFirstExpression + ySecondExpression + yThirdExpression
        return CGPoint(x: x, y: y)
    }
}
class QuadraticBezierAnimator: BezierAnimator{
    var controlPoint: CGPoint = CGPoint.zero
    init(startingPoint: CGPoint, endingPoint: CGPoint, andControlPoint controlPoint: CGPoint) {
        super.init(startingPoint: startingPoint, endingPoint: endingPoint)
        self.controlPoint = controlPoint
    }
    override func value(atPercent p: Double) -> CGPoint {
        let firstExpressionX = pow((1.0 - p), 2)*Double(startingPoint.x)
        let secondExpessionX = 2.0*(1.0-p)*p*Double(controlPoint.x)
        let thirdExpressionX = pow(p, 2)*Double(endingPoint.x)
        let x = firstExpressionX+secondExpessionX+thirdExpressionX
        let firstExpressionY = pow((1.0 - p), 2)*Double(startingPoint.y)
        let secondExpessionY = 2.0*(1.0-p)*p*Double(controlPoint.y)
        let thirdExpressionY = pow(p, 2)*Double(endingPoint.y)
        let y = firstExpressionY+secondExpessionY+thirdExpressionY
        return CGPoint(x: x, y: y)
    }
    func getOrientation(atPercent p: Double) -> CGPoint{
        let xFirstExpression = 2*(1-CGFloat(p))*(controlPoint.x - startingPoint.x)
        let xSecondExpression = 2*CGFloat(p)*(endingPoint.x - controlPoint.x)
        let x = xFirstExpression + xSecondExpression
        let yFirstExpression = 2*(1-CGFloat(p))*(controlPoint.y - startingPoint.y)
        let ySecondExpression = 2*CGFloat(p)*(endingPoint.y - controlPoint.y)
        let y = yFirstExpression + ySecondExpression
        return CGPoint(x: x, y: y)
    }
}
class ColorAnimator: PercentAnimator{
    internal typealias type = UIColor
    private var rNumberAnimator: NumberAnimator!
    private var gNumberAnimator: NumberAnimator!
    private var bNumberAnimator: NumberAnimator!
    var startColor = UIColor.white{
        didSet{
            initNumberAnimators()
        }
    }
    var endColor = UIColor.black{
        didSet{
            initNumberAnimators()
        }
    }
    init(startColor: UIColor, endColor: UIColor) {
        self.startColor = startColor
        self.endColor = endColor
        initNumberAnimators()
    }
    private func initNumberAnimators(){
        rNumberAnimator = NumberAnimator(minValue: startColor.colorComponents!.red, maxValue: endColor.colorComponents!.red)
        gNumberAnimator = NumberAnimator(minValue: startColor.colorComponents!.green, maxValue: endColor.colorComponents!.green)
        bNumberAnimator = NumberAnimator(minValue: startColor.colorComponents!.blue, maxValue: endColor.colorComponents!.blue)
    }
    internal func value(atPercent p: Double) -> UIColor {
        return UIColor(colorLiteralRed: Float(rNumberAnimator.value(atPercent: p)), green: Float(gNumberAnimator.value(atPercent: p)), blue: Float(bNumberAnimator.value(atPercent: p)), alpha: 1)
    }
}
extension UIColor {
    var colorComponents: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)? {
        guard let components = self.cgColor.components else { return nil }
        
        return (
            red: components[0],
            green: components[1],
            blue: components[2],
            alpha: components[3]
        )
    }
}
