//
//  BoxOfficeDetailViewController.swift
//  BoostCourse5
//
//  Created by Haeseok Lee on 2021/08/06.
//

import UIKit
import RxSwift
import RxCocoa

enum MovieDetailTableViewSection: Int, CaseIterable {
    case header, summary, info, comment
}

final class BoxOfficeDetailViewController: UIViewController {
    
    // MARK: - Views
    private lazy var movieDetailTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: UITableView.Style.grouped)
        tableView.register(BoxOfficeDetailHeaderView.self, forHeaderFooterViewReuseIdentifier: Constants.Identifier.boxOfficeDetailHeaderView)
        tableView.register(BoxOfficeDetailSummaryHeaderView.self, forHeaderFooterViewReuseIdentifier: Constants.Identifier.boxOfficeDetailSummaryHeaderView)
        tableView.register(BoxOfficeDetailInfoHeaderView.self, forHeaderFooterViewReuseIdentifier: Constants.Identifier.boxOfficeDetailInfoHeaderView)
        tableView.register(BoxOfficeDetailReviewHeaderView.self, forHeaderFooterViewReuseIdentifier: Constants.Identifier.boxOfficeDetailReviewHeaderView)
        tableView.register(BoxOfficeDetailTableViewCell.self, forCellReuseIdentifier: Constants.Identifier.boxOfficeDetailTableViewCell)
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // MARK: - Variables
    var viewModel: MovieViewModelType
    private var disposeBag: DisposeBag = DisposeBag()
    
    // MARK: - Life Cycles
    init(viewModel: MovieViewModelType = MovieViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.viewModel = MovieViewModel()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupNavigationBar()
        setupBindings()
    }
    
    // MARK: - Functions
    private func setupViews() {
        view.addSubview(movieDetailTableView)
        
        NSLayoutConstraint.activate([
            movieDetailTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            movieDetailTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            movieDetailTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            movieDetailTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.tintColor = .white
        
        viewModel.movieObservable
            .map { $0.title }
            .asDriver(onErrorJustReturn: "")
            .drive(navigationItem.rx.title)
            .disposed(by: disposeBag)
    }
    
    private func setupBindings() {
        
        // fetch movie
        let viewWillAppearOnce = rx.viewWillAppear.take(1).map { _ in () }
        viewWillAppearOnce
            .bind(to: viewModel.fetchMovieObserver)
            .disposed(by: disposeBag)
        
        // tableView
        // TODO: commentlistViewModel과 연결하기
        movieDetailTableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        movieDetailTableView.rx
            .setDataSource(self)
            .disposed(by: disposeBag)
        
        // NetworkActivityIndicator
        viewModel.isActivatedObservable
            .observe(on: MainScheduler.instance)
            .bind {[weak self] isActivated in
                if #available(iOS 13.0, *) {
                    
                } else {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = isActivated
                }
                self?.movieDetailTableView.reloadData()
            }
            .disposed(by: disposeBag)
        
        // Navigation
        viewModel.showMovieImageDetailViewController
            .subscribe(onNext: {[weak self] image in
                self?.presentMovieImageDetailViewController(image: image)
            })
            .disposed(by: disposeBag)
        
        viewModel.showBoxOfficeReviewWriteViewController
            .subscribe(onNext: {[weak self] movie in
                self?.presentBoxOfficeReviewWriteViewController(movie: movie)
            })
            .disposed(by: disposeBag)
    }

//    private func fetchCommentList(movie: Movie?) {
//        guard let movieId = movie?.id else { return }
//        showNetworkActivityIndicator(isVisible: true)
//        CommentRequest.shared.sendGetCommentListRequest(movieId: movieId) {[weak self] result in
//            switch result {
//            case .success(let data):
//                self?.commentList = data.comments
//                DispatchQueue.main.async {
//                    self?.movieDetailTableView.reloadData()
//                    self?.showNetworkActivityIndicator(isVisible: false)
//                }
//            case .failure(let error):
//                DispatchQueue.main.async {
//                    self?.showAlert(title: "오류", message: "코멘트를 가져오지 못했습니다\nError: \(error)")
//                }
//            }
//        }
//    }
    
    private func presentBoxOfficeReviewWriteViewController(movie: Movie?) {
        let boxOfficeReviewWriteViewController = BoxOfficeReviewWriteViewController()
        boxOfficeReviewWriteViewController.movie = movie
        let navigationController = UINavigationController(rootViewController: boxOfficeReviewWriteViewController)
        self.navigationController?.present(navigationController, animated: true, completion: nil)
    }
    
    private func presentMovieImageDetailViewController(image: UIImage) {
        let movieImageDetailViewController = MovieImageDetailViewController()
        movieImageDetailViewController.movieObserver.onNext(image)
        present(movieImageDetailViewController, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension BoxOfficeDetailViewController: UITableViewDelegate, UITableViewDataSource {

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return MovieDetailTableViewSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionKind = MovieDetailTableViewSection(rawValue: section)
        if sectionKind == .comment {
//            return commentList.count
            return 0
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionKind = MovieDetailTableViewSection(rawValue: indexPath.section)
        if sectionKind == .comment {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: Constants.Identifier.boxOfficeDetailTableViewCell,
                for: indexPath
            ) as? BoxOfficeDetailTableViewCell else {
                return UITableViewCell()
            }
//            cell.comment = commentList[indexPath.item]
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let defaultHeaderView = UITableViewHeaderFooterView()
        let sectionKind = MovieDetailTableViewSection(rawValue: section)
        switch sectionKind {
        case .header:
            guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: Constants.Identifier.boxOfficeDetailHeaderView) as? BoxOfficeDetailHeaderView else {
                return defaultHeaderView
            }
            viewModel.movieObservable
                .bind(to: headerView.movieObserver)
                .disposed(by: headerView.disposeBag)
            
            viewModel.fetchMovieImageObserver.onNext(())
            
            viewModel.movieImageObservable
                .bind(to: headerView.movieImageObserver)
                .disposed(by: headerView.disposeBag)
            
            headerView.touchMovieObservable
                .bind(to: viewModel.touchMovieImageObserver)
                .disposed(by: headerView.disposeBag)
            
            return headerView
        case .summary:
            guard let summaryView = tableView.dequeueReusableHeaderFooterView(withIdentifier: Constants.Identifier.boxOfficeDetailSummaryHeaderView) as? BoxOfficeDetailSummaryHeaderView else {
                return defaultHeaderView
            }
            viewModel.movieObservable
                .bind(to: summaryView.movieObserver)
                .disposed(by: summaryView.disposeBag)
            return summaryView
        case .info:
            guard let infoView = tableView.dequeueReusableHeaderFooterView(withIdentifier: Constants.Identifier.boxOfficeDetailInfoHeaderView) as? BoxOfficeDetailInfoHeaderView else {
                return defaultHeaderView
            }
            viewModel.movieObservable
                .bind(to: infoView.movieObserver)
                .disposed(by: infoView.disposeBag)
            return infoView
        case .comment:
            guard let reviewView = tableView.dequeueReusableHeaderFooterView(withIdentifier: Constants.Identifier.boxOfficeDetailReviewHeaderView) as? BoxOfficeDetailReviewHeaderView else {
                return defaultHeaderView
            }
            reviewView.touchReviewWriteButtonObservable
                .bind(to: viewModel.touchReviewWriteButtonObserver)
                .disposed(by: reviewView.disposeBag)
            return reviewView
        default:
            return defaultHeaderView
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        let sectionKind = MovieDetailTableViewSection(rawValue: section)
        switch sectionKind {
        case .header:
            return 350
        case .summary:
            return 350
        case .info:
            return 150
        case .comment:
            return 50
        default:
            return 50
        }
    }
}
