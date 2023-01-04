//
//  RandomPhotosVC.swift
//  WhiteAndFluffy
//
//  Created by Alexander Senin on 04.01.2023.
//

import UIKit
import SHSearchBar

class RandomPhotosVC: UIViewController {
    
    var networkService: NetworkServiceProtocol!
    var dataFetcherService: DataFetcherServiceProtocol!
    
    var randomPhotos = [RandomPhotoModel]()
    var queryPhotos = [QueryPhotoModel]()
    var images = [UIImage]()
    
    private let group = DispatchGroup()
    private let semaphore = DispatchSemaphore(value: 1)
    private let queue = DispatchQueue(label: "queue")
    
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
        
        setupCollectionView()
        setupSearchBar()
        setupConstraints()
        
        fetchRandomPhotos()
    }
    
    private lazy var layout: UICollectionViewFlowLayout = {
        
        let viewWidth = view.frame.width / 2
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: viewWidth, height: viewWidth)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        return layout
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        collectionView.register(RandomPhotoCell.self, forCellWithReuseIdentifier: "RandomPhotoCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private lazy var searchBar: SHSearchBar = {
        let leftView = imageViewWithIcon(UIImage(systemName: "magnifyingglass")!.withRenderingMode(.alwaysTemplate), raster: 10)
        let searchBar = defaultSearchBar(withRasterSize: 10,
                                         leftView: leftView,
                                         rightView: nil,
                                         delegate: self)
        return searchBar
    }()
    
    private func setupSearchBar() {
        collectionView.addSubview(searchBar)
    }

    private func setupCollectionView() {
        view.addSubview(collectionView)
    }
    
    private func setupConstraints() {
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor)
        ])
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: collectionView.layoutMarginsGuide.topAnchor, constant: 10),
            searchBar.leadingAnchor.constraint(equalTo: collectionView.layoutMarginsGuide.leadingAnchor, constant: 10),
            searchBar.trailingAnchor.constraint(equalTo: collectionView.layoutMarginsGuide.trailingAnchor, constant: -10),
            searchBar.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func fetchRandomPhotos() {
        
        queryPhotos.removeAll()
        images.removeAll()
        
        group.enter()
        dataFetcherService.fetchRandomPhotos { [self] randomPhotos in
            if let randomPhotos {
                self.randomPhotos = randomPhotos
                group.leave()
            }
        }
        
        group.notify(queue: .main) { [self] in
            queue.async { [self] in
                randomPhotos.forEach {
                    semaphore.wait()
                    networkService.request(url: $0.urls.small, httpMethod: nil) { [self] data, response, error in
                        guard let data = data, error == nil else { return }
                        images.append(UIImage(data: data)!)
                        semaphore.signal()
                        DispatchQueue.main.async { [self] in
                            collectionView.reloadData()
                        }
                    }
                }
            }
        }
    }
}

extension RandomPhotosVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
}

extension RandomPhotosVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RandomPhotoCell", for: indexPath) as! RandomPhotoCell
        cell.photoImageView.image = images[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let detailVC = DetailPhotoVC(dataFetcherService: DataFetcherService(), dataSenderService: DataSenderService())
        detailVC.modalPresentationStyle = .popover
        detailVC.photo = images[indexPath.item]
        
        if queryPhotos.isEmpty {
            detailVC.photoId = randomPhotos[indexPath.item].id
            detailVC.username = randomPhotos[indexPath.item].user.username
            detailVC.downloads = randomPhotos[indexPath.item].downloads
            detailVC.creationDate = randomPhotos[indexPath.item].createdAt
            
            if let city = randomPhotos[indexPath.item].location?.city, let country = randomPhotos[indexPath.item].location?.country {
                detailVC.location = city + ", " + country
            }
        } else {
            detailVC.photoId = queryPhotos[indexPath.item].id
            detailVC.username = queryPhotos[indexPath.item].user.username
            detailVC.creationDate = queryPhotos[indexPath.item].createdAt
            
            if let place = queryPhotos[indexPath.item].user.location {
                detailVC.location = place
            }
        }
        
        self.present(detailVC, animated: true, completion: nil)
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
    
    private func fetchPhotosByQuery(query: String) {
        
        randomPhotos.removeAll()
        images.removeAll()
        
        group.enter()
        dataFetcherService.fetchPhotosByQuery(query: query) { [self] queryPhotos in
            if let queryPhotos {
                self.queryPhotos = queryPhotos.results
                group.leave()
            }
        }

        group.notify(queue: .main) { [self] in
            queue.async { [self] in
                queryPhotos.forEach {
                    semaphore.wait()
                    networkService.request(url: $0.urls.small, httpMethod: nil) { [self] data, response, error in
                        guard let data = data, error == nil else { return }
                        images.append(UIImage(data: data)!)
                        semaphore.signal()
                        DispatchQueue.main.async { [self] in
                            collectionView.reloadData()
                        }
                    }
                }
            }
        }
    }
}

// Methods for SHSearchBar (CocoaPods)
extension RandomPhotosVC {
    
    private func imageViewWithIcon(_ icon: UIImage, raster: CGFloat) -> UIView {
        let imgView = UIImageView(image: icon)
        imgView.translatesAutoresizingMaskIntoConstraints = false

        imgView.contentMode = .center
        imgView.tintColor = UIColor(red: 0.75, green: 0, blue: 0, alpha: 1)

        let container = UIView()
        container.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: raster, bottom: 0, trailing: raster)
        container.addSubview(imgView)

        NSLayoutConstraint.activate([
            imgView.leadingAnchor.constraint(equalTo: container.layoutMarginsGuide.leadingAnchor),
            imgView.trailingAnchor.constraint(equalTo: container.layoutMarginsGuide.trailingAnchor),
            imgView.topAnchor.constraint(equalTo: container.layoutMarginsGuide.topAnchor),
            imgView.bottomAnchor.constraint(equalTo: container.layoutMarginsGuide.bottomAnchor)
        ])

        return container
    }
    
    private func defaultSearchBar(withRasterSize rasterSize: CGFloat,
                          leftView: UIView?,
                          rightView: UIView?,
                          delegate: SHSearchBarDelegate,
                          useCancelButton: Bool = true) -> SHSearchBar {

        var config = defaultSearchBarConfig(rasterSize)
        config.leftView = leftView
        config.rightView = rightView
        config.useCancelButton = useCancelButton

        if leftView != nil {
            config.leftViewMode = .always
        }

        if rightView != nil {
            config.rightViewMode = .unlessEditing
        }

        let bar = SHSearchBar(config: config)
        bar.delegate = delegate
        bar.placeholder = "Search for photos"
        bar.updateBackgroundImage(withRadius: 6, corners: [.allCorners], color: UIColor.white)
        bar.layer.shadowColor = UIColor.black.cgColor
        bar.layer.shadowOffset = CGSize(width: 0, height: 3)
        bar.layer.shadowRadius = 5
        bar.layer.shadowOpacity = 0.25
        return bar
    }
    
    private func defaultSearchBarConfig(_ rasterSize: CGFloat) -> SHSearchBarConfig {
        var config: SHSearchBarConfig = SHSearchBarConfig()
        config.rasterSize = rasterSize
        config.cancelButtonTextAttributes = [.foregroundColor: UIColor.systemBlue]
        config.textContentType = UITextContentType.fullStreetAddress.rawValue
        config.textAttributes = [.foregroundColor: UIColor.gray]
        return config
    }
}
