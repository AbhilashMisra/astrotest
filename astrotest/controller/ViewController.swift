//
//  ViewController.swift
//  astrotest
//
//  Created by Abhilash Mishra on 22/03/23.
//

import UIKit
import Combine

class ViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    /// viewmodel for data and interaction
    private var viewModel: AstroFactsModalProvider!
    
    /// connectivity check
    private var isConnected = NetworkMonitor.shared.isConnected
    
    /// hold publishers ref
    private var anyCancellables = [AnyCancellable]()

    // MARK: Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        
        let dbc = DatabaseConnector()
        let apic = ApiConnector()
        let fc = FileStoreConnector()
        let fetcher = FactFetcher(apiConnector: apic, databaseConnector: dbc, fileStoreConnector: fc)
        let guc = GetFactUseCaseImplementation(fetcher: fetcher)
        let duc = ImageFetchUseCaseImplementation(fetcher: fetcher)
        viewModel = AstroViewModel(getUsecase: guc, downloadUsecase: duc)
        viewModel.data.receive(on: DispatchQueue.main).sink {[weak self] _ in
            self?.collectionView.reloadData()
        }.store(in: &anyCancellables)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Task {
            await viewModel.fetchPreviousDateData()
        }
    }
    
    deinit {
        anyCancellables.forEach({ $0.cancel() })
        anyCancellables.removeAll()
    }
    
    // MARK: Setup
    /// Setup collection view and flow
    private func setupCollectionView() {
        let itemLayoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemLayoutSize)
        
        
        let groupLayoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupLayoutSize, repeatingSubitem: item, count: 1)
        group.contentInsets = NSDirectionalEdgeInsets(top: 30, leading: 30, bottom: 30, trailing: 0)
        
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .paging
        section.visibleItemsInvalidationHandler = { (items, offset, environment) in
            items.forEach { item in
                let distanceFromCenter = abs((item.frame.midX - offset.x) - environment.container.contentSize.width / 2.0)
                let minScale: CGFloat = 0.9
                let maxScale: CGFloat = 1.1
                let scale = max(maxScale - (distanceFromCenter / environment.container.contentSize.width), minScale)
                item.transform = CGAffineTransform(scaleX: scale, y: scale)
            }
        }
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        collectionView.setCollectionViewLayout(layout, animated: false)
        collectionView.semanticContentAttribute = .forceRightToLeft
    }


}

// MARK: Collection Delegates
extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.data.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AstroCollectionViewCell", for: indexPath) as! AstroCollectionViewCell
        cell.backgroundColor = .lightGray.withAlphaComponent(0.3)
        let data = viewModel.data.value[indexPath.item]
        if let url = data.filePath {
            cell.astroImageView.image = UIImage(contentsOfFile: url)
        }
        cell.astroTitleLabel.text = data.title
        cell.astroDetailsLabel.text = data.explanation
        if let copyright = data.copyright, copyright.count > 0 {
            cell.astroCopyrightLabel.isHidden = false
            cell.astroCopyrightLabel.text = "Copyright: \(copyright)"
        } else {
            cell.astroCopyrightLabel.isHidden = true
            cell.astroCopyrightLabel.text = ""
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == viewModel.data.value.count - 1 {
            Task {
                await viewModel.fetchPreviousDateData()
            }
        }
    }
    
}

