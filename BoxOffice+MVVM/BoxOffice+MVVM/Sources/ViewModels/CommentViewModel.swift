//
//  CommentViewModel.swift
//  BoxOffice+MVVM
//
//  Created by Haeseok Lee on 2022/01/06.
//

import Foundation
import RxSwift
import RxCocoa

protocol CommentViewModelType {
    
    // Input
    var touchCancelButtonObserver: AnyObserver<Void> { get }
    var touchCompleteButtonObserver: AnyObserver<Void> { get }
    var userRatingObserver: AnyObserver<Double> { get }
    var userNickNameObserver: AnyObserver<String> { get }
    var userCommentObserver: AnyObserver<String> { get }
    
    // Output
    var movieTitleTextObservable: Observable<String> { get }
    var movieGradeImageObservable: Observable<UIImage> { get }
    var errorMessageObservable: Observable<NSError> { get }
    
    // Navigation
    var showDetailViewController: Observable<Void> { get }
}

class CommentViewModel: CommentViewModelType {
    
    private let disposeBag: DisposeBag = DisposeBag()
    
    // Input
    let touchCancelButtonObserver: AnyObserver<Void>
    let touchCompleteButtonObserver: AnyObserver<Void>
    let userRatingObserver: AnyObserver<Double>
    let userNickNameObserver: AnyObserver<String>
    let userCommentObserver: AnyObserver<String>
    
    // Output
    let movieTitleTextObservable: Observable<String>
    let movieGradeImageObservable: Observable<UIImage>
    let errorMessageObservable: Observable<NSError>
    
    // Navigation
    let showDetailViewController: Observable<Void>
    
    init(selectedMovie: Movie = Movie.empty, domain: BoxOfficeType = BoxOffice()) {
        
        let touchCancelButton = PublishSubject<Void>()
        let touchCompleteButton = PublishSubject<Void>()
        let userRating = BehaviorSubject<Double>(value: 10)
        let userNickName = BehaviorSubject<String>(value: UserData.shared.nickname ?? "" )
        let userComment = BehaviorSubject<String>(value: "")
        let movie = BehaviorSubject<Movie>(value: selectedMovie)
        let errorMessage = PublishSubject<NSError>()
        
        // Input
        touchCancelButtonObserver = touchCancelButton.asObserver()
        touchCompleteButtonObserver = touchCompleteButton.asObserver()
        userRatingObserver = userRating.asObserver()
        userNickNameObserver = userNickName.asObserver()
        userCommentObserver = userComment.asObserver()
        
        touchCompleteButton
            .withLatestFrom(Observable.combineLatest(userRating, userNickName, userComment, movie))
            .filter {rating, nickName, comment, movie in
                if rating == 0 {
                    errorMessage.onNext(NSError(domain: "????????? ?????? ??????", code: 700, userInfo: [NSLocalizedDescriptionKey: "???????????? ?????? ???????????????"]))
                } else if nickName.isEmpty {
                    errorMessage.onNext(NSError(domain: "????????? ?????? ??????", code: 701, userInfo: [NSLocalizedDescriptionKey: "???????????? ?????? ??????????????????"]))
                } else if comment.isEmpty || comment == "???????????? ??????????????????" {
                    errorMessage.onNext(NSError(domain: "????????? ?????? ??????", code: 702, userInfo: [NSLocalizedDescriptionKey: "???????????? ?????? ??????????????????"]))
                }
                return rating != 0 && !nickName.isEmpty && !comment.isEmpty && comment != "???????????? ??????????????????"
            }
            .map { rating, nickName, comment, movie in
                Comment(id: nil, rating: rating, timestamp: nil, writer: nickName, movieId: movie.id, contents: comment)
            }
            .flatMap {
                domain.postComment(comment: $0)
            }
            .subscribe(onNext: { _ in
                touchCancelButton.onNext(())
            }, onError: { error in
                errorMessage.onNext(error as NSError)
            })
            .disposed(by: disposeBag)
        
        // Output
        movieTitleTextObservable = movie
            .map { $0.title }
            .asObservable()
        
        movieGradeImageObservable = movie
            .map { $0.gradeImageName }
            .map { UIImage(named: $0) ?? UIImage() }
            .asObservable()
        
        errorMessageObservable = errorMessage
            .map { $0 as NSError }
            .asObservable()
        
        showDetailViewController = touchCancelButton
            .asObservable()
    }
}
