//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Alekhina Viktoriya on 23/02/2026.
//
import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController {

    // MARK: - Private property
    var imageURL: URL?

    // MARK: - IB Outlets & Action

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func didTapShareButton(_ sender: UIButton) {
        guard let image = imageView.image else { return }
        let share = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(share, animated: true)
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.delegate = self
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true

        loadImage()
    }

    // MARK: - Private methods

    private func loadImage() {
        guard let url = imageURL else {
            print("url is nil")
            return }

        UIBlockingProgressHUD.show()

        imageView.kf.setImage(with: url) { [weak self] result in

            UIBlockingProgressHUD.dismiss()

            guard let self else { return }

            switch result {
            case .success(let value):
                let image = value.image
                self.imageView.frame.size = image.size
                self.rescaleAndCenterImageInScrollView(image: image)

            case .failure:
                self.showError()
            }
        }
    }

    private func showError() {
        let alert = UIAlertController(
            title: "Что-то пошло не так",
            message: "Попробовать ещё раз?",
            preferredStyle: .alert
        )

        let retryAction = UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            self?.loadImage()
        }

        alert.addAction(retryAction)

        present(alert, animated: true)
    }

    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale

        view.layoutIfNeeded()

        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size

        guard imageSize.width > 0,
              imageSize.height > 0,
              visibleRectSize.width > 0,
              visibleRectSize.height > 0 else {
            return
        }

        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()

        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2

        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)

        scrollView.zoomScale = scale
        updateInsetsForCentering()
    }

    private func updateInsetsForCentering() {
        let scrollSize = scrollView.bounds.size
        let contentSize = scrollView.contentSize

        let verticalInset = max(0, (scrollSize.height - contentSize.height) / 2)
        let horizontalInset = max(0, (scrollSize.width - contentSize.width) / 2)

        scrollView.contentInset = UIEdgeInsets(
            top: verticalInset,
            left: horizontalInset,
            bottom: verticalInset,
            right: horizontalInset
        )
    }
}
// MARK: - UIScrollViewDelegate
extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateInsetsForCentering()
    }

    func scrollViewDidEndZooming(
        _ scrollView: UIScrollView,
        with view: UIView?,
        atScale scale: CGFloat
    ) {
        updateInsetsForCentering()
    }
}
