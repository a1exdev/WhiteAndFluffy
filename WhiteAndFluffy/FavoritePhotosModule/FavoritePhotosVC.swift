//
//  FavoritePhotosVC.swift
//  WhiteAndFluffy
//
//  Created by Alexander Senin on 04.01.2023.
//

import UIKit

class FavoritePhotosVC: ViewController<FavoritePhotosView> {
    
    var networkService: NetworkServiceProtocol!
    var dataFetcherService: DataFetcherServiceProtocol!
    
    var favoritePhotos = [FavoritePhotoModel]()
    
    init(networkService: NetworkServiceProtocol!, dataFetcherService: DataFetcherServiceProtocol!) {
        super.init(nibName: nil, bundle: nil)
        self.networkService = networkService
        self.dataFetcherService = dataFetcherService
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFavoritePhotosView()
        fetchPhotos()
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(fetchPhotos),
            name: Notification.Name("RefreshFavoritePhotos"),
            object: nil)
    }
    
    @objc private func fetchPhotos() {
    
        dataFetcherService.fetchFavoritePhotos { [weak self] favoritePhotos in
            if let favoritePhotos {
                self?.favoritePhotos = favoritePhotos
                self?.mainView.tableView.reloadData()
            }
        }
    }
    
    private func setupFavoritePhotosView() {
        mainView.tableView.dataSource = self
        mainView.tableView.delegate = self
    }
}

extension FavoritePhotosVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoritePhotos.count
    }
}

extension FavoritePhotosVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoritePhotoCell", for: indexPath)
        
        DispatchQueue.main.async { [weak self] in
            self?.networkService.request(url: self!.favoritePhotos[indexPath.row].urls.small, httpMethod: nil) { data, response, error in
                guard let data = data, error == nil else { return }
                
                var content = cell.defaultContentConfiguration()
                content.image = UIImage(data: data)!
                content.text = self!.favoritePhotos[indexPath.row].user.username
                cell.contentConfiguration = content
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        networkService.request(url: favoritePhotos[indexPath.item].urls.small, httpMethod: nil) { [weak self] data, response, error in
            guard let data = data, error == nil else { return }
            
            self?.showDetailVC(photo: UIImage(data: data)!,
                               photoId: self!.favoritePhotos[indexPath.item].id,
                               username: self!.favoritePhotos[indexPath.item].user.username,
                               location: self!.favoritePhotos[indexPath.item].user.location ?? "location not specified",
                               downloads: nil,
                               creationDate: self!.favoritePhotos[indexPath.item].createdAt)
        }
    }
    
    private func showDetailVC(photo: UIImage, photoId: String, username: String, location: String, downloads: Int?, creationDate: String) {
        let detailVC = DetailPhotoVC(dataFetcherService: DataFetcherService(),
                                     dataSenderService: DataSenderService(),
                                     photo: photo,
                                     photoId: photoId,
                                     username: username,
                                     location: location,
                                     downloads: downloads,
                                     creationDate: creationDate)
        present(detailVC, animated: true)
    }
}
