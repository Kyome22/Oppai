//
//  OppaiView.swift
//  Oppai
//
//  Created by Takuto Nakamura on 2019/04/22.
//  Copyright © 2019 Takuto Nakamura. All rights reserved.
//

import UIKit

let e: CGFloat = 2.718281828459045

protocol OppaiViewDelegate: AnyObject {
    func animationFinished()
}

class OppaiView: UIView, CAAnimationDelegate {

    private var w: CGFloat { return self.frame.width }
    private var h: CGFloat { return self.frame.height }
    private var time: CGFloat = 0.0
    private var shapeLayer: CAShapeLayer?
    public var isTouching: Bool = false
    private var touchPoint: CGPoint  = CGPoint.zero
    public weak var delegate: OppaiViewDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        shapeLayer = CAShapeLayer(layer: self.layer)
        shapeLayer!.lineWidth = 3.0
        shapeLayer!.path = createOppai(CGPoint.zero, 0.0)
        shapeLayer!.lineJoin = CAShapeLayerLineJoin.round
        shapeLayer!.lineCap = CAShapeLayerLineCap.round
        shapeLayer!.strokeColor = UIColor.black.cgColor
        shapeLayer!.fillColor = UIColor.clear.cgColor
        self.layer.addSublayer(shapeLayer!)
    }
    
    override func draw(_ rect: CGRect) {
        if isTouching {
            UIColor.blue.setFill()
            let path = UIBezierPath(roundedRect: CGRect(x: touchPoint.x - 15, y: touchPoint.y - 15, width: 30, height: 30), cornerRadius: 15)
            path.fill()
        }
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        shapeLayer?.path = createOppai(CGPoint.zero, 0.0)
        shapeLayer?.removeAllAnimations()
        delegate?.animationFinished()
    }
    
    private func createPath(_ point: CGPoint) -> CGPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0.5 * h))
        path.addQuadCurve(to: CGPoint(x: w, y: 0.5 * h), controlPoint: CGPoint(x: 0.5 * w, y: point.y + 0.5 * h))
        return path.cgPath
    }
    
    private func createOppai(_ point: CGPoint, _ t: CGFloat) -> CGPath {
        let path = UIBezierPath()
        let uh: CGFloat = h / 320
        var x: CGFloat = 0.0
        var y: CGFloat = 0.0
        for i in 0 ... 320 {
            y = 0.025 * CGFloat(160 - i)
            x = 80 * calculateOppaiCurve(y: y, t: t) + 50.0
            if i == 0 {
                path.move(to: CGPoint(x: x, y: uh * CGFloat(i)))
            } else {
                path.addLine(to: CGPoint(x: x, y: uh * CGFloat(i)))
            }
        }
        
        return path.cgPath
    }
    
    private func calculateOppaiCurve(y: CGFloat, t: CGFloat) -> CGFloat {
        let sinT: CGFloat = 1.5 * 1.27 * pow(e, -t) * sin(2.0 * CGFloat.pi * t)
        var x: CGFloat = 0.0
        x += (1.5 * exp((0.12 * sinT - 0.5) * pow((y + 0.16 * sinT), 2.0))) / (1.0 + exp(-20.0 * (5.0 * y + sinT)))
        x += (1.5 + 0.8 * pow((y + 0.2 * sinT), 3.0)) / ((1.0 + exp(-1.0 * (100.0 * (y + 1.0) + 16.0 * sinT))) * (1.0 + exp(20.0 * (5.0 * y + sinT))))
        x += (0.2 * (exp(-1.0 * pow(y + 1.0, 2.0)) + 1.0)) / (1.0 + exp(100.0 * (y + 1.0) + 16.0 * sinT))
        x += 0.1 / exp(2.0 * pow((10.0 * y + 1.2 * (2.0 + sinT) * sinT), 4.0))
        return x
    }
    
    public func setPath(_ point: CGPoint) {
        time = min(max(2.0 * point.y / h, -0.09), 0.25)
        shapeLayer!.path = createOppai(point, time)
    }

    private func getTime(_ n: Int) -> CGFloat {
        return 0.25 * CGFloat(n)
    }
    
    public func animate(_ point: CGPoint) {
        let bounce = CAKeyframeAnimation(keyPath: "path")
        var values = [CGPath]()
        var duration = 1.0
        var m: Int = 0
        if time > 0.125 {
            m = 2
        } else if time > 0.0 {
            m = 1
        } else {
            duration = 1.4
        }
        for n in (m ... (24 + m)) {
            values.append(createOppai(point, CGFloat(n) / 8))
        }
        bounce.values = values
        bounce.calculationMode = .discrete
        bounce.duration = duration
        bounce.isRemovedOnCompletion = false
        bounce.fillMode = CAMediaTimingFillMode.forwards
        bounce.delegate = self
        self.shapeLayer?.add(bounce, forKey: "bounce")
    }
    
    public func setTouchPoint(_ p: CGPoint) {
        touchPoint = p
        self.setNeedsDisplay()
    }
    
}
