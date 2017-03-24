//
//  PolaroidView.swift
//  PolaroidGallery
//
//  Created by mathias@privat on 17.03.17.
//  Copyright © 2017 mathias. All rights reserved.
//

import UIKit

class PolaroidView: UIView {
  
  // MARK: - Properties
  
  var image: UIImage? {
    didSet {
       UIView.transition(with: photoImageView, duration: 0.5, options: [.transitionCrossDissolve], animations: {
        self.photoImageView.image = self.image
       }, completion: nil)
    }
  }
  
  var descriptionText: String? {
    didSet {
      descriptionLabel.text = descriptionText
    }
  }

  // MARK: - Outlets
  
  @IBOutlet private weak var polaroidFrameView: UIView! {
    didSet {
      polaroidFrameView.layer.shouldRasterize = true
      polaroidFrameView.layer.rasterizationScale = UIScreen.main.scale
      polaroidFrameView.transform = CGAffineTransform(rotationAngle: randomRotationInRad)
    }
  }
  
  @IBOutlet private weak var photoImageView: UIImageView!
  
  @IBOutlet private weak var descriptionLabel: UILabel! {
    didSet {
      descriptionLabel.textColor = .black
      descriptionLabel.font = UIFont(name: "Quikhand", size: 18)
      descriptionLabel.lineBreakMode = .byWordWrapping
      descriptionLabel.numberOfLines = 2
    }
  }
  
  // MARK: - Functions

  private var randomRotationInRad: CGFloat {
    
    let randomRotationInDegree = CGFloat(350+arc4random_uniform(20)) // 350° to 10°
    let rad = CGFloat(0.0174533) // Google "degree to rad"
    
    return rad*randomRotationInDegree
  }
}
