//
//  Photo.swift
//  PolaroidGallery
//
//  Created by mathias@privat on 24.03.17.
//  Copyright © 2017 mathias. All rights reserved.
//

import Foundation
import UIKit

struct Photo {
  var image: UIImage
  var date: Date
  
  init(image: UIImage, date: Date) {
    self.image = image
    self.date = date    
  }
}
