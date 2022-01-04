//
//  MovieListViewModel.swift
//  BoxOffice+MVVM
//
//  Created by Haeseok Lee on 2022/01/04.
//

import Foundation
import RxSwift
import RxCocoa

protocol MovieListViewModelType {
    
    // Input
    var fetchMoviesObserver: AnyObserver<Void> { get }
    var changeOrderTypeObserver: AnyObserver<MovieOrderType> { get }
    var touchMovieObserver: AnyObserver<Movie> { get }
    
    // Output
    var isActivatedObservable: Observable<Bool> { get }
    var moviesObservable: Observable<[Movie]> { get }
    var errorMessageObservable: Observable<NSError> { get }
    
    // Navigation
    var showBoxOfficeDetailViewController: Observable<Movie> { get }
}

class MovieListViewModel: MovieListViewModelType {
    
    private let disposeBag: DisposeBag = DisposeBag()
    
    // Input
    let fetchMoviesObserver: AnyObserver<Void>
    let changeOrderTypeObserver: AnyObserver<MovieOrderType>
    let touchMovieObserver: AnyObserver<Movie>
    
    // Output
    let isActivatedObservable: Observable<Bool>
    let changedOrderTypeObservable: Observable<MovieOrderType>
    let moviesObservable: Observable<[Movie]>
    let errorMessageObservable: Observable<NSError>
    
    // Navigation
    let showBoxOfficeDetailViewController: Observable<Movie>
    
    init(domain: BoxOfficeType = BoxOffice()) {
        let fetchMovies = PublishSubject<Void>()
        let changeOrderType = BehaviorSubject<MovieOrderType>(value: .reservationRate)
        let touchMovie = PublishSubject<Movie>()
        
        let isActivated = BehaviorSubject<Bool>(value: false)
        let movies = BehaviorSubject<[Movie]>(value: [])
        let errorMessage = PublishSubject<NSError>()
        
        // Input
        fetchMoviesObserver = fetchMovies.asObserver()
        changeOrderTypeObserver = changeOrderType.asObserver()
        touchMovieObserver = touchMovie.asObserver()
        
        fetchMovies
            .withLatestFrom(changeOrderType)
            .map { orderType -> MovieOrderType in
                isActivated.onNext(true)
                return orderType
            }
            .flatMap { orderType in
                domain.getMovieList(orderType: orderType.rawValue)
            }
            .subscribe(onNext: { movieList in
                changeOrderType.onNext(MovieOrderType(rawValue: movieList.orderType) ?? .reservationRate)
                movies.onNext(movieList.movies)
                isActivated.onNext(false)
            }, onError: { error in
                errorMessage.onError(error)
            })
            .disposed(by: disposeBag)
        
        // Output
        isActivatedObservable = isActivated
            .distinctUntilChanged()
            .asObservable()
        
        changedOrderTypeObservable = changeOrderType.asObservable()
                
        moviesObservable = movies.asObservable()
        
        errorMessageObservable = errorMessage
            .map { $0 as NSError }
            .asObservable()
        
        // Navigation
        showBoxOfficeDetailViewController = touchMovie
            .asObservable()
    }
}