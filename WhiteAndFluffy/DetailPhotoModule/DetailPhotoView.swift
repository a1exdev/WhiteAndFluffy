//
//  DetailPhotoView.swift
//  WhiteAndFluffy
//
//  Created by Alexander Senin on 05.01.2023.
//

import UIKit

class DetailPhotoView: UIView {
    
    init() {
        super.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        configureView()
        configurePhotoImageView()
        configureLabels()
        configureLikeButton()
        
        setupConstraints()
    }
    
    private func configureView() {
        backgroundColor = .white
    }
    
    private func configurePhotoImageView() {
        addSubview(photoImageView)
    }
    
    private func configureLabels() {
        addSubview(usernameLabel)
        addSubview(downloadsLabel)
        addSubview(locationLabel)
        addSubview(creationDateLabel)
    }
    
    private func configureLikeButton() {
        addSubview(likeButton)
    }
    
    lazy var photoImageView: UIImageView = {
        let photoImageView = UIImageView()
        photoImageView.clipsToBounds = true
        photoImageView.contentMode = .scaleAspectFill
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        return photoImageView
    }()
    
    lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var downloadsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var locationLabel: UILabel = {
        let label = UILabel()
        label.text = "location not specified"
        label.font = UIFont.systemFont(ofSize: 17)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var creationDateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let likeButton: UIButton = {
        let button = UIButton()
        button.tintColor = .red
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            photoImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            photoImageView.widthAnchor.constraint(equalToConstant: 350),
            photoImageView.heightAnchor.constraint(equalToConstant: 350),
            photoImageView.topAnchor.constraint(equalTo: topAnchor, constant: 24)
        ])
        
        NSLayoutConstraint.activate([
            usernameLabel.topAnchor.constraint(equalTo: photoImageView.bottomAnchor, constant: 50),
            usernameLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 25),
            usernameLabel.widthAnchor.constraint(equalToConstant: 120),
            usernameLabel.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        NSLayoutConstraint.activate([
            downloadsLabel.topAnchor.constraint(equalTo: photoImageView.bottomAnchor, constant: 50),
            downloadsLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -25),
            downloadsLabel.widthAnchor.constraint(equalToConstant: 120),
            downloadsLabel.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        NSLayoutConstraint.activate([
            locationLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 50),
            locationLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 25),
            locationLabel.widthAnchor.constraint(equalToConstant: 120),
            locationLabel.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        NSLayoutConstraint.activate([
            creationDateLabel.topAnchor.constraint(equalTo: downloadsLabel.bottomAnchor, constant: 50),
            creationDateLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -25),
            creationDateLabel.widthAnchor.constraint(equalToConstant: 120),
            creationDateLabel.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        NSLayoutConstraint.activate([
            likeButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            likeButton.topAnchor.constraint(equalTo: creationDateLabel.bottomAnchor, constant: 50)
        ])
    }
}
