//
//  BoxOfficeReviewCollectionReusableView.swift
//  BoostCourse5
//
//  Created by Haeseok Lee on 2021/08/25.
//

import UIKit

protocol BoxOfficeDetailReviewHeaderDelegate: AnyObject {
    func touchReviewWriteButton()
}

final class BoxOfficeDetailReviewHeaderView: UITableViewHeaderFooterView {
    
    // MARK: - Views
    private let reviewTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "한줄평"
        label.font = UIFont.systemFont(ofSize: 18)
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var reviewWriteButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(touchUpReviewWriteButton), for: .touchUpInside)
        button.setImage(UIImage(named: "btn_compose"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let reviewStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalCentering
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: - Variables
    weak var boxOfficeDetailReviewHeaderDelegate: BoxOfficeDetailReviewHeaderDelegate?
    
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
        
        [reviewTitleLabel, reviewWriteButton].forEach {
            reviewStackView.addArrangedSubview($0)
        }
        contentView.addSubview(reviewStackView)
        
        NSLayoutConstraint.activate([
            reviewStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            reviewStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            reviewStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            reviewStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    @objc
    private func touchUpReviewWriteButton() {
        boxOfficeDetailReviewHeaderDelegate?.touchReviewWriteButton()
    }
}
