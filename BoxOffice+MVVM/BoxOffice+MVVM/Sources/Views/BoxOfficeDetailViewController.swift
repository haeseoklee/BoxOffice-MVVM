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
    var movieViewModel: MovieViewModelType
    var commentListViewModel: CommentListViewModelType
    private var comments: [Comment] = []
    private var disposeBag: DisposeBag = DisposeBag()
    
    // MARK: - Life Cycles
    init(movieViewModel: MovieViewModelType = MovieViewModel(),
         commentListViewModel: CommentListViewModelType = CommentListViewModel()) {
        self.movieViewModel = movieViewModel
        self.commentListViewModel = commentListViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        movieViewModel = MovieViewModel()
        commentListViewModel = CommentListViewModel()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupNavigationBar()
        setupBindings()
        setupNotification()
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
        
        movieViewModel.movieObservable
            .map { $0.title }
            .asDriver(onErrorJustReturn: "")
            .drive(navigationItem.rx.title)
            .disposed(by: disposeBag)
    }
    
    private func setupBindings() {
        
        // Fetch movie
        let viewWillAppearOnce = rx.viewWillAppear.take(1).map { _ in () }
        viewWillAppearOnce
            .bind(to: movieViewModel.fetchMovieObserver)
            .disposed(by: disposeBag)
        
        // Fetch comment list
        viewWillAppearOnce
            .bind{ [weak self] _ in
                self?.commentListViewModel.fetchCommentsObserver.onNext(())
            }
            .disposed(by: disposeBag)
        
        // TableView
        movieDetailTableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        movieDetailTableView.rx
            .setDataSource(self)
            .disposed(by: disposeBag)
        
        commentListViewModel
            .commentsObservable
            .bind {[weak self] comments in
                self?.comments = comments
            }
            .disposed(by: disposeBag)
        
        // NetworkActivityIndicator
        Observable
            .merge(movieViewModel.isActivatedObservable, commentListViewModel.isActivatedObservable)
            .observe(on: MainScheduler.instance)
            .bind {[weak self] isActivated in
                if #available(iOS 13.0, *) {
                } else {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = isActivated
                }
                self?.movieDetailTableView.reloadData()
            }
            .disposed(by: disposeBag)
        
        // Error message
        Observable
            .merge(movieViewModel.errorMessageObservable, commentListViewModel.errorMessageObservable)
            .map { $0.localizedDescription }
            .observe(on: MainScheduler.instance)
            .bind { [weak self] message in
                self?.showAlert(title: "오류", message: message)
            }
            .disposed(by: disposeBag)
        
        // Navigation
        movieViewModel.showMovieImageDetailViewController
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: {[weak self] image in
                self?.presentMovieImageDetailViewController(image: image)
            })
            .disposed(by: disposeBag)
        
        movieViewModel.showBoxOfficeReviewWriteViewController
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: {[weak self] movie in
                self?.presentBoxOfficeReviewWriteViewController(movie: movie)
            })
            .disposed(by: disposeBag)
    }
    
    private func setupNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateCommentList), name: .init("PostCommentFinished"), object: nil)
    }
    
    @objc
    private func updateCommentList() {
        commentListViewModel.fetchCommentsObserver.onNext(())
    }
    
    private func presentBoxOfficeReviewWriteViewController(movie: Movie) {
        let boxOfficeReviewWriteViewController = BoxOfficeReviewWriteViewController(viewModel: CommentViewModel(selectedMovie: movie))
        let reviewWriteNavigationController = UINavigationController(rootViewController: boxOfficeReviewWriteViewController)
        present(reviewWriteNavigationController, animated: true, completion: nil)
    }
    
    private func presentMovieImageDetailViewController(image: UIImage) {
        let movieImageDetailViewController = MovieImageDetailViewController()
        movieImageDetailViewController.image = image
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
            return comments.count
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
            let item = comments[indexPath.row]
            cell.commentObserver.onNext(item)
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
            movieViewModel.fetchMovieImageObserver.onNext(())
            
            movieViewModel.movieObservable
                .bind(to: headerView.movieObserver)
                .disposed(by: headerView.disposeBag)
            
            movieViewModel.movieImageObservable
                .bind(to: headerView.movieImageObserver)
                .disposed(by: headerView.disposeBag)
            
            headerView.touchMovieObservable
                .bind(to: movieViewModel.touchMovieImageObserver)
                .disposed(by: headerView.disposeBag)
            
            return headerView
        case .summary:
            guard let summaryView = tableView.dequeueReusableHeaderFooterView(withIdentifier: Constants.Identifier.boxOfficeDetailSummaryHeaderView) as? BoxOfficeDetailSummaryHeaderView else {
                return defaultHeaderView
            }
            movieViewModel.movieObservable
                .bind(to: summaryView.movieObserver)
                .disposed(by: summaryView.disposeBag)
            return summaryView
        case .info:
            guard let infoView = tableView.dequeueReusableHeaderFooterView(withIdentifier: Constants.Identifier.boxOfficeDetailInfoHeaderView) as? BoxOfficeDetailInfoHeaderView else {
                return defaultHeaderView
            }
            movieViewModel.movieObservable
                .bind(to: infoView.movieObserver)
                .disposed(by: infoView.disposeBag)
            return infoView
        case .comment:
            guard let reviewView = tableView.dequeueReusableHeaderFooterView(withIdentifier: Constants.Identifier.boxOfficeDetailReviewHeaderView) as? BoxOfficeDetailReviewHeaderView else {
                return defaultHeaderView
            }
            reviewView.touchReviewWriteButtonObservable
                .bind(to: movieViewModel.touchReviewWriteButtonObserver)
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
