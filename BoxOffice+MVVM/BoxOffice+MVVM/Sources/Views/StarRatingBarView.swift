//
//  StarScoringBarView.swift
//  BoostCourse5
//
//  Created by Haeseok Lee on 2021/08/25.
//

import UIKit

protocol StarRatingBarDelegate: AnyObject {
    func ratingUpdated(rating: Double?)
}

final class StarRatingBarView: UIView {

    // MARK: - Views
    private let starImageViews: [UIImageView] = {
        return (0...4).map { i in
            let imageView = UIImageView()
            imageView.image = UIImage(named: "ic_star_large")
            imageView.accessibilityIdentifier = "star\(i)ImageView"
            imageView.translatesAutoresizingMaskIntoConstraints = false
            return imageView
        }
    }()
    
    private let starImageStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 0
        stackView.backgroundColor = .white
        stackView.accessibilityIdentifier = "starImageStackView"
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var starRatingSlider: UISlider = {
        let slider = UISlider()
        slider.addTarget(self, action: #selector(valueChangedStarRatingSlider), for: .valueChanged)
        slider.minimumValue = 0
        slider.maximumValue = 10
        slider.value = 0
        slider.isEnabled = false
        slider.minimumTrackTintColor = .clear
        slider.maximumTrackTintColor = .clear
        slider.thumbTintColor = .clear
        slider.accessibilityIdentifier = "starRaingSlider"
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    // MARK: - Variables
    weak var starRatingBarDelegate: StarRatingBarDelegate?
    
    // MARK: - Life Cycles
    init(isEnabled: Bool, userRating: Double) {
        super.init(frame: .zero)
        setupViews()
        starRatingSlider.isEnabled = isEnabled
        starRatingSlider.value = Float(userRating)
        updateStarImageViews(userRating: userRating)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Functions
    private func setupViews() {
        starImageViews.forEach { view in
            starImageStackView.addArrangedSubview(view)
        }
        addSubview(starImageStackView)
        addSubview(starRatingSlider)
        
        NSLayoutConstraint.activate([
            starImageStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            starImageStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            starImageStackView.topAnchor.constraint(equalTo: topAnchor),
            starImageStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            starRatingSlider.leadingAnchor.constraint(equalTo: starImageStackView.leadingAnchor),
            starRatingSlider.trailingAnchor.constraint(equalTo: starImageStackView.trailingAnchor),
            starRatingSlider.topAnchor.constraint(equalTo: starImageStackView.topAnchor),
            starRatingSlider.bottomAnchor.constraint(equalTo: starImageStackView.bottomAnchor),
        ])
        
        let starImageViewsRatioConstraints = starImageStackView.arrangedSubviews.map {
            $0.widthAnchor.constraint(equalTo: $0.heightAnchor)
        }
        NSLayoutConstraint.activate(starImageViewsRatioConstraints)
    }
    
    func updateStarImageViews(userRating: Double) {
        let emptyStarImage = UIImage(named: "ic_star_large")
        let fullStarImage = UIImage(named: "ic_star_large_full")
        let halfStarImage = UIImage(named: "ic_star_large_half")
        let userRating = Int(userRating)
        let idx = (userRating - 1) / 2
        
        starImageStackView.arrangedSubviews.forEach { view in
            if let view = view as? UIImageView {
                view.image = emptyStarImage
            }
        }
        
        if userRating == 0 { return }
        if idx >= 1 {
            zip((0...idx-1), starImageStackView.arrangedSubviews).forEach { _, view in
                if let view = view as? UIImageView { view.image = fullStarImage }
            }
        }
        if let view = starImageStackView.arrangedSubviews[idx] as? UIImageView {
            view.image = userRating % 2 == 0 ? fullStarImage : halfStarImage
        }
    }
                         
    @objc
    private func valueChangedStarRatingSlider() {
        let currentRating = ceil(starRatingSlider.value)
        starRatingSlider.setValue(currentRating, animated: true)
        updateStarImageViews(userRating: Double(currentRating))
        starRatingBarDelegate?.ratingUpdated(rating: Double(currentRating))
    }
}
