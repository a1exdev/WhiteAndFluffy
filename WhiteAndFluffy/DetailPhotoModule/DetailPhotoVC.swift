//
//  DetailPhotoVC.swift
//  WhiteAndFluffy
//
//  Created by Alexander Senin on 04.01.2023.
//

import UIKit

class DetailPhotoVC: ViewController<DetailPhotoView> {
    
    var photo: UIImage!
    var photoId: String!
    var username: String!
    var location: String!
    var downloads: Int!
    var creationDate: String!
    
    private var likedPhotos = [FavoritePhotoModel]()
    private var isPhotoLiked = false
    
    private var dataFetcherService: DataFetcherServiceProtocol!
    private var dataSenderService: DataSenderServiceProtocol!
    
    init(dataFetcherService: DataFetcherServiceProtocol!,
         dataSenderService: DataSenderServiceProtocol!,
         photo: UIImage!,
         photoId: String,
         username: String!,
         location: String!,
         downloads: Int?,
         creationDate: String!) {
        
        super.init(nibName: nil, bundle: nil)
        
        self.dataFetcherService = dataFetcherService
        self.dataSenderService = dataSenderService
        
        self.photo = photo
        self.photoId = photoId
        self.username = username
        self.location = location
        self.downloads = downloads
        self.creationDate = creationDate
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDetailView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchLikedPhotos()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshFavoritePhotos"),
                                        object: nil,
                                        userInfo: nil)
    }
    
    private func setupDetailView() {
        mainView.photoImageView.image = photo
        mainView.usernameLabel.text = "author: \(username ?? "-")"
        mainView.locationLabel.text = location
        mainView.downloadsLabel.text = "\(downloads ?? 2361) downloads"
        mainView.creationDateLabel.text = "created at \(creationDate.prefix(10))"
        
        mainView.likeButton.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
    }
    
    private func fetchLikedPhotos() {
        
        dataFetcherService.fetchFavoritePhotos { [weak self] likedPhotos in
            if let likedPhotos {
                
                self?.likedPhotos = likedPhotos
                
                for likedPhoto in likedPhotos {
                    if likedPhoto.id == self?.photoId {
                        self?.isPhotoLiked = true
                    }
                }
                
                self?.mainView.likeButton.setImage(UIImage(systemName: self!.isPhotoLiked ? "heart.fill" : "heart"), for: .normal)
            }
        }
    }
    
    @objc private func likeButtonTapped() {
        
        let photoLikedAlert = UIAlertController(title: "Success", message: "You've liked the photo", preferredStyle: UIAlertController.Style.alert)
        photoLikedAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        
        let photoUnlikedAlert = UIAlertController(title: "Success", message: "You've unliked the photo", preferredStyle: UIAlertController.Style.alert)
        photoUnlikedAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        
        if isPhotoLiked {
            dataSenderService.sendPhotoUnlike(photoId: photoId) { [weak self] responseCode in
                guard responseCode != nil else { return }
                self?.mainView.likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
                self?.present(photoUnlikedAlert, animated: true, completion: nil)
            }
        } else {
            dataSenderService.sendPhotoLike(photoId: photoId) { [weak self] responseCode in
                guard responseCode != nil else { return }
                self?.mainView.likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                self?.present(photoLikedAlert, animated: true, completion: nil)
            }
        }
    }
}
