//
//  RandomPhotosVC.swift
//  WhiteAndFluffy
//
//  Created by Alexander Senin on 04.01.2023.
//

import UIKit
import SHSearchBar

class RandomPhotosVC: ViewController<RandomPhotosView> {
    
    var networkService: NetworkServiceProtocol!
    var dataFetcherService: DataFetcherServiceProtocol!
    
    var randomPhotos = [RandomPhotoModel]()
    var queryPhotos = [QueryPhotoModel]()
    
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
        setupRandomPhotosView()
        fetchRandomPhotos()
    }
    
    private func fetchRandomPhotos() {
        queryPhotos.removeAll()
        fetchPhotos(query: nil)
    }
    
    private func fetchPhotosByQuery(query: String) {
        randomPhotos.removeAll()
        fetchPhotos(query: query)
    }
    
    private func fetchPhotos(query: String?) {
        
        if query == nil {
            dataFetcherService.fetchRandomPhotos { [weak self] randomPhotos in
                if let randomPhotos {
                    self?.randomPhotos = randomPhotos
                    self?.mainView.collectionView.reloadData()
                }
            }
        } else {
            dataFetcherService.fetchPhotosByQuery(query: query!) { [weak self] queryPhotos in
                if let queryPhotos {
                    self?.queryPhotos = queryPhotos.results
                    self?.mainView.collectionView.reloadData()
                }
            }
        }
    }
    
    private lazy var searchBar: SHSearchBar = {
        let leftView = mainView.imageViewWithIcon(UIImage(systemName: "magnifyingglass")!.withRenderingMode(.alwaysTemplate), raster: 10)
        let searchBar = mainView.defaultSearchBar(withRasterSize: 10,
                                         leftView: leftView,
                                         rightView: nil,
                                         delegate: self)
        return searchBar
    }()
    
    private func setupRandomPhotosView() {
        mainView.collectionView.dataSource = self
        mainView.collectionView.delegate = self
        
        mainView.collectionView.addSubview(searchBar)
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: mainView.collectionView.layoutMarginsGuide.topAnchor, constant: 10),
            searchBar.leadingAnchor.constraint(equalTo: mainView.collectionView.layoutMarginsGuide.leadingAnchor, constant: 10),
            searchBar.trailingAnchor.constraint(equalTo: mainView.collectionView.layoutMarginsGuide.trailingAnchor, constant: -10),
            searchBar.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
}

extension RandomPhotosVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if queryPhotos.isEmpty {
            return randomPhotos.count
        } else {
            return queryPhotos.count
        }
    }
}

extension RandomPhotosVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RandomPhotoCell", for: indexPath) as! RandomPhotoCell
        
        if queryPhotos.isEmpty {
            DispatchQueue.main.async { [weak self] in
                self?.networkService.request(url: self!.randomPhotos[indexPath.row].urls.small, httpMethod: nil) { data, response, error in
                    guard let data = data, error == nil else { return }
                    cell.photoImageView.image = UIImage(data: data)!
                }
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.networkService.request(url: self!.queryPhotos[indexPath.row].urls.small, httpMethod: nil) { data, response, error in
                    guard let data = data, error == nil else { return }
                    cell.photoImageView.image = UIImage(data: data)!
                }
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        var location = "location not specified"
        
        if queryPhotos.isEmpty {
            if let city = randomPhotos[indexPath.item].location?.city, let country = randomPhotos[indexPath.item].location?.country {
                location = city + ", " + country
            }
            
            networkService.request(url: randomPhotos[indexPath.item].urls.small, httpMethod: nil) { [weak self] data, response, error in
                guard let data = data, error == nil else { return }
                
                self?.showDetailVC(photo: UIImage(data: data)!,
                             photoId: self!.randomPhotos[indexPath.item].id,
                             username: self!.randomPhotos[indexPath.item].user.username,
                             location: location,
                             downloads: self!.randomPhotos[indexPath.item].downloads,
                             creationDate: self!.randomPhotos[indexPath.item].createdAt)
            }
        } else {
            if let place = queryPhotos[indexPath.item].user.location {
                location = place
            }
            
            networkService.request(url: queryPhotos[indexPath.item].urls.small, httpMethod: nil) { [weak self] data, response, error in
                guard let data = data, error == nil else { return }
                
                self?.showDetailVC(photo: UIImage(data: data)!,
                             photoId: self!.queryPhotos[indexPath.item].id,
                             username: self!.queryPhotos[indexPath.item].user.username,
                             location: location,
                             downloads: nil,
                             creationDate: self!.queryPhotos[indexPath.item].createdAt)
            }
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

extension RandomPhotosVC: SHSearchBarDelegate {
    
    func searchBarShouldReturn(_ searchBar: SHSearchBar) -> Bool {
        
        if searchBar.text != "" {
            fetchPhotosByQuery(query: searchBar.text!)
        } else {
            fetchRandomPhotos()
        }
        return false
    }
}
