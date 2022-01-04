//
//  BoxOfficeTableViewCell.swift
//  BoostCourse5
//
//  Created by Haeseok Lee on 2021/08/25.
//

import UIKit

final class BoxOfficeTableViewCell: UITableViewCell {
    
    // MARK: - Views
    private let movieImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let movieTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let movieGradeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let movieTitleStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = UIStackView.spacingUseSystem
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let movieInfoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let movieOpeningDateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let movieInfoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fill
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: - Variables
    static let height: CGFloat = 130
    
    var movie: Movie? {
        didSet {
            guard let movie = movie else { return }
            movieTitleLabel.text = movie.title
            movieGradeImageView.image = UIImage(named: movie.gradeImageName)
            movieInfoLabel.text = "평점 : \(movie.userRating) 예매순위 : \(movie.reservationGrade) 예매율 : \(movie.reservationRate)"
            movieOpeningDateLabel.text = "개봉일 : \(movie.date)"
        }
    }
    
    // MARK: - LifeCycles
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        movieImageView.image = UIImage(named: "img_placeholder")
        movieTitleLabel.text = nil
        movieGradeImageView.image = nil
        movieInfoLabel.text = nil
        movieOpeningDateLabel.text = nil
    }
    
    // MARK: - Functions
    private func setupViews() {
        selectionStyle = .none
        
        [movieTitleLabel, movieGradeImageView].forEach { view in
            movieTitleStackView.addArrangedSubview(view)
        }
        [movieTitleStackView, movieInfoLabel, movieOpeningDateLabel].forEach { view in
            movieInfoStackView.addArrangedSubview(view)
        }
        contentView.addSubview(movieImageView)
        contentView.addSubview(movieInfoStackView)
        
        movieTitleLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
        
        NSLayoutConstraint.activate([
            movieImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            movieImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            movieImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            
            movieImageView.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.4),
            movieImageView.widthAnchor.constraint(equalTo: movieImageView.heightAnchor, multiplier: 3/4),
            
            movieInfoStackView.leadingAnchor.constraint(equalTo: movieImageView.trailingAnchor, constant: 10),
            movieInfoStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            movieInfoStackView.topAnchor.constraint(equalTo: movieImageView.topAnchor, constant: 10),
            movieInfoStackView.bottomAnchor.constraint(equalTo: movieImageView.bottomAnchor, constant: -10),
            
            movieGradeImageView.widthAnchor.constraint(equalTo: movieGradeImageView.heightAnchor),
        ])
    
    }
    
    func update(image: UIImage) {
        movieImageView.image = image
    }
}
