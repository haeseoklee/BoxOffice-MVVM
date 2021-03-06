//
//  BoxOffice.swift
//  BoxOffice+MVVM
//
//  Created by Haeseok Lee on 2022/01/04.
//

import Foundation
import RxSwift

protocol BoxOfficeType {
    func getMovieList(orderType: Int) -> Observable<MovieList>
    func getMovie(id: String) -> Observable<Movie>
    func getCommentList(movieId: String) -> Observable<CommentList>
    func postComment(comment: Comment) -> Observable<Comment>
}

class BoxOffice: BoxOfficeType {
    
    func getMovieList(orderType: Int) -> Observable<MovieList> {
        return MovieRequest.getMovieListRx(orderType: orderType)
    }
    
    func getMovie(id: String) -> Observable<Movie> {
        return MovieRequest.getMovieRx(id: id)
    }
    
    func getCommentList(movieId: String) -> Observable<CommentList> {
        return CommentRequest.getCommentListRx(movieId: movieId)
    }
    
    func postComment(comment: Comment) -> Observable<Comment> {
        return CommentRequest.postCommentRx(comment: comment)
    }
}
