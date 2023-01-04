//
//  DetailPhotoVC.swift
//  WhiteAndFluffy
//
//  Created by Alexander Senin on 04.01.2023.
//

import UIKit

class DetailPhotoVC: UIViewController {
    
    var photo: UIImage?
    var photoId = ""
    var username = ""
    var location = "location not specified"
    var downloads = 2361
    var creationDate = ""
    
    private var likedPhotos = [FavoritePhotoModel]()
    private var isPhotoLiked = false
    
    private var dataFetcherService: DataFetcherServiceProtocol!
    private var dataSenderService: DataSenderServiceProtocol!
    
    private let group = DispatchGroup()
    private let semaphore = DispatchSemaphore(value: 1)
    private let queue = DispatchQueue(label: "queue")
    
    init(dataFetcherService: DataFetcherServiceProtocol!, dataSenderService: DataSenderServiceProtocol!) {
        super.init(nibName: nil, bundle: nil)
        self.dataFetcherService = dataFetcherService
        self.dataSenderService = dataSenderService
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        photoImageView.image = photo
        usernameLabel.text = "author: \(username)"
        locationLabel.text = location
        downloadsLabel.text = "\(downloads) downloads"
        creationDateLabel.text = "created at \(creationDate.prefix(10))"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchLikedPhotos()

        configureView()
        configurePhotoImageView()
        configureLabels()
        configureLikeButton()
        
        setupConstraints()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshFavoritePhotos"),
                                        object: nil,
                                        userInfo: nil)
    }
    
    private func fetchLikedPhotos() {
        dataFetcherService.fetchFavoritePhotos { [self] likedPhotos in
            if let likedPhotos {
                
                self.likedPhotos = likedPhotos
                
                for likedPhoto in likedPhotos {
                    if likedPhoto.id == self.photoId {
                        isPhotoLiked = true
                    }
                }
                
                likeButton.setImage(UIImage(systemName: isPhotoLiked ? "heart.fill" : "heart"), for: .normal)
            }
        }
    }
    
    @objc private func likeButtonTapped() {
        
        let photoLikedAlert = UIAlertController(title: "Success", message: "You've liked the photo", preferredStyle: UIAlertController.Style.alert)
        photoLikedAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        
        let photoUnlikedAlert = UIAlertController(title: "Success", message: "You've unliked the photo", preferredStyle: UIAlertController.Style.alert)
        photoUnlikedAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        
        if isPhotoLiked {
            dataSenderService.sendPhotoUnlike(photoId: photoId) { [self] responseCode in
                guard responseCode != nil else { return }
                likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
                present(photoUnlikedAlert, animated: true, completion: nil)
            }
        } else {
            dataSenderService.sendPhotoLike(photoId: photoId) { [self] responseCode in
                guard responseCode != nil else { return }
                likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                present(photoLikedAlert, animated: true, completion: nil)
            }
        }
    }
    
    private lazy var photoImageView: UIImageView = {
        let photoImageView = UIImageView()
        photoImageView.image = photo
        photoImageView.clipsToBounds = true
        photoImageView.contentMode = .scaleAspectFill
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        return photoImageView
    }()
    
    private lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var downloadsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var locationLabel: UILabel = {
        let label = UILabel()
        label.text = "location not specified"
        label.font = UIFont.systemFont(ofSize: 17)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var creationDateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let likeButton: UIButton = {
        let button = UIButton()
        button.tintColor = .red
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private func configureView() {
        view.backgroundColor = .white
    }
    
    private func configurePhotoImageView() {
        view.addSubview(photoImageView)
    }
    
    private func configureLabels() {
        view.addSubview(usernameLabel)
        view.addSubview(downloadsLabel)
        view.addSubview(locationLabel)
        view.addSubview(creationDateLabel)
    }
    
    private func configureLikeButton() {
        view.addSubview(likeButton)
        likeButton.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            photoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            photoImageView.widthAnchor.constraint(equalToConstant: 350),
            photoImageView.heightAnchor.constraint(equalToConstant: 350),
            photoImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 24)
        ])
        
        NSLayoutConstraint.activate([
            usernameLabel.topAnchor.constraint(equalTo: photoImageView.bottomAnchor, constant: 50),
            usernameLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 25),
            usernameLabel.widthAnchor.constraint(equalToConstant: 120),
            usernameLabel.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        NSLayoutConstraint.activate([
            downloadsLabel.topAnchor.constraint(equalTo: photoImageView.bottomAnchor, constant: 50),
            downloadsLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -25),
            downloadsLabel.widthAnchor.constraint(equalToConstant: 120),
            downloadsLabel.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        NSLayoutConstraint.activate([
            locationLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 50),
            locationLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 25),
            locationLabel.widthAnchor.constraint(equalToConstant: 120),
            locationLabel.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        NSLayoutConstraint.activate([
            creationDateLabel.topAnchor.constraint(equalTo: downloadsLabel.bottomAnchor, constant: 50),
            creationDateLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -25),
            creationDateLabel.widthAnchor.constraint(equalToConstant: 120),
            creationDateLabel.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        NSLayoutConstraint.activate([
            likeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            likeButton.topAnchor.constraint(equalTo: creationDateLabel.bottomAnchor, constant: 50)
        ])
    }
}
