//
//  ViewController.swift
//  PolaroidGallery
//
//  Created by mathias@privat on 16.03.17.
//  Copyright © 2017 mathias. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
  // MARK: - Outlets
  
  @IBOutlet private weak var scrollView: UIScrollView! {
    didSet {
      scrollView.translatesAutoresizingMaskIntoConstraints = false
      scrollView.flashScrollIndicators()
      scrollView.backgroundColor = .brown
    }
  }
  
  @IBOutlet weak var containerView: UIView! {
    didSet {
      containerView.translatesAutoresizingMaskIntoConstraints = false
      containerView.backgroundColor = nil
    }
  }
  
  @IBOutlet weak var containerViewWidthConstraint: NSLayoutConstraint!
  
  // MARK: - Properties
  
  private var polaroids = ["a", "b", "c", "d", "e", "f", "g"]
  private var polaroidViews: [PolaroidView] = []
  
  // MARK: - Functions
  
  override func viewDidLoad() {
    super.viewDidLoad()

    containerViewWidthConstraint.constant = view.frame.width*CGFloat(polaroids.count-1)
    fillWithPolaroids()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    animatePolaroids()
  }
  
  private func animatePolaroids() {

    guard polaroidViews.count>1 else {
      return
    }
    
    let firstPolaroid = polaroidViews[0]
    let secondPolaroid = polaroidViews[1]
    
    let firstPolaroidCenter = firstPolaroid.center
    let secondPolaroidCenter = secondPolaroid.center
    
    firstPolaroid.center.x += firstPolaroid.frame.width
    secondPolaroid.center.x += secondPolaroid.frame.width
    
    UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
      firstPolaroid.center = firstPolaroidCenter
    }, completion: nil)
    
    UIView.animate(withDuration: 0.2, delay: 0.1, options: .curveLinear, animations: {
      secondPolaroid.center = secondPolaroidCenter
    }, completion: nil)
  }
  
  private func fillWithPolaroids() {
    
    for _ in polaroids {
      
      guard let polaroidView = Bundle.main.loadNibNamed("PolaroidView", owner: self, options: nil)?.first as? PolaroidView else {
        return
      }
      
      polaroidView.photo = #imageLiteral(resourceName: "Mathias")
      polaroidView.descriptionText = growsSinceText
      
      polaroidView.translatesAutoresizingMaskIntoConstraints = false
      
      containerView.addSubview(polaroidView)
      
      polaroidView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8).isActive = true
      polaroidView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8).isActive = true
      polaroidView.leftAnchor.constraint(equalTo: polaroidViews.isEmpty ? containerView.leftAnchor : polaroidViews[polaroidViews.count-1].rightAnchor, constant: 8).isActive = true
      polaroidView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 0.8).isActive = true
      
      polaroidViews.append(polaroidView)
    }
  }
  
  private var growsSinceText: String {
    
    let randomDate = Calendar.current.date(byAdding: .day, value: -Int(arc4random_uniform(400)), to: Date())! // up to 400 days in the past
    
    if Calendar.current.isDateInToday(randomDate) {
      return "Heute erst angefangen ;-)"
      
    } else if Calendar.current.isDateInYesterday(randomDate) {
      return "Gestern angefangen"
      
    } else {
      
      // must be older than yesterday
      let startInDays = Calendar.current.ordinality(of: .day, in: .era, for: randomDate)!
      let endInDays = Calendar.current.ordinality(of: .day, in: .era, for: Date())!
      
      let difference = endInDays-startInDays
      
      return "Wächst seit \(difference) Tagen"
    }
  }
}

extension ViewController: UIScrollViewDelegate {
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    print(#function)
  }
  
}
