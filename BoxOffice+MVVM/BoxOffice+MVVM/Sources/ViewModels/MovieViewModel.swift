//
//  MovieViewModel.swift
//  BoxOffice+MVVM
//
//  Created by Haeseok Lee on 2022/01/05.
//

import Foundation
import RxSwift

protocol MovieViewModelType {
    
    // Input
    var fetchMovieObserver: AnyObserver<Void> { get }
    var fetchMovieImageObserver: AnyObserver<Void> { get }
    var touchMovieImageObserver: AnyObserver<Void> { get }
    var touchReviewWriteButtonObserver: AnyObserver<Void> { get }
    
    // Output
    var isActivatedObservable: Observable<Bool> { get }
    var movieObservable: Observable<Movie> { get }
    var movieImageObservable: Observable<UIImage> { get }
    var errorMessageObservable: Observable<NSError> { get }
    
    // Navigation
    var showMovieImageDetailViewController: Observable<UIImage> { get }
    var showBoxOfficeReviewWriteViewController: Observable<Movie> { get }
}

class MovieViewModel: MovieViewModelType {
    
    private let disposeBag: DisposeBag = DisposeBag()
    
    // Input
    let fetchMovieObserver: AnyObserver<Void>
    let fetchMovieImageObserver: AnyObserver<Void>
    let touchMovieImageObserver: AnyObserver<Void>
    let touchReviewWriteButtonObserver: AnyObserver<Void>
    
    // Output
    let isActivatedObservable: Observable<Bool>
    let movieObservable: Observable<Movie>
    let movieImageObservable: Observable<UIImage>
    let errorMessageObservable: Observable<NSError>
    
    // Navigation
    let showMovieImageDetailViewController: Observable<UIImage>
    let showBoxOfficeReviewWriteViewController: Observable<Movie>
    
    init(selectedMovie: Movie = Movie.empty, domain: BoxOfficeType = BoxOffice()) {
        
        let fetchMovie = PublishSubject<Void>()
        let fetchMovieImage = PublishSubject<Void>()
        let touchMovieImage = PublishSubject<Void>()
        let touchReviewWriteButton = PublishSubject<Void>()
        
        let isActivated = BehaviorSubject<Bool>(value: false)
        let movie = BehaviorSubject<Movie>(value: selectedMovie)
        let movieImage = BehaviorSubject<UIImage>(value: UIImage(named: "img_placeholder") ?? UIImage())
        let errorMessage = PublishSubject<NSError>()
        
        // Input
        fetchMovieObserver = fetchMovie.asObserver()
        fetchMovieImageObserver = fetchMovieImage.asObserver()
        touchMovieImageObserver = touchMovieImage.asObserver()
        touchReviewWriteButtonObserver = touchReviewWriteButton.asObserver()
        
        fetchMovie
            .withLatestFrom(movie)
            .flatMap { Observable.from(optional: $0.id) }
            .flatMap { id -> Observable<Movie> in
                isActivated.onNext(true)
                return domain.getMovie(id: id)
            }
            .subscribe(onNext: { fetchedMovie in
                movie.onNext(fetchedMovie)
                isActivated.onNext(false)
            }, onError: { error in
                errorMessage.onNext(error as NSError)
            })
            .disposed(by: disposeBag)
        
        
        fetchMovieImage
            .withLatestFrom(movie)
            .distinctUntilChanged({ $0.image ?? "" })
            .flatMap { movie -> Observable<String> in
                isActivated.onNext(true)
                return Observable.from(optional: movie.image)
            }
            .flatMap {
                ImageLoader(url: $0).loadRx()
            }
            .subscribe(onNext: { image in
                isActivated.onNext(false)
                movieImage.onNext(image)
            }, onError: { error in
                errorMessage.onNext(error as NSError)
            })
            .disposed(by: disposeBag)
        
        
        // Output
        isActivatedObservable = isActivated
            .asObservable()
        
        movieObservable = movie
            .asObservable()
        
        movieImageObservable = movieImage
            .asObservable()
        
        errorMessageObservable = errorMessage
            .map { $0 as NSError }
            .asObservable()
        
        // Navigation
        showMovieImageDetailViewController = touchMovieImage
            .withLatestFrom(movieImage)
            .asObservable()
        
        showBoxOfficeReviewWriteViewController = touchReviewWriteButton
            .throttle(.seconds(1), latest: false, scheduler: MainScheduler.instance)
            .withLatestFrom(movie)
            .asObservable()
    }
}
