//
//  StarScoringBarView.swift
//  BoostCourse5
//
//  Created by Haeseok Lee on 2021/08/25.
//

import UIKit
import RxSwift
import RxGesture

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
        slider.minimumValue = 0
        slider.maximumValue = 10
        slider.value = 10
        slider.isEnabled = false
        slider.minimumTrackTintColor = .clear
        slider.maximumTrackTintColor = .clear
        slider.thumbTintColor = .clear
        slider.accessibilityIdentifier = "starRaingSlider"
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    // MARK: - Variables
    private let isEnabled: BehaviorSubject<Bool>
    private let userRating: BehaviorSubject<Double>
    
    var isEnabledObserver: AnyObserver<Bool> { isEnabled.asObserver() }
    var userRatingObserver: AnyObserver<Double> { userRating.asObserver() }
    var userRatingObservable: Observable<Double> { userRating.asObservable() }
    
    private let disposeBag: DisposeBag = DisposeBag()
    
    // MARK: - Life Cycles
    init(isEnabled: Bool, userRating: Double) {
        self.isEnabled = BehaviorSubject<Bool>(value: isEnabled)
        self.userRating = BehaviorSubject<Double>(value: userRating)
        super.init(frame: .zero)
        setupViews()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        isEnabled = BehaviorSubject<Bool>(value: false)
        userRating = BehaviorSubject<Double>(value: 10)
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
    
    private func setupBindings() {
        isEnabled
            .asDriver(onErrorJustReturn: false)
            .drive(starRatingSlider.rx.isEnabled)
            .disposed(by: disposeBag)
            
        userRating
            .observe(on: MainScheduler.instance)
            .bind { [weak self] rating in
                self?.updateStarImageViews(userRating: rating)
            }
            .disposed(by: disposeBag)
        
        let starRatingSliderValue = starRatingSlider.rx.value
            .map { ceil($0) }
            .share(replay: 1, scope: .whileConnected)
        
        starRatingSliderValue
            .asDriver(onErrorJustReturn: 0)
            .drive(starRatingSlider.rx.value)
            .disposed(by: disposeBag)
        
        starRatingSliderValue
            .map { Double($0) }
            .bind(to: userRating)
            .disposed(by: disposeBag)
        
        starRatingSlider.rx
            .tapGesture()
            .when(.recognized)
            .bind {[weak self] sender in
                let location = sender.location(in: self)
                let minimumValue = self?.starRatingSlider.minimumValue ?? 0
                let maximumValue = self?.starRatingSlider.maximumValue ?? 10
                let width = self?.starRatingSlider.bounds.width ?? 100
                let percent = minimumValue + Float(location.x / width) * maximumValue
                self?.starRatingSlider.setValue(percent, animated: true)
                self?.starRatingSlider.sendActions(for: .valueChanged)
            }
            .disposed(by: disposeBag)
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
}
