//
//  ETSSketchLayer.swift
//  DemoClass
//
//  Created by MAC193 on 1/7/20.
//  Copyright © 2020 MAC193. All rights reserved.
//

import UIKit
import SwiftSVG


public enum LineType
{
    case solidLine
    case dottedLine
}


protocol ETSDrawable
{
    var touchable : Bool { get }
}


struct ETSDrawableImage : ETSDrawable
{
    let image       : UIImage
    var touchable   : Bool
    {
        return false
    }
}


struct ETSDrawableSVG : ETSDrawable
{
    let svgData     : Data
    var touchable   : Bool
    {
        return true
    }
}


struct ETSDrawableStock : ETSDrawable
{
    let bezierPath  : UIBezierPath
    let tintColor   : UIColor
    let stockType   : LineType
    
    var touchable   : Bool
    {
        return true
    }
}


open class ETSSketchLayer : UIView
{
    let drawable : ETSDrawable
    
    private var tapGesture      : UITapGestureRecognizer?
    private var panGesture      : UIPanGestureRecognizer?
    private var pinchGesture    : UIPinchGestureRecognizer?
    private var rotateGesture   : UIRotationGestureRecognizer?
 
    required public init?(coder: NSCoder)
    {
        return nil
    }
    
    
    init(frame : CGRect, drawable : ETSDrawable)
    {
        self.drawable = drawable
        super.init(frame : frame)
        self.initGestureRecognizers()
        self.backgroundColor = .clear
    }
    
    
    private func initGestureRecognizers()
    {
        self.tapGesture = UITapGestureRecognizer(target: self, action: #selector(ETSImageLayer.didTap(_:)))
        if let tapGesture = self.tapGesture
        {
            self.addGestureRecognizer(tapGesture)
        }
        
        self.panGesture = UIPanGestureRecognizer(target: self, action: #selector(ETSImageLayer.didPan(_:)))
        if let panGesture = self.panGesture
        {
            self.addGestureRecognizer(panGesture)
        }
        
        self.rotateGesture = UIRotationGestureRecognizer(target: self, action: #selector(ETSImageLayer.didRotate(_:)))
        if let rotateGesture = self.rotateGesture
        {
            self.addGestureRecognizer(rotateGesture)
        }
        
        self.pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(ETSImageLayer.didPinch(_:)))
        if let pinchGesture = self.pinchGesture
        {
            self.addGestureRecognizer(pinchGesture)
        }
    }
}


extension ETSSketchLayer
{
    // To prevent ios13 present controller default gesture to dismiss screen while draw signature.
    open override func gestureRecognizerShouldBegin(_ gestureRecognizer : UIGestureRecognizer) -> Bool
    {
        if (self.tapGesture == gestureRecognizer)
        {
            return true// always work for select deselect
        }
        else
        {
            if (ETSSketchpadView.shared?.selected == self)
            {
                if ((self.panGesture == gestureRecognizer) || (self.pinchGesture == gestureRecognizer) || (self.rotateGesture == gestureRecognizer))
                {
                    return true
                }
                else
                {
                    return false
                }
            }
            else
            {
                return false
            }
        }
    }
    
    
    //MARK: Gesture Method
    @objc fileprivate func didTap(_ panGR : UITapGestureRecognizer)
    {
        if (ETSSketchpadView.shared?.selected == self)
        {
            ETSSketchpadView.shared?.setSelected(newLayer : nil)
        }
        else
        {
            ETSSketchpadView.shared?.setSelected(newLayer : self)
        }
    }
    
    
    @objc fileprivate func didPan(_ panGR : UIPanGestureRecognizer)
    {
        if ((self.drawable.touchable) && (ETSSketchpadView.shared?.selected == self))
        {
            self.superview!.bringSubviewToFront(self)
            var translation = panGR.translation(in : self)
            translation = translation.applying(self.transform)
            self.center.x += translation.x
            self.center.y += translation.y
            panGR.setTranslation(CGPoint.zero, in : self)
        }
    }
    
    
    @objc fileprivate func didPinch(_ gestureRecognizer : UIPinchGestureRecognizer)
    {
        if ((self.drawable.touchable) && (ETSSketchpadView.shared?.selected == self))
        {
            if gestureRecognizer.state == .began || gestureRecognizer.state == .changed
            {
               gestureRecognizer.view?.transform = (gestureRecognizer.view?.transform.scaledBy(x: gestureRecognizer.scale, y: gestureRecognizer.scale))!
               gestureRecognizer.scale = 1.0
            }
        }
    }
    
    
    @objc fileprivate func didRotate(_ rotationGR : UIRotationGestureRecognizer)
    {
        if ((self.drawable.touchable) && (ETSSketchpadView.shared?.selected == self))
        {
            self.superview!.bringSubviewToFront(self)
            let rotation = rotationGR.rotation
            self.transform = self.transform.rotated(by: rotation)
            rotationGR.rotation = 0.0
        }
    }
}
