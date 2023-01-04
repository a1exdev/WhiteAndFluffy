//
//  FavoritePhotosVC.swift
//  WhiteAndFluffy
//
//  Created by Alexander Senin on 04.01.2023.
//

import UIKit

class FavoritePhotosVC: UIViewController {
    
    var networkService: NetworkServiceProtocol!
    var dataFetcherService: DataFetcherServiceProtocol!
    
    var photos = [FavoritePhotoModel]()
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
        
        setupNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupTableView()
        setupConstraints()
        
        loadPhotos()
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(loadPhotos),
            name: Notification.Name("RefreshFavoritePhotos"),
            object: nil)
    }
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: view.frame)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FavoritePhotoCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private func setupTableView() {
        view.addSubview(tableView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor)
        ])
    }
    
    @objc private func loadPhotos() {
        
        group.enter()
        dataFetcherService.fetchFavoritePhotos { [self] likedPhotos in
            if let likedPhotos {
                photos = likedPhotos
                group.leave()
            }
        }
        
        group.notify(queue: .main) { [self] in
            queue.async { [self] in
                images.removeAll()
                photos.forEach {
                    semaphore.wait()
                    networkService.request(url: $0.urls.small, httpMethod: nil) { [self] data, response, error in
                        guard let data = data, error == nil else { return }
                        images.append(UIImage(data: data)!)
                        semaphore.signal()
                        DispatchQueue.main.async { [self] in
                            tableView.reloadData()
                        }
                    }
                }
            }
        }
    }
}

extension FavoritePhotosVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images.count
    }
}

extension FavoritePhotosVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoritePhotoCell", for: indexPath)
        
        var content = cell.defaultContentConfiguration()
        content.image = images[indexPath.row]
        content.text = photos[indexPath.row].user.username
        
        cell.contentConfiguration = content
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let detailVC = DetailPhotoVC(dataFetcherService: DataFetcherService(), dataSenderService: DataSenderService())
        detailVC.modalPresentationStyle = .popover
        detailVC.photo = images[indexPath.item]
        detailVC.photoId = photos[indexPath.item].id
        detailVC.username = photos[indexPath.item].user.username
        detailVC.creationDate = photos[indexPath.item].createdAt
        
        if let place = photos[indexPath.item].user.location {
            detailVC.location = place
        }
        
        self.present(detailVC, animated: true, completion: nil)
    }
}
