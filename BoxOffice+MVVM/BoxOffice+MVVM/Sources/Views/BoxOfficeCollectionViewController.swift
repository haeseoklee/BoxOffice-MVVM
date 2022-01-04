//
//  BoxOfficeCollectionViewController.swift
//  BoostCourse5
//
//  Created by Haeseok Lee on 2021/08/06.
//

import UIKit

final class BoxOfficeCollectionViewController: UIViewController {
    
    // MARK: - Views
    private lazy var movieCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(BoxOfficeCollectionViewCell.self, forCellWithReuseIdentifier: Constants.Identifier.boxOfficeCollectionViewCell)
        collectionView.refreshControl = refreshControl
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private lazy var rightBarButton: UIBarButtonItem = {
        let rightBarButton = UIBarButtonItem(image: UIImage(named: "ic_settings"), style: .plain, target: self, action: #selector(touchUpRightBarButton(_:)))
        rightBarButton.tintColor = .white
        return rightBarButton
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(
            self,
            action: #selector(refreshMovieCollectionView),
            for: .valueChanged
        )
        return refreshControl
    }()
    
    // MARK: - Variables
    private var movieOrderType: MovieOrderType = MovieData.shared.orderType {
        willSet {
            MovieData.shared.orderType = newValue
            navigationItem.title = newValue.toKorean()
        }
    }
    
    private var boxOfficeCollectionViewCellSize: CGSize {
        let width = (view.safeAreaLayoutGuide.layoutFrame.size.width - 20) / 2
        return CGSize(width: width, height: width * 2)
    }
    
    private var boxOfficeLandscapeCollectionViewCellSize: CGSize {
        let width = (view.safeAreaLayoutGuide.layoutFrame.size.width - 30) / 3
        return CGSize(width: width, height: width * 2)
    }
    
    // MARK: - LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if MovieData.shared.movieList.isEmpty || movieOrderType != MovieData.shared.orderType {
            fetchMovieList(orderType: MovieData.shared.orderType)
        }
        updateMovieOrderType(orderType: MovieData.shared.orderType)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        movieCollectionView.reloadData()
        movieCollectionView.layoutIfNeeded()
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
        navigationItem.backButtonTitle = "영화목록"
    }
    
    private func pushToBoxOfficeDetailViewController(movie: Movie) {
        let boxOfficeDetailViewController = BoxOfficeDetailViewController()
        boxOfficeDetailViewController.movie = movie
        navigationController?.pushViewController(boxOfficeDetailViewController, animated: true)
    }
    
    private func fetchMovieListAndUpdateMovieOrderType(orderType: MovieOrderType) {
        fetchMovieList(orderType: orderType)
        updateMovieOrderType(orderType: orderType)
    }
    
    @objc private func touchUpRightBarButton(_ sender: Any) {
        DispatchQueue.main.async { [weak self] in
            self?.showActionSheet(
                reservationRateAction: self?.touchUpReservationRateAction,
                curationAction: self?.touchUpCurationAction,
                openingDateAction: self?.touchUpOpeningDateAction
            )
        }
    }
    
    @objc private func refreshMovieCollectionView() {
        fetchMovieListAndUpdateMovieOrderType(orderType: movieOrderType)
    }
    
    private func touchUpReservationRateAction(_ action: UIAlertAction) {
        fetchMovieListAndUpdateMovieOrderType(orderType: .reservationRate)
    }
    
    private func touchUpCurationAction(_ action: UIAlertAction) {
        fetchMovieListAndUpdateMovieOrderType(orderType: .curation)
    }
    
    private func touchUpOpeningDateAction(_ action: UIAlertAction) {
        fetchMovieListAndUpdateMovieOrderType(orderType: .openingDate)
    }
    
    private func updateMovieOrderType(orderType: MovieOrderType) {
        movieOrderType = orderType
    }
    
    private func fetchMovieList(orderType: MovieOrderType = .reservationRate) {
        showNetworkActivityIndicator(isVisible: true)
        MovieRequest.shared.sendGetMovieListRequest(orderType: orderType.rawValue) {[weak self] result in
            switch result {
            case .success(let data):
                MovieData.shared.movieList = data.movies
                DispatchQueue.main.async {
                    self?.movieCollectionView.reloadData()
                    self?.refreshControl.endRefreshing()
                    self?.showNetworkActivityIndicator(isVisible: false)
                }
            case .failure(let error):
                self?.showAlert(title: "오류", message: "영화 정보를 가져오지 못했습니다\nError: \(error)")
            }
        }
    }
    
    private func showNetworkActivityIndicator(isVisible: Bool) {
        if #available(iOS 13, *) {
            
        } else {
            UIApplication.shared.isNetworkActivityIndicatorVisible = isVisible
        }
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
extension BoxOfficeCollectionViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return MovieData.shared.movieList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movie = MovieData.shared.movieList[indexPath.item]
        pushToBoxOfficeDetailViewController(movie: movie)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.Identifier.boxOfficeCollectionViewCell, for: indexPath) as? BoxOfficeCollectionViewCell else {
            return UICollectionViewCell()
        }
        let movie = MovieData.shared.movieList[indexPath.item]
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if UIDevice.current.orientation.isLandscape {
            return boxOfficeLandscapeCollectionViewCellSize
        }
        return boxOfficeCollectionViewCellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return .zero
    }
}
