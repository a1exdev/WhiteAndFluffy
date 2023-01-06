//
//  RandomPhotosView.swift
//  WhiteAndFluffy
//
//  Created by Alexander Senin on 05.01.2023.
//

import UIKit
import SHSearchBar

class RandomPhotosView: UIView {
    
    let screenWidth = UIScreen.main.bounds.size.width
    let screenHeight = UIScreen.main.bounds.size.height
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        setupTableView()
        
        setupConstraints()
    }

    private lazy var layout: UICollectionViewFlowLayout = {
        
        let viewWidth = frame.width / 2
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: viewWidth, height: viewWidth)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        return layout
    }()
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.register(RandomPhotoCell.self, forCellWithReuseIdentifier: "RandomPhotoCell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    private func setupTableView() {
        addSubview(collectionView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.rightAnchor.constraint(equalTo: rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            collectionView.leftAnchor.constraint(equalTo: leftAnchor)
        ])
    }
    
    func imageViewWithIcon(_ icon: UIImage, raster: CGFloat) -> UIView {
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
    
    func defaultSearchBar(withRasterSize rasterSize: CGFloat,
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
