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
      addNewPolaroidButton.setTitle("Add new photo", for: .normal)
    }
  }
  
  // MARK: - Properties
  
  fileprivate enum Status {
    case firstStart
    case newPhoto
    case returning
  }

  fileprivate var polaroidViews: [PolaroidView] = []

  
  fileprivate var status: Status = .firstStart

  fileprivate var randomDate: Date {
    let randomDate = Calendar.current.date(byAdding: .day, value: -Int(arc4random_uniform(400)), to: Date())! // up to 400 days in the past
    return randomDate
  }
  
  fileprivate var photos: [Photo] = []
  
  private var leftMostConstraint: NSLayoutConstraint?
  
  // MARK: - IBActions
  
  // Todo: Refactor outlet name
  @IBAction private func addNewPolaroid() {
    
    let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
    }
    
    let takePhotoAction = UIAlertAction(title: "Take photo", style: .default) { _ in
      
      // Take Photo
      if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
      }
    }
    
    let selectFromLibraryAction = UIAlertAction(title: "Select form library", style: .default) { _ in
      
      // Open library
      if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
      }
    }
    
    alertController.addAction(cancelAction)
    alertController.addAction(takePhotoAction)
    alertController.addAction(selectFromLibraryAction)
    
    self.present(alertController, animated: true)
  }
  
  // MARK: - Lifecircle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    photos.append(Photo(image: #imageLiteral(resourceName: "Mathias-2"), date: randomDate))
    photos.append(Photo(image: #imageLiteral(resourceName: "Mathias-1"), date: randomDate))
    
    fillWithPolaroids()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    switch status {
    case .newPhoto:
      addPolaroid(photo: photos.last!)
    case .firstStart:
      animatePolaroids()
    case .returning:()
    }
    
    status = .returning
  }
  
  // MARK: - Functions
  
  // Todo: Refactor function name
  fileprivate func addPolaroid(photo: Photo) {
    
    guard let newPolaroidView = createPolaroid(photo: photo) else {
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
    
    photos.append(photo)
    
    UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
      self.scrollView.layoutIfNeeded()
    }, completion: nil)
  }
  
  private func animatePolaroids() {
    
    guard polaroidViews.count>1 else {
      return
    }
    
    let firstPolaroid = polaroidViews.last!
    let secondPolaroid = polaroidViews[polaroidViews.count-2]
    
    let firstPolaroidCenter = firstPolaroid.center
    let secondPolaroidCenter = secondPolaroid.center
    
    firstPolaroid.center.x += firstPolaroid.frame.width
    secondPolaroid.center.x += secondPolaroid.frame.width
    
    UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear, animations: {
      firstPolaroid.center = firstPolaroidCenter
    }, completion: nil)
    
    UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveLinear, animations: {
      secondPolaroid.center = secondPolaroidCenter
    }, completion: nil)
  }
  
  private func createPolaroid(photo: Photo) -> PolaroidView? {
    
    guard let polaroidView = Bundle.main.loadNibNamed("PolaroidView", owner: self, options: nil)?.first as? PolaroidView else {
      return nil
    }
    
    polaroidView.translatesAutoresizingMaskIntoConstraints = false
    
    polaroidView.image = photo.image
    polaroidView.descriptionText = growsSinceText(from: photo.date)
    
    return polaroidView
  }
  
  private func fillWithPolaroids() {
    
    for photo in photos {
      
      guard let polaroidView = createPolaroid(photo: photo) else {
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
  
  private func growsSinceText(from photoDate: Date) -> String {
    
    if Calendar.current.isDateInToday(photoDate) {
      return "Started today ;-)"
      
    } else if Calendar.current.isDateInYesterday(photoDate) {
      return "Started yesterday"
      
    } else {
      
      // must be older than yesterday
      let startInDays = Calendar.current.ordinality(of: .day, in: .era, for: photoDate)!
      let endInDays = Calendar.current.ordinality(of: .day, in: .era, for: Date())!
      
      let difference = endInDays-startInDays
      
      return "Grows since \(difference) days"
    }
  }
}

// MARK: - UIImagePickerControllerDelegate

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    
    if let photo = info["UIImagePickerControllerEditedImage"] as? UIImage {
      photos.append(Photo(image: photo, date: randomDate))
      status = .newPhoto
    }
    
    self.dismiss(animated: true, completion: nil)
  }
}
