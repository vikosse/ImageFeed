import UIKit
import Kingfisher

// MARK: - ImagesListCellDelegate

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

// MARK: - ImagesListCell

final class ImagesListCell: UITableViewCell {

    // MARK: - Static Properties

    static let reuseIdentifier = "ImagesListCell"
    private static let animationStartTime = CACurrentMediaTime()

    // MARK: - Public Properties

    weak var delegate: ImagesListCellDelegate?

    // MARK: - IBOutlets

    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!

    // MARK: - Private Properties

    private var animationLayers = Set<CALayer>()
    private var isImageLoaded = false

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

    override func layoutSubviews() {
        super.layoutSubviews()

        guard !isImageLoaded, animationLayers.isEmpty else { return }
        addGradient(to: cellImageView, cornerRadius: 16)
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        cellImageView.kf.cancelDownloadTask()
        cellImageView.image = nil
        dateLabel.text = nil
        setIsLiked(false)
        isImageLoaded = false

        animationLayers.forEach { $0.removeFromSuperlayer() }
        animationLayers.removeAll()
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil {
            restartAnimations()
        }
    }

    // MARK: - Actions

    @objc private func didTapLikeButton() {
        delegate?.imageListCellDidTapLike(self)
    }

    // MARK: - Public Methods

    func setIsLiked(_ isLiked: Bool) {
        let image = isLiked ? UIImage(resource: .filledHeart) : UIImage(resource: .heart)
        likeButton.setImage(image, for: .normal)
        likeButton.accessibilityIdentifier = isLiked ? "FilledHeart" : "Heart"
    }

    func setImage(url: URL?, placeholder: UIImage?) {
        isImageLoaded = false
        animationLayers.forEach { $0.removeFromSuperlayer() }
        animationLayers.removeAll()
        addGradient(to: cellImageView, cornerRadius: 16)

        cellImageView.kf.indicatorType = .none
        cellImageView.kf.setImage(
            with: url,
            placeholder: placeholder,
            options: [.transition(.fade(0.2))]
        ) { [weak self] result in
            guard let self else { return }
            self.animationLayers.forEach { $0.removeFromSuperlayer() }
            self.animationLayers.removeAll()
            switch result {
            case .success:
                self.isImageLoaded = true
            case .failure:
                self.isImageLoaded = false
            }
        }
    }

    // MARK: - Private Methods

    private func addGradient(to view: UIView, cornerRadius: CGFloat = 0) {
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.locations = [0, 0.1, 0.3]
        gradient.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 0.3).cgColor,
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 0.3).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.cornerRadius = cornerRadius
        gradient.masksToBounds = true

        let animation = CABasicAnimation(keyPath: "locations")
        animation.duration = 1.0
        animation.repeatCount = .infinity
        animation.fromValue = [0, 0.1, 0.3]
        animation.toValue = [0, 0.8, 1]
        animation.beginTime = ImagesListCell.animationStartTime
        gradient.add(animation, forKey: "locationsChange")

        view.layer.addSublayer(gradient)
        animationLayers.insert(gradient)
    }

    private func restartAnimations() {
        for layer in animationLayers {
            let animation = CABasicAnimation(keyPath: "locations")
            animation.duration = 1.0
            animation.repeatCount = .infinity
            animation.fromValue = [0, 0.1, 0.3]
            animation.toValue = [0, 0.8, 1]
            animation.beginTime = ImagesListCell.animationStartTime
            layer.add(animation, forKey: "locationsChange")
        }
    }
}
