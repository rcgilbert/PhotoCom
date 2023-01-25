//
//  LoadingImageView.swift
//  PhotoCom
//
//  Created by Ryan Gilbert on 1/26/23.
//

import UIKit

/// An Image View that displays a `UIActivityIndicatorView` while the image is `nil`.
class LoadingImageView: UIImageView {
    override var image: UIImage? {
        didSet {
            updateActivityIndicator()
        }
    }
    
    private lazy var activityIndictor: UIActivityIndicatorView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.hidesWhenStopped = true
        return $0
    }(UIActivityIndicatorView(style: .medium))
    
    override init(image: UIImage? = nil) {
        super.init(image: image)
        setUpView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpView()
    }
    
    private func setUpView() {
        addSubview(activityIndictor)
        
        NSLayoutConstraint.activate([
            activityIndictor.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndictor.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        updateActivityIndicator()
    }
    
    private func updateActivityIndicator() {
        if image == nil {
            activityIndictor.startAnimating()
        } else {
            activityIndictor.stopAnimating()
        }
    }
}
