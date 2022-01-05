//
//  BoxOfficeTableViewController.swift
//  BoostCourse5
//
//  Created by Haeseok Lee on 2021/08/06.
//

import UIKit
import RxSwift
import RxViewController

final class BoxOfficeTableViewController: UIViewController {
    
    // MARK: - Views
    private lazy var movieTableView: UITableView = {
        let tableView = UITableView()
        tableView.refreshControl = refreshControl
        tableView.register(BoxOfficeTableViewCell.self, forCellReuseIdentifier: Constants.Identifier.boxOfficeTableViewCell)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        return refreshControl
    }()
    
    private lazy var rightBarButton: UIBarButtonItem = {
        let rightBarButton = UIBarButtonItem(image: UIImage(named: "ic_settings"), style: .plain, target: nil, action: nil)
        rightBarButton.tintColor = .white
        return rightBarButton
    }()
    
    // MARK: - Variables
    private let viewModel: MovieListViewModelType
    private var disposeBag: DisposeBag = DisposeBag()
    
    // MARK: - Life Cycles
    init() {
        viewModel = MovieListViewModel.shared
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        viewModel = MovieListViewModel.shared
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupNavigationsBar()
        setupBindings()
    }
    
    // MARK: - Functions
    private func setupViews() {
        view.addSubview(movieTableView)
        
        NSLayoutConstraint.activate([
            movieTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            movieTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            movieTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            movieTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupNavigationsBar() {
        navigationItem.rightBarButtonItem = rightBarButton
        navigationItem.backButtonTitle = "영화목록"
    }
    
    private func setupBindings() {
        
        // viewWillAppear & tableView refreshed
        let viewWillAppearOnce = rx.viewWillAppear.take(1).map { _ in () }
        let refreshed = movieTableView.refreshControl?.rx.controlEvent(.valueChanged).map { _ in () } ?? Observable.just(())
        Observable
            .merge(viewWillAppearOnce, refreshed)
            .bind(to: viewModel.fetchMoviesObserver)
            .disposed(by: disposeBag)
        
        // tableViewCell tap
        movieTableView.rx.modelSelected(Movie.self)
            .observe(on: MainScheduler.instance)
            .bind(to: viewModel.touchMovieObserver)
            .disposed(by: disposeBag)
        
        // tableView refreshControl & NetworkActivityIndicator
        viewModel.isActivatedObservable
            .observe(on: MainScheduler.instance)
            .bind {[weak self] isActivated in
                if !isActivated {
                    self?.movieTableView.refreshControl?.endRefreshing()
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
                self?.showActionSheet(
                    reservationRateAction: self?.touchUpReservationRateAction(_:),
                    curationAction: self?.touchUpCurationAction(_:),
                    openingDateAction: self?.touchUpOpeningDateAction(_:)
                )
            }
            .disposed(by: disposeBag)
        
        // navigation title
        viewModel.changedOrderTypeTextObservable
            .asDriver(onErrorJustReturn: "예매율순")
            .drive(navigationItem.rx.title)
            .disposed(by: disposeBag)
        
        // tableview
        movieTableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        viewModel.moviesObservable
            .asDriver(onErrorJustReturn: [])
            .drive(movieTableView.rx.items(
                cellIdentifier: Constants.Identifier.boxOfficeTableViewCell,
                cellType: BoxOfficeTableViewCell.self)
            ) { index, item, cell in
                cell.movieObserver.onNext(item)
                cell.errorMessageObservable
                    .observe(on: MainScheduler.instance)
                    .bind {[weak self] error in
                        self?.showAlert(title: "오류", message: "사진을 가져오지 못했습니다\n\(error.localizedDescription)")
                    }
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
        
        // errorMessage
        viewModel.errorMessageObservable
            .map { $0.localizedDescription }
            .observe(on: MainScheduler.instance)
            .bind(onNext: {[weak self] error in
                self?.showAlert(title: "오류", message: error)
            })
            .disposed(by: disposeBag)
        
        // navigation
        viewModel.showBoxOfficeDetailViewController
            .bind(onNext: {[weak self] movie in
                self?.pushToBoxOfficeDetailViewController(movie: movie)
            })
            .disposed(by: disposeBag)
    }

    private func pushToBoxOfficeDetailViewController(movie: Movie) {
        let boxOfficeDetailViewController = BoxOfficeDetailViewController()
        boxOfficeDetailViewController.commentListViewModel = CommentListViewModel(movie: movie)
        boxOfficeDetailViewController.movieViewModel = MovieViewModel(selectedMovie: movie)
        navigationController?.pushViewController(boxOfficeDetailViewController, animated: true)
    }
    
    private func touchUpReservationRateAction(_ alertAction: UIAlertAction) {
        viewModel.changeOrderTypeObserver.onNext(.reservationRate)
    }
    
    private func touchUpCurationAction(_ alertAction: UIAlertAction) {
        viewModel.changeOrderTypeObserver.onNext(.curation)
    }
    
    private func touchUpOpeningDateAction(_ alertAction: UIAlertAction) {
        viewModel.changeOrderTypeObserver.onNext(.openingDate)
    }
}

// MARK: - UITableViewDelegate
extension BoxOfficeTableViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return BoxOfficeTableViewCell.height
    }
}
