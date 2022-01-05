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
    var touchMovieImageObserver: AnyObserver<Void> { get }
    var touchReviewWriteButtonObserver: AnyObserver<Void> { get }
    
    // Output
    var movieImageObservable: Observable<UIImage> { get }
    var movieTitleTextObservable: Observable<String> { get }
    var movieGradeImageObservable: Observable<UIImage> { get }
    var movieOpeningDateTextObservable: Observable<String> { get }
    var movieGenreDurationTextObservable: Observable<String> { get }
    var movieReservationTextObservable: Observable<String> { get }
    var movieRateTextObservable: Observable<String> { get }
    var movieAttendenceTextObservable: Observable<String> { get }
    var movieSynopsisTextObservable: Observable<String> { get }
    var movieDirectorTextObservable: Observable<String> { get }
    var movieActorTextObservable: Observable<String> { get }
    var errorMessageObservable: Observable<NSError> { get }
    
    // Navigation
    var showMovieImageDetailViewController: Observable<UIImage> { get }
    var showBoxOfficeReviewWriteViewController: Observable<Void> { get }
    
}

class MovieViewModel: MovieViewModelType {
    
    private var disposeBag: DisposeBag = DisposeBag()
    
    // Input
    let touchMovieImageObserver: AnyObserver<Void>
    let touchReviewWriteButtonObserver: AnyObserver<Void>
    
    // Output
    let movieImageObservable: Observable<UIImage>
    let movieTitleTextObservable: Observable<String>
    let movieGradeImageObservable: Observable<UIImage>
    let movieOpeningDateTextObservable: Observable<String>
    let movieGenreDurationTextObservable: Observable<String>
    let movieReservationTextObservable: Observable<String>
    let movieRateTextObservable: Observable<String>
    let movieAttendenceTextObservable: Observable<String>
    let movieSynopsisTextObservable: Observable<String>
    let movieDirectorTextObservable: Observable<String>
    let movieActorTextObservable: Observable<String>
    let errorMessageObservable: Observable<NSError>
    
    // Navigation
    let showMovieImageDetailViewController: Observable<UIImage>
    let showBoxOfficeReviewWriteViewController: Observable<Void>
    
    init(selectedMovie: Movie) {
        
        let touchMovieImage = PublishSubject<Void>()
        let touchReviewWriteButton = PublishSubject<Void>()
        let movie = BehaviorSubject<Movie>(value: selectedMovie)
        let errorMessage = PublishSubject<NSError>()
        
        // Input
        touchMovieImageObserver = touchMovieImage.asObserver()
        touchReviewWriteButtonObserver = touchReviewWriteButton.asObserver()
        
        // Output
        movieImageObservable = movie
            .map { $0.image }
            .flatMap { Observable.from(optional: $0) }
            .flatMap { ImageLoader(url: $0).loadRx() }
            .asObservable()
        
        movieTitleTextObservable = movie
            .map { $0.title }
            .asObservable()
        
        movieGradeImageObservable = movie
            .map { UIImage(named: $0.gradeImageName) }
            .flatMap { Observable.from(optional: $0) }
            .asObservable()
            
        movieOpeningDateTextObservable = movie
            .map { "\($0.date) 개봉" }
            .asObservable()
        
        movieGenreDurationTextObservable = movie
            .map { "\($0.genre ?? "")/\($0.duration ?? 0)분" }
            .asObservable()
        
        movieReservationTextObservable = movie
            .map { "\($0.reservationGrade)위 \($0.reservationRate)%" }
            .asObservable()
        
        movieRateTextObservable = movie
            .map { "\($0.userRating)" }
            .asObservable()
        
        movieAttendenceTextObservable = movie
            .map { $0.audience?.intWithCommas() }
            .flatMap { Observable.from(optional: $0) }
            .asObservable()
        
        movieSynopsisTextObservable = movie
            .map { $0.synopsis }
            .flatMap { Observable.from(optional: $0) }
            .asObservable()
        
        movieDirectorTextObservable = movie
            .map { $0.director }
            .flatMap { Observable.from(optional: $0) }
            .asObservable()
        
        movieActorTextObservable = movie
            .map { $0.actor }
            .flatMap { Observable.from(optional: $0) }
            .asObservable()
        
        errorMessageObservable = errorMessage
            .map { $0 as NSError }
            .asObservable()
        
        showMovieImageDetailViewController = touchMovieImage
            .withLatestFrom(movieImageObservable)
            .asObservable()
        
        showBoxOfficeReviewWriteViewController = touchReviewWriteButton
            .asObservable()
    }
}
