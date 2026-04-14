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

//private enum FeedState {
//    case loading
//    case loaded
//}

final class ImagesListViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet private var tableView: UITableView!

    // MARK: - Private properties
    private var presenter: ImagesListPresenterProtocol?

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    // MARK: - Configure

    func configure(_ presenter: ImagesListPresenterProtocol) {
        self.presenter = presenter
        presenter.view = self
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.contentInset = UIEdgeInsets(
            top: Layout.tableVerticalInset,
            left: 0,
            bottom: Layout.tableVerticalInset,
            right: 0
        )

        presenter?.viewDidLoad()
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "ShowSingleImage",
              let viewController = segue.destination as? SingleImageViewController,
              let indexPath = tableView.indexPathForSelectedRow,
              let photos = presenter?.photos,
              photos.indices.contains(indexPath.row) else { return }

        let photo = photos[indexPath.row]
        viewController.imageURL = URL(string: photo.largeImageURL)
    }

    // MARK: - Private methods

    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard let photos = presenter?.photos,
              photos.indices.contains(indexPath.row) else { return }

        let photo = photos[indexPath.row]
        cell.delegate = self
        cell.setImage(url: URL(string: photo.thumbImageURL), placeholder: nil)
        cell.dateLabel.text = photo.createdAt.map { dateFormatter.string(from: $0) }
        cell.setIsLiked(photo.isLiked)
    }
}

// MARK: - ImagesListViewControllerProtocol

extension ImagesListViewController: ImagesListViewControllerProtocol {

    // Презентер говорит "перезагрузи таблицу целиком" (первая загрузка)
    func reloadTableView() {
        tableView.reloadData()
    }

    // Презентер говорит "анимированно добавь новые строки"
    func updateTableViewAnimated(oldCount: Int, newCount: Int) {
        let indexPaths = (oldCount ..< newCount).map { IndexPath(row: $0, section: 0) }
        tableView.performBatchUpdates {
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }

    func showLikeError() {
        let alert = UIAlertController(
            title: "Ошибка",
            message: "Что-то пошло не так",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "ОК", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension ImagesListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Пока фото не загружены — показываем 10 заглушек с анимацией
        return presenter?.photos.count ?? 10
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
        guard let photos = presenter?.photos,
              photos.indices.contains(indexPath.row) else {
            return Layout.defaultHeight
        }
        let photo = photos[indexPath.row]
        guard photo.size.width > 0 else { return Layout.defaultHeight }
        let tableWidth = tableView.bounds.width
        let imageViewWidth = tableWidth - Layout.horizontalInset * 2
        let ratio = photo.size.height / photo.size.width
        return imageViewWidth * ratio + Layout.imageVerticalInset
    }

    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        guard let photosCount = presenter?.photos.count,
              indexPath.row == photosCount - 1 else { return }
        presenter?.fetchNextPage()
    }
}

// MARK: - ImagesListCellDelegate

extension ImagesListViewController: ImagesListCellDelegate {

    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell),
              let photos = presenter?.photos,
              photos.indices.contains(indexPath.row) else { return }

        let photo = photos[indexPath.row]
        UIBlockingProgressHUD.show()

        presenter?.changeLike(photoId: photo.id, isLiked: !photo.isLiked) { [weak self] result in
            guard let self else { return }
            UIBlockingProgressHUD.dismiss()

            switch result {
            case .success:
                guard let updatedPhotos = self.presenter?.photos,
                      updatedPhotos.indices.contains(indexPath.row) else { return }
                cell.setIsLiked(updatedPhotos[indexPath.row].isLiked)
            case .failure:
                self.showLikeError()
            }
        }
    }
}
