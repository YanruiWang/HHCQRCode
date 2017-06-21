//
//  PreviewRect.swift
//  HHCQRCode
//
//  Created by 王彦睿 on 2017/1/21.
//  Copyright © 2017年 家健文化传媒. All rights reserved.
//

import UIKit

class PreviewRect: UIView {

    override func draw(_ rect: CGRect) {
        drawCorner()
        drawBorder()
    }
    
    fileprivate func drawCorner() {
        // 左上
        drawLineFromPoint(start: CGPoint(x: bounds.origin.x, y: bounds.origin.y + 2), toPoint: CGPoint(x: bounds.origin.x + 20, y: bounds.origin.y + 2), ofColor: UIColor.white, lineWidth: 4)
        drawLineFromPoint(start: CGPoint(x: bounds.origin.x + 2, y: bounds.origin.y), toPoint: CGPoint(x: bounds.origin.x + 2, y: bounds.origin.y + 20), ofColor: UIColor.white, lineWidth: 4)
        // 左下
        drawLineFromPoint(start: CGPoint(x: bounds.origin.x, y: bounds.size.height - 2), toPoint: CGPoint(x: bounds.origin.x + 20, y: bounds.size.height - 2), ofColor: UIColor.white, lineWidth: 4)
        drawLineFromPoint(start: CGPoint(x: bounds.origin.x + 2, y: bounds.size.height), toPoint: CGPoint(x: bounds.origin.x + 2, y: bounds.size.height - 20), ofColor: UIColor.white, lineWidth: 4)
        // 右上
        drawLineFromPoint(start: CGPoint(x: bounds.size.width, y: bounds.origin.y + 2), toPoint: CGPoint(x: bounds.size.width - 20, y: bounds.origin.y + 2), ofColor: UIColor.white, lineWidth: 4)
        drawLineFromPoint(start: CGPoint(x: bounds.size.width - 2, y: bounds.origin.y), toPoint: CGPoint(x: bounds.size.width - 2, y: bounds.origin.y + 20), ofColor: UIColor.white, lineWidth: 4)
        // 右下
        drawLineFromPoint(start: CGPoint(x: bounds.size.width, y: bounds.size.height - 2), toPoint: CGPoint(x: bounds.size.width - 20, y: bounds.size.height - 2), ofColor: UIColor.white, lineWidth: 4)
        drawLineFromPoint(start: CGPoint(x: bounds.size.width - 2, y: bounds.size.height), toPoint: CGPoint(x: bounds.size.width - 2, y: bounds.size.height - 20), ofColor: UIColor.white, lineWidth: 4)
    }
    
    fileprivate func drawBorder() {
        
        let path = UIBezierPath(rect: bounds)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 1.0
        
        layer.addSublayer(shapeLayer)
    }
    
    fileprivate func drawLineFromPoint(start : CGPoint, toPoint end:CGPoint, ofColor lineColor: UIColor, lineWidth: CGFloat) {
        
        //design the path
        let path = UIBezierPath()
        path.move(to: start)
        path.addLine(to: end)
        
        //design path in layer
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = lineColor.cgColor
        shapeLayer.lineWidth = lineWidth
        
        layer.addSublayer(shapeLayer)
    }
    
    

}


