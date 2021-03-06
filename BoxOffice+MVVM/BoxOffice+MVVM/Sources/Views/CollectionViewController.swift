//
//  BoxOfficeCollectionViewController.swift
//  BoostCourse5
//
//  Created by Haeseok Lee on 2021/08/06.
//

import UIKit
import RxSwift

final class CollectionViewController: UIViewController {
    
    // MARK: - Views
    private lazy var movieCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.refreshControl = refreshControl
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: Constants.Identifier.collectionViewCell)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private lazy var rightBarButton: UIBarButtonItem = {
        let rightBarButton = UIBarButtonItem(image: UIImage(named: "ic_settings"), style: .plain, target: nil, action: nil)
        rightBarButton.tintColor = .white
        return rightBarButton
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        return refreshControl
    }()
    
    // MARK: - Variables
    private var collectionViewCellSize: CGSize {
        let width = (view.safeAreaLayoutGuide.layoutFrame.size.width - 20) / 2
        return CGSize(width: width, height: width * 2)
    }
    
    private var landscapeCollectionViewCellSize: CGSize {
        let width = (view.safeAreaLayoutGuide.layoutFrame.size.width - 30) / 3
        return CGSize(width: width, height: width * 2)
    }
    
    private let viewModel: MovieListViewModelType
    private var disposeBag: DisposeBag = DisposeBag()
    
    // MARK: - Life Cycle
    init(viewModel: MovieListViewModelType = MovieListViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.viewModel = MovieListViewModel()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupNavigationBar()
        setupBindings()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        movieCollectionView.reloadData()
    }
    
    // MARK: - Functions
    private func setupViews() {
        view.addSubview(movieCollectionView)
        
        NSLayoutConstraint.activate([
            movieCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            movieCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            movieCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            movieCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.barTintColor = UIColor(named: "app_purple")
        navigationItem.rightBarButtonItem = rightBarButton
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.tintColor = .white
        navigationItem.backButtonTitle = "????????????"
    }
    
    private func setupBindings() {
        
        // viewWillAppear & tableView refreshed
        let viewWillAppearOnce = rx.viewWillAppear.take(1).map { _ in () }
        let refreshed = movieCollectionView.refreshControl?.rx.controlEvent(.valueChanged).map { _ in () } ?? Observable.just(())
        Observable
            .merge(viewWillAppearOnce, refreshed)
            .bind(to: viewModel.fetchMoviesObserver)
            .disposed(by: disposeBag)
        
        // tableViewCell tapped
        movieCollectionView.rx.modelSelected(Movie.self)
            .observe(on: MainScheduler.instance)
            .bind(to: viewModel.touchMovieObserver)
            .disposed(by: disposeBag)
        
        // tableView refreshControl & NetworkActivityIndicator
        viewModel.isActivatedObservable
            .observe(on: MainScheduler.instance)
            .bind {[weak self] isActivated in
                if !isActivated {
                    self?.movieCollectionView.refreshControl?.endRefreshing()
                }
                if #available(iOS 13.0, *) {
                    
                } else {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = isActivated
                }
            }
            .disposed(by: disposeBag)
        
        // rightBarButton tapped
        rightBarButton.rx.tap
            .observe(on: MainScheduler.instance)
            .bind { [weak self] _ in
                self?.showActionSheet(actionItems: [
                    ActionItem(title: MovieOrderType.reservationRate.toKorean, handler: self?.touchUpReservationRateAction),
                    ActionItem(title: MovieOrderType.curation.toKorean, handler: self?.touchUpCurationAction),
                    ActionItem(title: MovieOrderType.openingDate.toKorean, handler: self?.touchUpOpeningDateAction)
                ])
            }
            .disposed(by: disposeBag)
        
        // navigation title
        viewModel.changedOrderTypeTextObservable
            .asDriver(onErrorJustReturn: "????????????")
            .drive(navigationItem.rx.title)
            .disposed(by: disposeBag)
        
        // collectionView
        movieCollectionView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        viewModel.moviesObservable
            .asDriver(onErrorJustReturn: [])
            .drive(movieCollectionView.rx.items(
                cellIdentifier: Constants.Identifier.collectionViewCell,
                cellType: CollectionViewCell.self)
            ) { index, item, cell in
                cell.movieObserver.onNext(item)
                cell.errorMessageObservable
                    .observe(on: MainScheduler.instance)
                    .bind {[weak self] error in
                        self?.showAlert(title: "??????", message: "????????? ???????????? ???????????????\n\(error.localizedDescription)")
                    }
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
        
        // errorMessage
        viewModel.errorMessageObservable
            .map { $0.localizedDescription }
            .observe(on: MainScheduler.instance)
            .bind(onNext: {[weak self] error in
                self?.showAlert(title: "??????", message: error)
            })
            .disposed(by: disposeBag)
        
        // navigation
        viewModel.showDetailViewController
            .bind(onNext: {[weak self] movie in
                self?.pushToDetailViewController(movie: movie)
            })
            .disposed(by: disposeBag)
    }
    
    private func pushToDetailViewController(movie: Movie) {
        let detailViewController = DetailViewController()
        detailViewController.commentListViewModel = CommentListViewModel(movie: movie)
        detailViewController.movieViewModel = MovieViewModel(selectedMovie: movie)
        navigationController?.pushViewController(detailViewController, animated: true)
    }
    
    
    private func touchUpReservationRateAction(_ action: UIAlertAction) {
        viewModel.changeOrderTypeObserver.onNext(.reservationRate)
    }
    
    private func touchUpCurationAction(_ action: UIAlertAction) {
        viewModel.changeOrderTypeObserver.onNext(.curation)
    }
    
    private func touchUpOpeningDateAction(_ action: UIAlertAction) {
        viewModel.changeOrderTypeObserver.onNext(.openingDate)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if UIDevice.current.orientation.isLandscape {
            return landscapeCollectionViewCellSize
        }
        return collectionViewCellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return .zero
    }
}
