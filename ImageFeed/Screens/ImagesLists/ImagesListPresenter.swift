import Foundation

// MARK: - ImagesListViewControllerProtocol

protocol ImagesListViewControllerProtocol: AnyObject {
    func updateTableViewAnimated(oldCount: Int, newCount: Int)
    func reloadTableView()
    func showLikeError()
}

// MARK: - ImagesListPresenterProtocol

protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }
    var photos: [Photo] { get }
    func viewDidLoad()
    func fetchNextPage()
    func changeLike(photoId: String, isLiked: Bool, completion: @escaping (Result<Void, Error>) -> Void)
}

// MARK: - ImagesListServiceProtocol

protocol ImagesListServiceProtocol: AnyObject {
    var photos: [Photo] { get }
    var didChangeNotification: Notification.Name { get }
    func fetchPhotosNextPage()
    func changeLike(photoId: String, isLiked: Bool, completion: @escaping (Result<Void, Error>) -> Void)
}

// MARK: - ImagesListPresenter

final class ImagesListPresenter: ImagesListPresenterProtocol {

    // MARK: - Properties

    weak var view: ImagesListViewControllerProtocol?

    private(set) var photos: [Photo] = []

    private let imagesListService: ImagesListServiceProtocol
    private var imagesListObserver: NSObjectProtocol?

    // MARK: - Init

    init(imagesListService: ImagesListServiceProtocol = ImagesListService.shared) {
        self.imagesListService = imagesListService
    }

    // MARK: - ImagesListPresenterProtocol

    func viewDidLoad() {
        imagesListObserver = NotificationCenter.default.addObserver(
            forName: imagesListService.didChangeNotification,
            object: imagesListService,
            queue: .main
        ) { [weak self] _ in
            self?.handlePhotosUpdate()
        }

        imagesListService.fetchPhotosNextPage()
    }

    func fetchNextPage() {
        imagesListService.fetchPhotosNextPage()
    }

    func changeLike(
        photoId: String,
        isLiked: Bool,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        imagesListService.changeLike(photoId: photoId, isLiked: isLiked) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                self.photos = self.imagesListService.photos
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - Private

    private func handlePhotosUpdate() {
        let newPhotos = imagesListService.photos
        guard !newPhotos.isEmpty else { return }

        let oldCount = photos.count
        let newCount = newPhotos.count
        photos = newPhotos

        if oldCount == 0 {
            view?.reloadTableView()
        } else if oldCount < newCount {
            view?.updateTableViewAnimated(oldCount: oldCount, newCount: newCount)
        }
    }

    deinit {
        if let imagesListObserver {
            NotificationCenter.default.removeObserver(imagesListObserver)
        }
    }
}

// MARK: - ImagesListServiceProtocol

extension ImagesListService: ImagesListServiceProtocol {
    var didChangeNotification: Notification.Name {
        Self.didChangeNotification
    }
}
