//
//  FavoritePhotosView.swift
//  WhiteAndFluffy
//
//  Created by Alexander Senin on 05.01.2023.
//

import UIKit

class FavoritePhotosView: UIView {

    init() {
        super.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        setupTableView()
        
        setupConstraints()
    }
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: frame)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FavoritePhotoCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private func setupTableView() {
        addSubview(tableView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.rightAnchor.constraint(equalTo: rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: leftAnchor)
        ])
    }
}
