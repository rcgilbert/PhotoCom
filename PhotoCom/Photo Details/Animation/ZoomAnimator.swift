//
//  ZoomAnimator.swift
//  PhotoCom
//
//  Created by Ryan Gilbert on 1/28/23.
//

import UIKit

protocol ZoomAnimatorDelegate: AnyObject {
    func transitionWillStartWith(zoomAnimator: ZoomAnimator)
    func transitionDidEndWith(zoomAnimator: ZoomAnimator)
    func referenceImageView(for zoomAnimator: ZoomAnimator) -> UIImageView?
    func referenceImageViewFrameInTransitioningView(for zoomAnimator: ZoomAnimator) -> CGRect?
}

/// This object creates and manages the zoom in and zoom out animation when transitioning between grid and full screen image displays.
/// This is meant to mimic the transition seen in the default iOS Photos app.
final class ZoomAnimator: NSObject {
    var isPresenting: Bool = true
    
    weak var fromDelegate: ZoomAnimatorDelegate?
    weak var toDelegate: ZoomAnimatorDelegate?
    
    var transitionImageView: UIImageView?
    
    private func animateZoomInTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toVC = transitionContext.viewController(forKey: .to),
              let fromVC = transitionContext.viewController(forKey: .from),
              let fromReferenceImageView = fromDelegate?.referenceImageView(for: self),
              let toReferenceImageView = toDelegate?.referenceImageView(for: self),
              let fromReferenceImageViewFrame = fromDelegate?.referenceImageViewFrameInTransitioningView(for: self),
              let toReferenceImageViewFrame = toDelegate?.referenceImageViewFrameInTransitioningView(for: self) else {
            return
        }
        
        let containerView = transitionContext.containerView
        
        toDelegate?.transitionWillStartWith(zoomAnimator: self)
        fromDelegate?.transitionWillStartWith(zoomAnimator: self)
        
        toVC.view.alpha = 0
        containerView.addSubview(toVC.view)
        
        let refImage = fromReferenceImageView.image
        
        if transitionImageView == nil {
            let transitionImageView = UIImageView(image: refImage)
            transitionImageView.contentMode = .scaleAspectFit
            transitionImageView.clipsToBounds = true
            transitionImageView.frame = fromReferenceImageViewFrame
            self.transitionImageView = transitionImageView
            containerView.addSubview(transitionImageView)
        }
        
        // In some cases(eg. error loading image) the image view may be hidden so we need
        // to make sure to restore the hidden value to the proper state at the end of the transition.
        let toImageWasHidden = toReferenceImageView.isHidden
        let fromImageWasHidden = fromReferenceImageView.isHidden
        fromReferenceImageView.isHidden = true
        toReferenceImageView.isHidden = true
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext),
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0) {
            self.transitionImageView?.frame = toReferenceImageViewFrame
            
            fromVC.view.alpha = 0
            toVC.view.alpha = 1.0
        } completion: { completed in
            self.transitionImageView?.removeFromSuperview()
            self.transitionImageView = nil
            
            toReferenceImageView.isHidden = toImageWasHidden
            fromReferenceImageView.isHidden = fromImageWasHidden
            fromVC.view.alpha = 1
            
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            self.toDelegate?.transitionDidEndWith(zoomAnimator: self)
            self.fromDelegate?.transitionDidEndWith(zoomAnimator: self)
        }
    }
    
    private func animateZoomOutTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
            let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let fromReferenceImageView = fromDelegate?.referenceImageView(for: self),
            let toReferenceImageView = toDelegate?.referenceImageView(for: self),
            let fromReferenceImageViewFrame = fromDelegate?.referenceImageViewFrameInTransitioningView(for: self),
            let toReferenceImageViewFrame = toDelegate?.referenceImageViewFrameInTransitioningView(for: self)
            else {
                return
        }
        
        let containerView = transitionContext.containerView
        
        fromDelegate?.transitionWillStartWith(zoomAnimator: self)
        toDelegate?.transitionWillStartWith(zoomAnimator: self)
        
        let referenceImage = fromReferenceImageView.image
        
        if transitionImageView == nil {
            let transitionImageView = UIImageView(image: referenceImage)
            transitionImageView.contentMode = .scaleAspectFit
            transitionImageView.clipsToBounds = true
            transitionImageView.frame = fromReferenceImageViewFrame
            self.transitionImageView = transitionImageView
            containerView.addSubview(transitionImageView)
        }
        
        containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
        
        // In some cases(eg. error loading image) the image view may be hidden so we need
        // to make sure to restore the hidden value to the proper state at the end of the transition.
        let toImageWasHidden = toReferenceImageView.isHidden
        let fromImageWasHidden = fromReferenceImageView.isHidden
        
        fromReferenceImageView.isHidden = true
        toReferenceImageView.isHidden = true
        
        let finalTransitionSize = toReferenceImageViewFrame
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext),
                       delay: 0,
                       options: []) {
            fromVC.view.alpha = 0
            self.transitionImageView?.frame = finalTransitionSize
            toVC.tabBarController?.tabBar.alpha = 1
        } completion: { completed in
            self.transitionImageView?.removeFromSuperview()
            toReferenceImageView.isHidden = toImageWasHidden
            fromReferenceImageView.isHidden = fromImageWasHidden
            
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            self.toDelegate?.transitionDidEndWith(zoomAnimator: self)
            self.fromDelegate?.transitionDidEndWith(zoomAnimator: self)
        }
    }
}

extension ZoomAnimator: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        isPresenting ? 0.5: 0.25
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if isPresenting {
            animateZoomInTransition(using: transitionContext)
        } else {
            animateZoomOutTransition(using: transitionContext)
        }
    }
}
