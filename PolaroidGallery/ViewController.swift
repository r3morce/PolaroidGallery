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

  fileprivate var polaroidViews: [PolaroidView] = []
  fileprivate var hasNewPolaroid: Bool = false
  fileprivate var photos = [#imageLiteral(resourceName: "Mathias-1"), #imageLiteral(resourceName: "Mathias-2")]
  
  private var leftMostConstraint: NSLayoutConstraint?
  
  // MARK: - IBActions
  
  // Todo: Refactor outlet name
  @IBAction private func addNewPolaroid() {
    
    let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    
    let cancelAction = UIAlertAction(title: "Abbrechen", style: .cancel) { action in
    }
    
    let takePhotoAction = UIAlertAction(title: "Foto machen", style: .default) { _ in
      
      // Take Photo
      if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
      }
    }
    
    let selectFromLibraryAction = UIAlertAction(title: "Foto auswählen", style: .default) { _ in
      
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
    
    fillWithPolaroids()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    if hasNewPolaroid {
      addPolaroid(photo: photos.last!, descriptionText: growsSinceText)
    } else {
      animatePolaroids()
    }
  }
  
  // MARK: - Functions
  
  // Todo: Refactor function name
  fileprivate func addPolaroid(photo: UIImage, descriptionText: String) {
    
    guard let newPolaroidView = createPolaroid(photo: photo, descriptionText: descriptionText) else {
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
    
    self.hasNewPolaroid = false
  }
  
  private func createPolaroid(photo: UIImage, descriptionText: String) -> PolaroidView? {
    
    guard let polaroidView = Bundle.main.loadNibNamed("PolaroidView", owner: self, options: nil)?.first as? PolaroidView else {
      return nil
    }
    
    polaroidView.translatesAutoresizingMaskIntoConstraints = false
    
    polaroidView.photo = photo
    polaroidView.descriptionText = descriptionText
    
    return polaroidView
  }
  
  private func fillWithPolaroids() {
    
    for photo in photos {
      
      guard let polaroidView = createPolaroid(photo: photo, descriptionText: growsSinceText) else {
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

// MARK: - UIImagePickerControllerDelegate

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    
    if let photo = info["UIImagePickerControllerEditedImage"] as? UIImage {
      photos.append(photo)
      hasNewPolaroid = true
    } else {
      print("Something went wrong")
    }
    
    self.dismiss(animated: true, completion: nil)
  }
}
