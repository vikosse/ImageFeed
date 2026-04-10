//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Alekhina Viktoriya on 15/02/2026.
//
import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {

    // MARK: - Static properties

    static let reuseIdentifier = "ImagesListCell"

    // MARK: - Public properties

    weak var delegate: ImagesListCellDelegate?

    // MARK: - IBOutlets

    @IBOutlet private weak var cellImageView: UIImageView!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var likeButton: UIButton!

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        likeButton
            .addTarget(
                self,
                action: #selector(didTapLikeButton),
                for: .touchUpInside
            )
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        cellImageView.kf.cancelDownloadTask()
        cellImageView.image = nil
        dateLabel.text = nil
        setIsLiked(false)
    }

    // MARK: - Actions

    @objc private func didTapLikeButton() {
        delegate?.imageListCellDidTapLike(self)
    }

    // MARK: - Public methods
    func setIsLiked(_ isLiked: Bool) {
        let image = isLiked ? UIImage(
            resource: .filledHeart
        ) : UIImage(resource: .heart
        )
        likeButton.setImage(image, for: .normal)
    }

}
