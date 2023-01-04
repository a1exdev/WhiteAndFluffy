//
//  MainViewController.swift
//  WhiteAndFluffy
//
//  Created by Alexander Senin on 04.01.2023.
//

import UIKit

class MainViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMainVC()
    }
    
    func setupMainVC() {
        viewControllers = [
            createNavigationController(for: RandomPhotosVC(networkService: NetworkService(),
                                                           dataFetcherService: DataFetcherService()),
                                       title: "Random",
                                       image: UIImage(systemName: "questionmark.folder")!),
            createNavigationController(for: FavoritePhotosVC(networkService: NetworkService(),
                                                             dataFetcherService: DataFetcherService()),
                                       title: "Favorites",
                                       image: UIImage(systemName: "star.square")!)
        ]
    }
    
    private func createNavigationController(for rootViewController: UIViewController,
                                     title: String,
                                     image: UIImage) -> UIViewController {
        
        let navigationController = UINavigationController(rootViewController: rootViewController)
        
        navigationController.tabBarItem.title = title
        navigationController.tabBarItem.image = image
        navigationController.navigationBar.prefersLargeTitles = true
        rootViewController.navigationItem.title = title
        
        return navigationController
    }
}
