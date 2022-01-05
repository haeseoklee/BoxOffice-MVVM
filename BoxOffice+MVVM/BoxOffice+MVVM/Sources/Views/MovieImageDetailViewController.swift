//
//  MovieImageDetailViewController.swift
//  BoostCourse5
//
//  Created by Haeseok Lee on 2021/12/17.
//

import UIKit
import RxSwift

final class MovieImageDetailViewController: UIViewController {
    
    // MARK: - Views
    private lazy var movieImageScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 4
        scrollView.isUserInteractionEnabled = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let movieImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // MARK: - Variables
    private let movie: PublishSubject<UIImage> = PublishSubject<UIImage>()
    var movieObserver: AnyObserver<UIImage> { movie.asObserver() }
    
    private let disposeBag: DisposeBag = DisposeBag()

    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
        setupViews()
        setupBindings()
    }
    
    private func initViews() {
        view.backgroundColor = .black
    }
    
    // MARK: - Functions
    private func setupViews() {
        movieImageScrollView.addSubview(movieImageView)
        view.addSubview(movieImageScrollView)
        
        NSLayoutConstraint.activate([
            movieImageScrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            movieImageScrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            movieImageScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            movieImageScrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            movieImageView.leadingAnchor.constraint(equalTo: movieImageScrollView.frameLayoutGuide.leadingAnchor),
            movieImageView.trailingAnchor.constraint(equalTo: movieImageScrollView.frameLayoutGuide.trailingAnchor),
            movieImageView.topAnchor.constraint(equalTo: movieImageScrollView.frameLayoutGuide.topAnchor),
            movieImageView.bottomAnchor.constraint(equalTo: movieImageScrollView.frameLayoutGuide.bottomAnchor),
            movieImageView.widthAnchor.constraint(equalTo: movieImageScrollView.frameLayoutGuide.widthAnchor),
            movieImageView.heightAnchor.constraint(equalTo: movieImageScrollView.frameLayoutGuide.heightAnchor)
        ])
    }
    
    private func setupBindings() {
        movie
            .asDriver(onErrorJustReturn: UIImage(named: "img_placeholder") ?? UIImage())
            .drive(movieImageView.rx.image)
            .disposed(by: disposeBag)
    }
}

// MARK: - UIScrollViewDelegate
extension MovieImageDetailViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return movieImageView
    }
}
