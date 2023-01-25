//
//  AlbumsViewController.swift
//  PhotoCom
//
//  Created by Ryan Gilbert on 1/25/23.
//

import UIKit
import Combine

/// Displays a table view with a list of albums and their owners.
final class AlbumsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let viewModel: AlbumsViewModelType
    private var cancellables: Set<AnyCancellable> = .init()
    
    private lazy var refreshControl: UIRefreshControl = {
        $0.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return $0
    }(UIRefreshControl())
    
    required init?(coder: NSCoder, viewModel: AlbumsViewModelType = AlbumsViewModel()) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        self.viewModel = AlbumsViewModel()
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        
        viewModel.state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
            switch state {
            case .loading:
               break
            case .success:
                self?.tableView.reloadData()
                self?.refreshControl.endRefreshing()
            case .failure:
                self?.refreshControl.endRefreshing()
            }
        }.store(in: &cancellables)
        
        viewModel.loadData()
    }
    
    private func configureView() {
        tableView.refreshControl = refreshControl
        tableView.register(AlbumTableViewCell.self, forCellReuseIdentifier: AlbumTableViewCell.defaultReuseIdentifier)
    }
    
    @objc private func refreshData() {
        viewModel.loadData()
    }
}

// MARK: - UITableViewDatasource

extension AlbumsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AlbumTableViewCell.defaultReuseIdentifier, for: indexPath)
        viewModel.configure(cell: cell, for: indexPath)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension AlbumsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let album = viewModel.album(for: indexPath)
        let photosViewModel = PhotosViewModel(album: album)
        let photosViewController = PhotosViewController(viewModel: photosViewModel)
        
        show(photosViewController, sender: self)
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
