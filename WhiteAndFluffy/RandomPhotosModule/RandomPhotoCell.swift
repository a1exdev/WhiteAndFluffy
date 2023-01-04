//
//  RandomPhotosCell.swift
//  WhiteAndFluffy
//
//  Created by Alexander Senin on 04.01.2023.
//

import UIKit

class RandomPhotoCell: UICollectionViewCell {
    
    lazy var photoImageView: UIImageView = {
        let photoImageView = UIImageView()
        photoImageView.clipsToBounds = true
        photoImageView.contentMode = .scaleAspectFill
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        return photoImageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupPhotoImageView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupPhotoImageView() {
        contentView.addSubview(photoImageView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            photoImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            photoImageView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            photoImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            photoImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor)
        ])
    }
}
