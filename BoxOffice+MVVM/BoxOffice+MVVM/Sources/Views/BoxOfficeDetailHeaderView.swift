//
//  BoxOfficeHeaderCollectionViewCell.swift
//  BoostCourse5
//
//  Created by Haeseok Lee on 2021/08/25.
//

import UIKit

protocol BoxOfficeHeaderDelegate: AnyObject {
    func touchUpMovieImageView(image: UIImage?)
}

final class BoxOfficeDetailHeaderView: UITableViewHeaderFooterView {
    
    // MARK: - Views
    private lazy var movieImageView: UIImageView = {
        let imageView = UIImageView()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(touchUpMovieImageView))
        imageView.addGestureRecognizer(tapGesture)
        imageView.image = UIImage(named: "img_placeholder")
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.accessibilityIdentifier = "movieImageView"
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let movieTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.adjustsFontForContentSizeCategory = true
        label.accessibilityIdentifier = "movieTitleLabel"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let movieGradeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.accessibilityIdentifier = "movieGradeImageView"
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let blockView: UIView = {
        let view = UIView()
        view.accessibilityIdentifier = "blockView"
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let movieTitleStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = UIStackView.spacingUseSystem
        stackView.accessibilityIdentifier = "movieTitleStackView"
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let movieInfoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fill
        stackView.spacing = UIStackView.spacingUseSystem
        stackView.accessibilityIdentifier = "movieInfoStackView"
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let movieRightInfoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fill
        stackView.accessibilityIdentifier = "movieRightInfoStackView"
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let movieTopStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 10
        stackView.accessibilityIdentifier = "movieTopStackView"
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let movieOpeningDateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.adjustsFontForContentSizeCategory = true
        label.accessibilityIdentifier = "movieOpeningDateLabel"
        label.translatesAutoresizingMaskIntoConstraints = true
        return label
    }()
    
