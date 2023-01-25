//
//  ZoomTransitionController.swift
//  PhotoCom
//
//  Created by Ryan Gilbert on 1/28/23.
//

import UIKit

/// Configures the `ZoomAnimator` for `UINavigationController` push transitions. 
final class ZoomTransitionController: NSObject {
    let animator: ZoomAnimator = .init()
    
    weak var fromDelegate: ZoomAnimatorDelegate?
    weak var toDelegate: ZoomAnimatorDelegate?
}

extension ZoomTransitionController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .push {
            animator.isPresenting = true
            animator.fromDelegate = fromDelegate
            animator.toDelegate = toDelegate
        } else {
            animator.isPresenting = false
            let temp = fromDelegate
            animator.fromDelegate = toDelegate
            animator.toDelegate = temp
        }
        
        return animator
    }
}
