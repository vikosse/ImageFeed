//
//  ImagesListViewController.swift
//  ImageFeed
//
//  Created by Alekhina Viktoriya on 03/02/2026.
//

import UIKit

class ImagesListViewController: UIViewController {
    
    // MARK: - Private types
       
       private enum Layout {
           static let tableVerticalInset: CGFloat = 12
           static let imageVerticalInset: CGFloat = 8
           static let horizontalInset: CGFloat = 16
           static let defaultHeight: CGFloat = 200
       }
    
    // MARK: - Private properties
    private let photosName: [String] = Array(0..<20).map{ "\($0)" }
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
    
    // MARK: - IBOutlets
    @IBOutlet private var tableView: UITableView!

    
    // MARK: - Private functions
    private func image(for indexPath: IndexPath) -> UIImage? {
        let imageName = photosName[indexPath.row]
        return UIImage(named: imageName)
    }

    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard let image = image(for: indexPath) else { return }
        cell.cellImageView.image = image
        
        cell.dateLabel.text = dateFormatter.string(from: Date())
        
        let isLiked = indexPath.row % 2 == 0
        let likeImageName = isLiked ? "FilledHeart" : "Heart"
        cell.likeButton.setImage(UIImage(named: likeImageName), for: .normal)
    }
}

    // MARK: - Extentions
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photosName.count
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
