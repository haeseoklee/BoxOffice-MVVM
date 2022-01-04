//
//  BoxOfficeDetailViewController.swift
//  BoostCourse5
//
//  Created by Haeseok Lee on 2021/08/06.
//

import UIKit

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
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // MARK: - Variables
    var movie: Movie?
    private var commentList: [Comment] = []
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupNavigationBar()
        setupNotification()
        fetchMovie(movie: movie)
        fetchCommentList(movie: movie)
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
        navigationItem.title = movie?.title
    }
    
    private func setupNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateCommentList), name: .init("PostCommentFinished"), object: nil)
    }
    
    @objc private func updateCommentList() {
        fetchCommentList(movie: movie)
    }
    
    private func fetchMovie(movie: Movie?) {
        guard let movieId = movie?.id else { return }
        showNetworkActivityIndicator(isVisible: true)
        MovieRequest.shared.sendGetMovieRequest(id: movieId) {[weak self] result in
            switch result {
            case .success(let data):
                self?.movie = data
                DispatchQueue.main.async {
                    self?.movieDetailTableView.reloadData()
                    self?.showNetworkActivityIndicator(isVisible: false)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.showAlert(title: "오류", message: "영화 정보를 가져오지 못했습니다\nError: \(error)")
                }
            }
        }
    }
    
    private func fetchCommentList(movie: Movie?) {
        guard let movieId = movie?.id else { return }
        showNetworkActivityIndicator(isVisible: true)
        CommentRequest.shared.sendGetCommentListRequest(movieId: movieId) {[weak self] result in
            switch result {
            case .success(let data):
                self?.commentList = data.comments
                DispatchQueue.main.async {
                    self?.movieDetailTableView.reloadData()
                    self?.showNetworkActivityIndicator(isVisible: false)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.showAlert(title: "오류", message: "코멘트를 가져오지 못했습니다\nError: \(error)")
                }
            }
        }
    }
    
    private func showNetworkActivityIndicator(isVisible: Bool) {
        if #available(iOS 13, *) {
            
        } else {
            UIApplication.shared.isNetworkActivityIndicatorVisible = isVisible
        }
    }
    
    private func presentBoxOfficeReviewWriteViewController(movie: Movie?) {
        let boxOfficeReviewWriteViewController = BoxOfficeReviewWriteViewController()
        boxOfficeReviewWriteViewController.movie = movie
        let navigationController = UINavigationController(rootViewController: boxOfficeReviewWriteViewController)
        self.navigationController?.present(navigationController, animated: true, completion: nil)
    }
    
    private func presentMovieImageDetailViewController(image: UIImage) {
        let movieImageDetailViewController = MovieImageDetailViewController()
        movieImageDetailViewController.movieImage = image
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
            return commentList.count
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
            cell.comment = commentList[indexPath.item]
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
            headerView.boxOfficeHeaderDelegate = self
            headerView.movie = movie
            if let url = movie?.image {
                ImageLoader(url: url).load {[weak self] result in
                    switch result {
                    case .success(let image):
                        DispatchQueue.main.async {
                            headerView.image = image
                        }
                    case .failure(let error):
                        DispatchQueue.main.async {
                            self?.showAlert(title: "오류", message: "사진을 가져오지 못했습니다\nError: \(error)")
                        }
                    }
                }
            }
            return headerView
        case .summary:
            guard let summaryView = tableView.dequeueReusableHeaderFooterView(withIdentifier: Constants.Identifier.boxOfficeDetailSummaryHeaderView) as? BoxOfficeDetailSummaryHeaderView else {
                return defaultHeaderView
            }
            summaryView.movie = movie
            return summaryView
        case .info:
            guard let infoView = tableView.dequeueReusableHeaderFooterView(withIdentifier: Constants.Identifier.boxOfficeDetailInfoHeaderView) as? BoxOfficeDetailInfoHeaderView else {
                return defaultHeaderView
            }
            infoView.movie = movie
            return infoView
        case .comment:
            guard let reviewView = tableView.dequeueReusableHeaderFooterView(withIdentifier: Constants.Identifier.boxOfficeDetailReviewHeaderView) as? BoxOfficeDetailReviewHeaderView else {
                return defaultHeaderView
            }
            reviewView.boxOfficeDetailReviewHeaderDelegate = self
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

// MARK: - ReviewCollectionReusableViewDelegate
extension BoxOfficeDetailViewController: BoxOfficeDetailReviewHeaderDelegate {
    func touchReviewWriteButton() {
        presentBoxOfficeReviewWriteViewController(movie: movie)
    }
}

// MARK: - BoxOfficeHeaderDelegate
extension BoxOfficeDetailViewController: BoxOfficeHeaderDelegate {
    func touchUpMovieImageView(image: UIImage?) {
        if let image = image {
            presentMovieImageDetailViewController(image: image)
        }
    }
}
