//
//  BoxOfficeTableViewController.swift
//  BoostCourse5
//
//  Created by Haeseok Lee on 2021/08/06.
//

import UIKit

final class BoxOfficeTableViewController: UIViewController {
    
    // MARK: - Views
    private lazy var movieTableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(
            BoxOfficeTableViewCell.self,
            forCellReuseIdentifier: Constants.Identifier.boxOfficeTableViewCell
        )
        tableView.refreshControl = refreshControl
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshMovieTableView), for: .valueChanged)
        return refreshControl
    }()
    
    private lazy var rightBarButton: UIBarButtonItem = {
        let rightBarButton = UIBarButtonItem(
            image: UIImage(named: "ic_settings"),
            style: .plain,
            target: self,
            action: #selector(touchUpRightBarButton(_:))
        )
        rightBarButton.tintColor = .white
        return rightBarButton
    }()
    
    // MARK: - Variables
    private var movieOrderType: MovieOrderType = MovieData.shared.orderType {
        willSet {
            MovieData.shared.orderType = newValue
            navigationItem.title = newValue.toKorean()
        }
    }
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupNavigationsBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if MovieData.shared.movieList.isEmpty || movieOrderType != MovieData.shared.orderType {
            fetchMovieList(orderType: MovieData.shared.orderType)
        }
        updateMovieOrderType(orderType: MovieData.shared.orderType)
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
    
    private func showNetworkActivityIndicator(isVisible: Bool) {
        if #available(iOS 13.0, *) {
            
        } else {
            UIApplication.shared.isNetworkActivityIndicatorVisible = isVisible
        }
    }

    private func pushToBoxOfficeDetailViewController(movie: Movie) {
        let boxOfficeDetailViewController = BoxOfficeDetailViewController()
        boxOfficeDetailViewController.movie = movie
        navigationController?.pushViewController(boxOfficeDetailViewController, animated: true)
    }
    
    @objc
    private func touchUpRightBarButton(_ sender: Any) {
        DispatchQueue.main.async { [weak self] in
            self?.showActionSheet(
                reservationRateAction: self?.touchUpReservationRateAction,
                curationAction: self?.touchUpCurationAction,
                openingDateAction: self?.touchUpOpeningDateAction
            )
        }
    }
    
    @objc
    private func refreshMovieTableView() {
        fetchMovieListAndUpdateMovieOrderType(orderType: movieOrderType)
    }
    
    private func touchUpReservationRateAction(_ alertAction: UIAlertAction) {
        fetchMovieListAndUpdateMovieOrderType(orderType: .reservationRate)
    }
    
    private func touchUpCurationAction(_ alertAction: UIAlertAction) {
        fetchMovieListAndUpdateMovieOrderType(orderType: .curation)
    }
    
    private func touchUpOpeningDateAction(_ alertAction: UIAlertAction) {
        fetchMovieListAndUpdateMovieOrderType(orderType: .openingDate)
    }
    
    private func fetchMovieListAndUpdateMovieOrderType(orderType: MovieOrderType) {
        fetchMovieList(orderType: orderType)
        updateMovieOrderType(orderType: orderType)
    }
    
    private func fetchMovieList(orderType: MovieOrderType = .reservationRate) {
        showNetworkActivityIndicator(isVisible: true)
        MovieRequest.shared.sendGetMovieListRequest(orderType: orderType.rawValue) {[weak self] result in
            switch result {
            case .success(let data):
                MovieData.shared.movieList = data.movies
                DispatchQueue.main.async {
                    self?.movieTableView.reloadData()
                    self?.refreshControl.endRefreshing()
                    self?.showNetworkActivityIndicator(isVisible: false)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.showAlert(title: "오류", message: "영화 정보를 가져오지 못했습니다\nError: \(error)")
                }
            }
        }
    }
    
    private func updateMovieOrderType(orderType: MovieOrderType) {
        movieOrderType = orderType
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension BoxOfficeTableViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let movie = MovieData.shared.movieList[indexPath.row]
        pushToBoxOfficeDetailViewController(movie: movie)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return BoxOfficeTableViewCell.height
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MovieData.shared.movieList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifier.boxOfficeTableViewCell, for: indexPath) as? BoxOfficeTableViewCell else {
            return UITableViewCell()
        }
        let movie = MovieData.shared.movieList[indexPath.row]
        cell.movie = movie

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            if let url = movie.thumb {
                ImageLoader(url: url).load { result in
                    switch result {
                    case .success(let image):
                        DispatchQueue.main.async {
                            cell.update(image: image)
                        }
                    case .failure(let error):
                        DispatchQueue.main.async {
                            self?.showAlert(title: "오류", message: "사진을 가져오지 못했습니다\nError: \(error)")
                        }
                    }
                }
            }
        }
        return cell
    }
}
