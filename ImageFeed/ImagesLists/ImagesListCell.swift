//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Alekhina Viktoriya on 15/02/2026.
//

import UIKit

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"

    // MARK: - IBOutlets
    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet weak var dateLabel : UILabel!
    @IBOutlet weak var likeButton: UIButton!
}
