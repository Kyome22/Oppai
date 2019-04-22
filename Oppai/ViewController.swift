//
//  ViewController.swift
//  Oppai
//
//  Created by Takuto Nakamura on 2019/04/22.
//  Copyright © 2019 Takuto Nakamura. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var oppaiView: OppaiView!
    var panGesture: UIPanGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.panHandle(_:)))
        panGesture!.delegate = self
        
        oppaiView.delegate = self
        oppaiView.addGestureRecognizer(panGesture!)
    }
    
    @objc func panHandle(_ sender: UIPanGestureRecognizer) {
        if sender.state == UIGestureRecognizer.State.began {
            oppaiView.isTouching = true
        }
        oppaiView.setTouchPoint(sender.location(in: oppaiView))
        let point: CGPoint = sender.translation(in: oppaiView)
        oppaiView.setPath(point)
        if sender.state == UIGestureRecognizer.State.ended, panGesture != nil {
            oppaiView.isTouching = false
            oppaiView.removeGestureRecognizer(panGesture!)
            oppaiView.animate(point)
        }
    }

}

extension ViewController: OppaiViewDelegate {
    func animationFinished() {
        oppaiView.addGestureRecognizer(panGesture!)
    }
}

