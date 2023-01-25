//
//  PhotoDetailsCollectionViewCell.swift
//  PhotoCom
//
//  Created by Ryan Gilbert on 1/28/23.
//

import UIKit

/// The cell displays an image scaled to fit into the given space. It also enables pinch to zoom on the image.
class PhotoDetailsCollectionViewCell: UICollectionViewCell {
    
    lazy var scrollView: UIScrollView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.minimumZoomScale = 1
        $0.maximumZoomScale = 5
        $0.contentInsetAdjustmentBehavior = .never
        $0.delegate = self
        return $0
    }(UIScrollView())
    
    lazy var imageView: LoadingImageView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentMode = .scaleAspectFill
        return $0
    }(LoadingImageView())
    
    private lazy var errorImageView: UIImageView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentMode = .center
        $0.image = UIImage(systemName: "exclamationmark.circle")?.withRenderingMode(.alwaysTemplate)
        $0.tintColor = .systemRed
        return $0
    }(UIImageView())
    
    private lazy var errorLabel: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = .preferredFont(forTextStyle: .headline)
        $0.textColor = .label
        $0.numberOfLines = 2
        $0.textAlignment = .center
        $0.text = NSLocalizedString("Failed to load image.", comment: "Failure message when loading image from network.")
        return $0
    }(UILabel())
    
    private lazy var errorStackView: UIStackView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.axis = .vertical
        $0.alignment = .center
        $0.spacing = 8
        $0.isHidden = true
        return $0
    }(UIStackView(arrangedSubviews: [errorImageView, errorLabel]))
    
    /// Setting this to true will confiure the cell to display an error state rather than the `LoadingImageView`
    var showErrorState: Bool = false {
        didSet {
            errorStackView.isHidden = !showErrorState
            scrollView.isHidden = showErrorState
        }
    }
    
    
    /// Setting this allows us to check if the cell has been reused before a Photo image has been loaded from the network.
    /// This is especially important when images take a long time to load and the user scrolls before the image is fully loaded.
    var photoID: Int = -1
    
    static let defaultReuseIdentifier = "PhotoDetailsCollectionViewCell.defaultReuseIdentifier"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }
    
    private func setUp() {
        scrollView.addSubview(imageView)
        contentView.addSubview(scrollView)
        contentView.addSubview(errorStackView)
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: contentView.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            imageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            imageView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            imageView.heightAnchor  .constraint(equalTo: contentView.heightAnchor),
            
            errorStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            errorStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            errorStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Reset cell state
        showErrorState = false
        photoID = -1
        scrollView.zoomScale = 1
    }
}

// MARK: - UIScrollViewDelegate

extension PhotoDetailsCollectionViewCell: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView.image == nil ? nil: imageView
    }
}
