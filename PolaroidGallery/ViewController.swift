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
  
  @IBOutlet private weak var addNewPolaroidButton: UIButton! {
    didSet {
      addNewPolaroidButton.setTitle("Hinzufügen", for: .normal)
    }
  }
  
  // MARK: - Properties
  
  private var polaroids = ["a", "b", "c", "d", "e", "f", "g"]
  private var polaroidViews: [PolaroidView] = []
  private var leftMostConstraint: NSLayoutConstraint?
  
  // MARK: - Functions
  
  override func viewDidLoad() {
    super.viewDidLoad()

    fillWithPolaroids()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    animatePolaroids()
  }
  
  @IBAction private func addNewPolaroid() {
    
    guard let newPolaroidView = createPolaroid() else {
      return
    }
    
    let previousPolaroidView = polaroidViews.last!
    
    newPolaroidView.center.y = scrollView.center.y
    newPolaroidView.center.x -= scrollView.frame.width*2
    
    containerView.addSubview(newPolaroidView)
    
    newPolaroidView.rightAnchor.constraint(equalTo: previousPolaroidView.leftAnchor, constant: 8).isActive = true
    
    if let leftMostConstraint = leftMostConstraint {
      containerView.removeConstraint(leftMostConstraint)
    }
    leftMostConstraint = newPolaroidView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 32)
    leftMostConstraint?.isActive = true
    
    newPolaroidView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8).isActive = true
    newPolaroidView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8).isActive = true
    newPolaroidView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 0.8).isActive = true
    
    polaroidViews.append(newPolaroidView)
    
    polaroids.append("new")
    
    UIView.animate(withDuration: 1, delay: 0, options: .transitionCurlUp, animations: {
      self.scrollView.layoutIfNeeded()
    }, completion: nil)
  }
  
  private func animatePolaroids(hasNewPolaroid: Bool = true) {

    guard polaroidViews.count>1 else {
      return
    }
    
    let firstPolaroid = polaroidViews.last!
    let secondPolaroid = polaroidViews[polaroidViews.count-2]
    
    let firstPolaroidCenter = firstPolaroid.center
    let secondPolaroidCenter = secondPolaroid.center
    
    if hasNewPolaroid {
      
      firstPolaroid.center.x -= firstPolaroid.frame.width
      
      UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear, animations: {
        firstPolaroid.center = firstPolaroidCenter
      }, completion: nil)
      
    } else {
      
      firstPolaroid.center.x += firstPolaroid.frame.width
      secondPolaroid.center.x += secondPolaroid.frame.width
      
      UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear, animations: {
        firstPolaroid.center = firstPolaroidCenter
      }, completion: nil)
      
      UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveLinear, animations: {
        secondPolaroid.center = secondPolaroidCenter
      }, completion: nil)
    }
  }
  
  private func createPolaroid() -> PolaroidView? {
    
    guard let polaroidView = Bundle.main.loadNibNamed("PolaroidView", owner: self, options: nil)?.first as? PolaroidView else {
      return nil
    }
    
    polaroidView.translatesAutoresizingMaskIntoConstraints = false
    
    polaroidView.photo = #imageLiteral(resourceName: "Mathias-1")
    polaroidView.descriptionText = growsSinceText
    
    return polaroidView
  }
  
  private func fillWithPolaroids() {
    
    for _ in polaroids {
      
      guard let polaroidView = createPolaroid() else {
        return
      }
      
      containerView.addSubview(polaroidView)
      
      if polaroidViews.isEmpty {
        polaroidView.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -64).isActive = true
      } else {
        polaroidView.rightAnchor.constraint(equalTo: polaroidViews.last!.leftAnchor, constant: 8).isActive = true
      }

      if let leftMostConstraint = leftMostConstraint {
        containerView.removeConstraint(leftMostConstraint)
      }
      leftMostConstraint = polaroidView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 32)
      leftMostConstraint?.isActive = true
      
      polaroidView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8).isActive = true
      polaroidView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8).isActive = true
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