    private let movieGenreAndRunningTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.adjustsFontForContentSizeCategory = true
        label.accessibilityIdentifier = "movieGenreAndRunningTimeLabel"
        label.translatesAutoresizingMaskIntoConstraints = true
        return label
    }()
    
    private let movieRateTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "예매율"
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.adjustsFontForContentSizeCategory = true
        label.accessibilityIdentifier = "movieRateTitleLabel"
        label.translatesAutoresizingMaskIntoConstraints = true
        return label
    }()
    
    private let movieRateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.adjustsFontForContentSizeCategory = true
        label.accessibilityIdentifier = "movieRateLabel"
        label.translatesAutoresizingMaskIntoConstraints = true
        return label
    }()
    
    private let movieReservationTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "평점"
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.adjustsFontForContentSizeCategory = true
        label.accessibilityIdentifier = "movieReservationTitleLabel"
        label.translatesAutoresizingMaskIntoConstraints = true
        return label
    }()
    
    private let movieReservationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.adjustsFontForContentSizeCategory = true
        label.accessibilityIdentifier = "movieReservationLabel"
        label.translatesAutoresizingMaskIntoConstraints = true
        return label
    }()
    
    private let movieAttendanceTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "누적관객수"
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.adjustsFontForContentSizeCategory = true
        label.accessibilityIdentifier = "movieAttendanceTitleLabel"
        label.translatesAutoresizingMaskIntoConstraints = true
        return label
    }()
    
    private let movieAttendanceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.adjustsFontForContentSizeCategory = true
        label.accessibilityIdentifier = "movieAttendanceLabel"
        label.translatesAutoresizingMaskIntoConstraints = true
        return label
    }()
    
    private let movieRateStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 15
        stackView.accessibilityIdentifier = "movieRateStackView"
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let movieReservationStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = UIStackView.spacingUseSystem
        stackView.accessibilityIdentifier = "movieReservationStackView"
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let movieAttendanceStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 15
        stackView.accessibilityIdentifier = "movieAttendanceStackView"
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let movieBottomStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = 0
        stackView.accessibilityIdentifier = "movieBottomStackView"
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let movieStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 10
        stackView.accessibilityIdentifier = "movieStackView"
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let movieStarRatingBarView: StarRatingBarView = {
        let view = StarRatingBarView(isEnabled: false, userRating: 0)
        view.accessibilityIdentifier = "movieStarRatingBarView"
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Variables
    var movie: Movie? {
        didSet {
            guard let movie = movie else { return }
            movieTitleLabel.text = movie.title
            movieGradeImageView.image = UIImage(named: movie.gradeImageName)
            movieOpeningDateLabel.text = "\(movie.date) 개봉"
            movieGenreAndRunningTimeLabel.text = "\(movie.genre ?? "")/\(movie.duration ?? 0)분"
            movieReservationLabel.text = "\(movie.userRating)"
            movieRateLabel.text = "\(movie.reservationGrade)위 \(movie.reservationRate)%"
            movieAttendanceLabel.text = intWithCommas(num: movie.audience)
            movieStarRatingBarView.updateStarImageViews(userRating: movie.userRating)
        }
    }
    
    var image: UIImage? {
        didSet {
            movieImageView.image = image
        }
    }
    
    weak var boxOfficeHeaderDelegate: BoxOfficeHeaderDelegate?
    
    // MARK: - Life Cycles
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    // MARK: - Functions
    private func setupViews() {
        contentView.backgroundColor = .white
        
        [movieTitleLabel, movieGradeImageView].forEach {
            movieTitleStackView.addArrangedSubview($0)
        }
        [movieTitleStackView, movieOpeningDateLabel, movieGenreAndRunningTimeLabel].forEach {
            movieInfoStackView.addArrangedSubview($0)
        }
        [blockView, movieInfoStackView].forEach {
            movieRightInfoStackView.addArrangedSubview($0)
        }
        [movieImageView, movieRightInfoStackView].forEach {
            movieTopStackView.addArrangedSubview($0)
        }
        [movieRateTitleLabel, movieRateLabel].forEach {
            movieRateStackView.addArrangedSubview($0)
        }
        [movieReservationTitleLabel, movieReservationLabel, movieStarRatingBarView].forEach {
            movieReservationStackView.addArrangedSubview($0)
        }
        [movieAttendanceTitleLabel, movieAttendanceLabel].forEach {
            movieAttendanceStackView.addArrangedSubview($0)
        }
        [movieRateStackView, movieReservationStackView, movieAttendanceStackView].forEach {
            movieBottomStackView.addArrangedSubview($0)
        }
        [movieTopStackView, movieBottomStackView].forEach {
            movieStackView.addArrangedSubview($0)
        }
        contentView.addSubview(movieStackView)
        
        NSLayoutConstraint.activate([
            movieStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            movieStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            movieStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            movieStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            
            movieImageView.widthAnchor.constraint(equalTo: movieImageView.heightAnchor, multiplier: 3/4),
            movieImageView.heightAnchor.constraint(equalToConstant: 200),
            
            blockView.widthAnchor.constraint(equalTo: movieRightInfoStackView.widthAnchor),
            blockView.heightAnchor.constraint(greaterThanOrEqualTo: movieRightInfoStackView.heightAnchor, multiplier: 0.25),
            
            movieGradeImageView.widthAnchor.constraint(equalToConstant: 25),
            movieGradeImageView.widthAnchor.constraint(equalTo: movieGradeImageView.heightAnchor),
            
            movieStarRatingBarView.widthAnchor.constraint(equalTo: movieStarRatingBarView.heightAnchor, multiplier: 5),
            movieStarRatingBarView.heightAnchor.constraint(equalToConstant: 18),
        ])
    }
    
    @objc
    private func touchUpMovieImageView() {
        boxOfficeHeaderDelegate?.touchUpMovieImageView(image: movieImageView.image)
    }
    
    private func intWithCommas(num: Int?) -> String? {
        if let num = num {
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            return numberFormatter.string(from: NSNumber(value: num))
        }
        return nil
    }
}
