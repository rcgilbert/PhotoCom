//
//  PhotoCollectionViewCell.swift
//  PhotoCom
//
//  Created by Ryan Gilbert on 1/26/23.
//

import UIKit

/// Displays an image that is scaled to fill the cell. This cell can also be configured to display an error state.
final class PhotoCollectionViewCell: UICollectionViewCell {
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
        $0.font = .preferredFont(forTextStyle: .caption1)
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
            imageView.isHidden = showErrorState
        }
    }
    
    
    /// Setting this allows us to check if the cell has been reused before a Photo image has been loaded from the network.
    /// This is especially important when images take a long time to load and the user scrolls before the image is fully loaded. 
    var photoID: Int = -1
    
    static let defaultReuseIdentifier = "PhotoCollectionViewCell.defaultReuseIdentifier"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }
    
    private func setUp() {
        contentView.addSubview(imageView)
        contentView.addSubview(errorStackView)
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
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
    }
}
