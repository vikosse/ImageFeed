//
//  ImagesListViewController.swift
//  ImageFeed
//
//  Created by Alekhina Viktoriya on 03/02/2026.
//
import UIKit
import Kingfisher

// MARK: - Private types

private enum Layout {
    static let tableVerticalInset: CGFloat = 12
    static let imageVerticalInset: CGFloat = 8
    static let horizontalInset: CGFloat = 16
    static let defaultHeight: CGFloat = 200
}

private enum FeedState {
    case loading
    case loaded
}

final class ImagesListViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet private var tableView: UITableView!

    // MARK: - Private properties
    private let imagesListService = ImagesListService.shared
    private var photos: [Photo] = []
    private var imagesListObserver: NSObjectProtocol?
    private var state: FeedState = .loading

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        setupObserver()

        imagesListService.fetchPhotosNextPage()
    }

    deinit {
        if let imagesListObserver {
            NotificationCenter.default.removeObserver(imagesListObserver)
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "ShowSingleImage",
              let viewController = segue.destination as? SingleImageViewController,
              let indexPath = tableView.indexPathForSelectedRow,
              photos.indices.contains(indexPath.row) else {
            return
        }

        let photo = photos[indexPath.row]
        viewController.imageURL = URL(string: photo.largeImageURL)
    }

    // MARK: - Setup

    private func setupTableView() {
        tableView.contentInset = UIEdgeInsets(
            top: Layout.tableVerticalInset,
            left: 0,
            bottom: Layout.tableVerticalInset,
            right: 0
        )
    }

    private func setupObserver() {
        imagesListObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: imagesListService,
            queue: .main
        ) { [weak self] _ in
            self?.updateTableViewAnimated()
        }
    }

    // MARK: - Private methods

    private func configCell(
        for cell: ImagesListCell,
        with indexPath: IndexPath
    ) {
        guard state == .loaded else { return }

        let photo = photos[indexPath.row]
        cell.delegate = self
        cell.setImage(
            url: URL(string: photo.thumbImageURL),
            placeholder: nil
        )

        cell.dateLabel.text = photo.createdAt.map {
            dateFormatter.string(from: $0)
        }

        cell.setIsLiked(photo.isLiked)
    }

    private func updateTableViewAnimated() {
        let newPhotos = imagesListService.photos
        guard !newPhotos.isEmpty else { return }

        let oldCount = photos.count
        let newCount = newPhotos.count
        photos = newPhotos

        if state == .loading {
            state = .loaded
            tableView.reloadData()
        } else {
            guard oldCount < newCount else { return }
            let indexPaths = (oldCount ..< newCount).map { IndexPath(row: $0, section: 0) }
            tableView.performBatchUpdates {
                tableView.insertRows(at: indexPaths, with: .automatic)
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch state {
        case .loading: return 10
        case .loaded: return photos.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath
        )

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
        switch state {
        case .loading:
            return 200
        case .loaded:
            let photo = photos[indexPath.row]
            guard photo.size.width > 0 else { return Layout.defaultHeight }
            let tableWidth = tableView.bounds.width
            let imageViewWidth = tableWidth - Layout.horizontalInset * 2
            let ratio = photo.size.height / photo.size.width
            return imageViewWidth * ratio + Layout.imageVerticalInset
        }
    }

    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        guard indexPath.row == photos.count - 1 else { return }
        imagesListService.fetchPhotosNextPage()
    }
}

// MARK: - ImagesListCellDelegate

extension ImagesListViewController: ImagesListCellDelegate {

    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }

        let photo = photos[indexPath.row]

        UIBlockingProgressHUD.show()

        imagesListService.changeLike(
            photoId: photo.id,
            isLiked: !photo.isLiked
        ) { [weak self] result in
            guard let self else { return }

            switch result {
            case .success:
                self.photos = self.imagesListService.photos

                guard self.photos.indices.contains(indexPath.row) else {
                    UIBlockingProgressHUD.dismiss()
                    return
                }

                cell.setIsLiked(self.photos[indexPath.row].isLiked)
                UIBlockingProgressHUD.dismiss()

            case .failure:
                UIBlockingProgressHUD.dismiss()

                let alert = UIAlertController(
                    title: "Ошибка",
                    message: "Что-то пошло не так",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "ОК", style: .default))
                self.present(alert, animated: true)
            }
        }
    }
}
