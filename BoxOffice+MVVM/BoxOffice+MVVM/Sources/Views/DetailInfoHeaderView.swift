//
//  BoxOfficeInfoCollectionViewCell.swift
//  BoostCourse5
//
//  Created by Haeseok Lee on 2021/08/25.
//

import UIKit
import RxSwift
import RxCocoa

final class DetailInfoHeaderView: UITableViewHeaderFooterView {
    
    // MARK: - Views
    private let infoTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "감독/출연"
        label.font = UIFont.systemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.restorationIdentifier = "infoTitleLabel"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let directorTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "감독"
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let directorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let directorStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .firstBaseline
        stackView.distribution = .fill
        stackView.spacing = UIStackView.spacingUseSystem
        stackView.accessibilityIdentifier = "directorStackView"
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let appearanceTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "출연"
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let appearanceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let appearanceStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .firstBaseline
        stackView.distribution = .fill
        stackView.spacing = UIStackView.spacingUseSystem
        stackView.accessibilityIdentifier = "appearanceStackView"
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let infoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 10
        stackView.accessibilityIdentifier = "infoStackView"
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: - Variables
    private let movie: PublishSubject<Movie> = PublishSubject<Movie>()
    var movieObserver: AnyObserver<Movie> { movie.asObserver() }

    var disposeBag: DisposeBag = DisposeBag()
    private let cellDisposeBag: DisposeBag = DisposeBag()
    
    // MARK: - Life Cycles
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupViews()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        setupBindings()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    // MARK: - Functions
    private func setupViews() {
        contentView.backgroundColor = .white
        
        [directorTitleLabel, directorLabel].forEach {
            directorStackView.addArrangedSubview($0)
        }
        [appearanceTitleLabel, appearanceLabel].forEach {
            appearanceStackView.addArrangedSubview($0)
        }
        [directorStackView, appearanceStackView].forEach {
            infoStackView.addArrangedSubview($0)
        }
        contentView.addSubview(infoTitleLabel)
        contentView.addSubview(infoStackView)
        
        directorTitleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        appearanceTitleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        directorLabel.setContentHuggingPriority(.init(rawValue: 1), for: .horizontal)
        appearanceLabel.setContentHuggingPriority(.init(rawValue: 1), for: .horizontal)
        
        NSLayoutConstraint.activate([
            infoTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            infoTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            infoTitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            
            infoStackView.leadingAnchor.constraint(equalTo: infoTitleLabel.leadingAnchor, constant: 20),
            infoStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            infoStackView.topAnchor.constraint(equalTo: infoTitleLabel.bottomAnchor, constant: 10),
            infoStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
        ])
    }
    
    private func setupBindings() {
        movie
            .observe(on: MainScheduler.instance)
            .bind { [weak self] movie in
                self?.directorLabel.text = movie.director
                self?.appearanceLabel.text = movie.actor
            }
            .disposed(by: cellDisposeBag)
    }
}
