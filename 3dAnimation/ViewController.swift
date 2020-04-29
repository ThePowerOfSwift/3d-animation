//
//  ViewController.swift
//  3dAnimation
//
//  Created by Admin on 11/28/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit

struct CardPosition {
    var xOffset: CGFloat
    var yOffset: CGFloat
    var zOffset: CGFloat
    var xRotation: CGFloat
    var yRotation: CGFloat
    var zRotation: CGFloat
    var xScale: CGFloat
    var yScale: CGFloat
    var zScale: CGFloat
}

func deg2rad(_ number: CGFloat) -> CGFloat {
    return number * .pi / 180
}

class ViewController: UIViewController {
    @IBOutlet weak var mainImageView: UIView!
    
    var cardPosition = CardPosition(xOffset: 0, yOffset: 0, zOffset: 0, xRotation: 0, yRotation: 0, zRotation: 0, xScale: 1, yScale: 1, zScale: 1)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        cardPosition = CardPosition(xOffset: 20, yOffset: 170, zOffset: 82, xRotation: -65, yRotation: 0, zRotation: 38, xScale: 0.94, yScale: 0.88, zScale: 0.8)
        
        var perspective = self.mainImageView.layer.transform
        perspective.m34 = 1.0 / 800
        perspective = CATransform3DRotate(perspective, deg2rad(self.cardPosition.xRotation), 1.0, 0, 0)
        perspective = CATransform3DRotate(perspective, deg2rad(self.cardPosition.zRotation), 0, 0.0, 1)
        
        let positionTransform = CATransform3DMakeTranslation(self.cardPosition.xOffset, self.cardPosition.yOffset, self.cardPosition.zOffset)
        let scaleTransform = CATransform3DMakeScale(self.cardPosition.xScale, self.cardPosition.yScale, self.cardPosition.zScale)
        var combineTransform = CATransform3DConcat(perspective, positionTransform)
        combineTransform = CATransform3DConcat(combineTransform, scaleTransform)
        self.mainImageView.layer.transform = combineTransform
        self.mainImageView.layer.masksToBounds = false

        let gesture = UIPanGestureRecognizer(target: self, action: #selector(wasDragged(_:)))
        self.mainImageView.addGestureRecognizer(gesture)
        self.mainImageView.isUserInteractionEnabled = true
        
        rotateCard()
    }
    
    var lastPoint: CGFloat = 0
    var isMovingCard = false
    var cardVelocity: CGFloat = 0
    
    @objc func wasDragged(_ gestureRecognizer: UIPanGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizer.State.began {
            self.mainImageView.layer.removeAllAnimations()
            lastPoint = gestureRecognizer.translation(in: self.view).x
            
            if let imageTransform = self.mainImageView.layer.presentation()?.transform {
                self.mainImageView.layer.transform = imageTransform
            }
            
            self.mainImageView.layer.removeAllAnimations()
        }
        
        if gestureRecognizer.state == UIGestureRecognizer.State.changed {
            let perspective = self.mainImageView.layer.transform
            let currentPoint = gestureRecognizer.translation(in: self.view).x
            let offset = (currentPoint - lastPoint) / self.view.bounds.size.width
            
            let transformY = CATransform3DRotate(perspective, deg2rad(-100.0 * offset), 0.0, 0.0, 1.0)
            self.mainImageView.layer.transform = transformY
            lastPoint = currentPoint
        }
        
        if gestureRecognizer.state == .ended {
            self.cardVelocity = gestureRecognizer.velocity(in: self.view).x
            print("Velocity \(cardVelocity)")
            
            if abs(self.cardVelocity) > 500 {
                self.accelerateCard()
            } else {
                self.rotateCard()
            }
        }
    }

    func accelerateCard() {
        UIView.animate(withDuration: 0.5, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction, .curveEaseOut], animations: { [weak self] in
            guard let `self` = self else {
                return
            }
            
            let perspective = self.mainImageView.layer.transform
            let transformY = CATransform3DRotate(perspective, deg2rad(self.cardVelocity < 0 ? 170 : -170), 0.0, 0.0, 1.0)
            self.mainImageView.layer.transform = transformY
        }) { [weak self] (animated) in
            if animated {
                self?.rotateCard()
            }
        }
    }
    
    func rotateCard() {
        UIView.animate(withDuration: 4, delay: 0, options: [.beginFromCurrentState, .repeat ,.autoreverse, .allowUserInteraction], animations: { [weak self] in
            guard let `self` = self else {
                return
            }
            
            let perspective = self.mainImageView.layer.transform
            let transformY = CATransform3DRotate(perspective, deg2rad(self.cardVelocity < 0 ? 14 : -14), 0.0, 0.0, 1.0)
            self.mainImageView.layer.transform = transformY
        }, completion: nil)
    }
    
    func pauseLayer(layer: CALayer) {
        let pausedTime: CFTimeInterval = layer.convertTime(CACurrentMediaTime(), from: nil)
        layer.speed = 0.0
        layer.timeOffset = pausedTime
    }
    
    @IBAction func tapDismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UIView{
    func rotate() {
        UIView.animate(withDuration: 0.5, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction, .curveLinear], animations: {
            let perspective = self.layer.transform
            let transformY = CATransform3DRotate(perspective, deg2rad(90), 0.0, 0.0, 1.0)
            self.layer.transform = transformY
        }) { (animated) in
            if animated {
                self.rotate()
            }
        }
    }
}
