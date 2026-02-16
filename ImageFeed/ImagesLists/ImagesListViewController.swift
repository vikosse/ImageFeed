//
//  ImagesListViewController.swift
//  ImageFeed
//
//  Created by Alekhina Viktoriya on 03/02/2026.
//

import UIKit

// MARK: - Private types
   
   private enum Layout {
       static let tableVerticalInset: CGFloat = 12
       static let imageVerticalInset: CGFloat = 8
       static let horizontalInset: CGFloat = 16
       static let defaultHeight: CGFloat = 200
   }

    private enum Images {
        static let liked = "FilledHeart"
        static let notLiked = "Heart"
    }

final class ImagesListViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet private var tableView: UITableView!

    // MARK: - Private properties
    private let photoNames: [String] = Array(0..<20).map(String.init)
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsets(
            top: Layout.tableVerticalInset,
            left: 0,
            bottom: Layout.tableVerticalInset,
            right: 0
        )
    }
    
    // MARK: - Private methods
    private func image(for indexPath: IndexPath) -> UIImage? {
        let imageName = photoNames[indexPath.row]
        return UIImage(named: imageName)
    }

    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard let image = image(for: indexPath) else { return }
        cell.cellImageView.image = image
        
        cell.dateLabel.text = dateFormatter.string(from: Date())
        
        let isLiked = indexPath.row % 2 == 0
        let likeImageName = isLiked ? Images.liked : Images.notLiked
        cell.likeButton.setImage(UIImage(named: likeImageName), for: .normal)
    }
}

    // MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photoNames.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
            
            guard let imageListCell = cell as? ImagesListCell else {
                return UITableViewCell()
            }
            
        configCell(for: imageListCell, with: indexPath)
            return imageListCell
        }
}

    // MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let image = image(for: indexPath) else {
                return Layout.defaultHeight
            }

            let tableWidth = tableView.bounds.width
            
            let imageViewWidth = tableWidth - Layout.horizontalInset * 2

            let ratio = image.size.height / image.size.width
            let imageViewHeight = imageViewWidth * ratio

            return imageViewHeight + Layout.imageVerticalInset
    }
}
