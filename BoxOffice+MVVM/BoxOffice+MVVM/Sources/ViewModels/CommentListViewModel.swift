//
//  CommentListViewModel.swift
//  BoxOffice+MVVM
//
//  Created by Haeseok Lee on 2022/01/05.
//

import Foundation
import RxSwift

protocol CommentListViewModelType {
    
    // Input
    var fetchCommentsObserver: AnyObserver<Void> { get }
    
    // Output
    var isActivatedObservable: Observable<Bool> { get }
    var commentsObservable: Observable<[Comment]> { get }
    var errorMessageObservable: Observable<NSError> { get }
}

class CommentListViewModel: CommentListViewModelType {
    
    private let disposeBag: DisposeBag = DisposeBag()
    
    // Input
    let fetchCommentsObserver: AnyObserver<Void>
    
    // Output
    let isActivatedObservable: Observable<Bool>
    let commentsObservable: Observable<[Comment]>
    let errorMessageObservable: Observable<NSError>
    
    init(movie: Movie = Movie.empty, domain: BoxOfficeType = BoxOffice()) {
        
        let movie = BehaviorSubject<Movie>(value: movie)
        let fetchComments = PublishSubject<Void>()
        let isActivated = PublishSubject<Bool>()
        let comments = BehaviorSubject<[Comment]>(value: [])
        let errorMessage = PublishSubject<NSError>()
        
        // Input
        fetchCommentsObserver = fetchComments.asObserver()
        
        fetchComments
            .withLatestFrom(movie)
            .map { movie in
                isActivated.onNext(true)
                return movie.id
            }
            .flatMap { domain.getCommentList(movieId: $0) }
            .subscribe(onNext: { commentList in
                isActivated.onNext(false)
                comments.onNext(commentList.comments)
            }, onError: { error in
                errorMessage.onNext(error as NSError)
            })
            .disposed(by: disposeBag)
        
        // Output
        isActivatedObservable = isActivated
            .asObservable()
        
        commentsObservable = comments
            .asObservable()
        
        errorMessageObservable = errorMessage
            .map { $0 as NSError }
            .asObservable()
    }
}
