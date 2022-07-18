//
//  ForecastViewController.swift
//  weather-app
//
//  Created by Dustin Mote on 7/16/22.
//

import UIKit

class ForecastViewController: UIViewController, ForecastNavigationCoordinated {

    weak var coordinator: ForecastNavigationCooridinator?
    
    var scrollView: UIScrollView?
    var stackView: UIStackView?
    
    var city1View: CityWeekForecastView?
    var city2View: CityWeekForecastView?
    var city3View: CityWeekForecastView?
    var city4View: CityWeekForecastView?
    var city5View: CityWeekForecastView?
    
    let cityViewHeight : CGFloat = 180
    var cityViews = [UIView?]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemMint
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupViews()
    }
    
    private func setupViews() {
        
        guard let forecast = coordinator?.currentForecast() else {

            assertionFailure("DataSource should be present")
            return
        }
        
        self.scrollView = UIScrollView(frame: .zero)
        scrollView?.translatesAutoresizingMaskIntoConstraints = false
        scrollView?.showsVerticalScrollIndicator = false
        scrollView?.showsHorizontalScrollIndicator = false
        scrollView?.alwaysBounceHorizontal = false
        
        for (i, n) in forecast.keys.enumerated() {
            
            switch i {
            case 0:
                self.city1View = CityWeekForecastView(with: forecast[n], delegate: self)
            case 1:
                self.city2View = CityWeekForecastView(with: forecast[n], delegate: self)
            case 2:
                self.city3View = CityWeekForecastView(with: forecast[n], delegate: self)
            case 3:
                self.city4View = CityWeekForecastView(with: forecast[n], delegate: self)
            case 4:
                self.city5View = CityWeekForecastView(with: forecast[n], delegate: self)
            default:
                break
            }
        }
        
    
        self.cityViews = [city1View, city2View, city3View, city4View, city5View]
        
        let spacing: CGFloat = 20
        let stackHeight : CGFloat = (CGFloat(cityViews.count) * cityViewHeight) + (spacing * CGFloat(cityViews.count - 1))
        self.stackView = UIStackView(frame: .init(origin: .zero,
                                                  size: .init(width: view.bounds.width,
                                                              height: stackHeight)))
        stackView?.axis = .vertical
        stackView?.distribution = .fill
        stackView?.alignment = .leading
        stackView?.spacing = spacing
        
        guard let scrollView = scrollView,
                let stackView = stackView else {
            
            assertionFailure("StackView & ScrollView should be instantiated")
            return
        }
        
        view.addSubview(scrollView)
        scrollView.contentSize = stackView.bounds.size
        scrollView.addSubview(stackView)
        
        for city in cityViews.compactMap( { $0 } ) {
            stackView.addArrangedSubview(city)
        }
        
        updateLayout()
        view.updateConstraintsIfNeeded()
    }
    
    private func updateLayout() {
        
        scrollView?.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor).activate()
        scrollView?.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor).activate()
        scrollView?.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).activate()
        scrollView?.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).activate()
        
        for aView in cityViews {
        
            aView?.heightAnchor.constraint(equalToConstant: cityViewHeight).activate()
            aView?.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor).activate()
        }
    
        
        view.updateConstraintsIfNeeded()
    }
}


extension ForecastViewController : CityWeekForecastViewDelegate {
    
    func requestIcon(for url: URL, _ completion: @escaping (UIImage?) -> Void) {
        
        coordinator?.didRequestImage(for: url, { imageResult in
        
            completion(try? imageResult.get())
        })
    }
    
    func isRequestingCelsius() -> Bool {
        
        guard let coordinator = coordinator else { return false }
        return coordinator.isRequestingCelsius()
    }
    
    func didSelect(period: WeatherForecastPeriodData) {
        coordinator?.didSelectForecastPeriod(period)
    }
}
