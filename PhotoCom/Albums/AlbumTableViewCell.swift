//
//  AlbumTableViewCell.swift
//  PhotoCom
//
//  Created by Ryan Gilbert on 1/26/23.
//

import UIKit

/// A minimalist cell for use to display an Album title and its owner.
final class AlbumTableViewCell: UITableViewCell {
    lazy var titleLabel: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = .preferredFont(forTextStyle: .headline)
        $0.textAlignment = .natural
        $0.textColor = .label
        $0.numberOfLines = 0
        return $0
    }(UILabel())

    lazy var ownerLabel: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = .preferredFont(forTextStyle: .subheadline)
        $0.textAlignment = .natural
        $0.textColor = .secondaryLabel
        return $0
    }(UILabel())
    
    static let defaultReuseIdentifier = "AlbumTableViewCell.defaultReuseIdentifier"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpView()
    }
    
    private func setUpView() {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, ownerLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 8
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate(
            [stackView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 16),
             stackView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -16),
             stackView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 16),
             stackView.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -16)]
        )
        
        accessoryType = .disclosureIndicator
    }
}
