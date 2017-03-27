//
//  ViewController.swift
//  PolaroidGallery
//
//  Created by mathias@privat on 16.03.17.
//  Copyright © 2017 mathias. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
  
  // MARK: - Outlets
  
  @IBOutlet private weak var scrollView: UIScrollView! {
    didSet {
      scrollView.translatesAutoresizingMaskIntoConstraints = false
      scrollView.flashScrollIndicators()
      scrollView.backgroundColor = .brown
    }
  }

  @IBOutlet private weak var stackView: UIStackView!
//  @IBOutlet private weak var stackViewWidth: NSLayoutConstraint!
  
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

//  fileprivate var polaroidViews: [PolaroidView] = []
  fileprivate var status: Status = .firstStart

  fileprivate var randomDate: Date {
    let randomDate = Calendar.current.date(byAdding: .day, value: -Int(arc4random_uniform(400)), to: Date())! // up to 400 days in the past
    return randomDate
  }
  
  fileprivate var photos: [PhotoEntity] {
    do {
      let request = NSFetchRequest<PhotoEntity>(entityName: "PhotoEntity")
      return try self.managedContext.fetch(request)      
    } catch {
      fatalError("Couldn't access photos")
    }
  }

  
  private var leftMostConstraint: NSLayoutConstraint?
  
  // MARK: Core data
  
  fileprivate var appDelegate: AppDelegate {
    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
      return appDelegate
    } else {
      fatalError("Couln't access app delegate")
    }
  }
  
  fileprivate var managedContext: NSManagedObjectContext {
    return appDelegate.persistentContainer.viewContext
  }
  
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
    
    fillWithPolaroids()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    switch status {
    case .newPhoto:
      guard let newPolaroidView = createPolaroid(photo: photos.last!) else {
        return
      }
      addPolaroidToGalery(newPolaroidView: newPolaroidView)
    case .firstStart:()
      // animatePolaroids()
    case .returning:()
    }
    
    status = .returning
  }
  
  // MARK: - Functions
  
  // Todo: Refactor function name
  private func fillWithPolaroids() {
    
//    polaroidViews = []
    
    for photo in photos {
      
      guard let polaroidView = createPolaroid(photo: photo) else {
        return
      }
      
      addPolaroidToGalery(newPolaroidView: polaroidView)
    }
  }
  
  private func createPolaroid(photo: PhotoEntity) -> PolaroidView? {
    
    guard let polaroidView = Bundle.main.loadNibNamed("PolaroidView", owner: self, options: nil)?.first as? PolaroidView else {
      return nil
    }
    
    guard let data = photo.image as? Data, let image = UIImage(data: data, scale:1.0) else {
      return nil
    }
    
    guard let date = photo.date as? Date else {
      return nil
    }
    
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ViewController.polaroidTapped(gesture:)))
    polaroidView.addGestureRecognizer(tapGesture)
    polaroidView.isUserInteractionEnabled = true
    
    polaroidView.translatesAutoresizingMaskIntoConstraints = false
    
    polaroidView.image = image
    polaroidView.descriptionText = growsSinceText(from: date)
    polaroidView.entity = photo
    
    return polaroidView
  }
  
  fileprivate func addPolaroidToGalery(newPolaroidView: PolaroidView) {

    stackView.addArrangedSubview(newPolaroidView)
    
    newPolaroidView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 0.8).isActive = true
    newPolaroidView.heightAnchor.constraint(equalTo: scrollView.heightAnchor, multiplier: 1).isActive = true
    
//    stackViewWidth.constant = view.frame.width*CGFloat(photos.count)
    // polaroidViews.append(newPolaroidView)    
    
//    UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
//      self.scrollView.layoutIfNeeded()
//    }, completion: nil)
  }
  
  func polaroidTapped(gesture: UIGestureRecognizer) {
    print("Image Tapped \(gesture.view)")
    
    guard let polaroidView = gesture.view as? PolaroidView else {
      return
    }
    
    let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
    }
    
    let deletePhotoAction = UIAlertAction(title: "Delete photo", style: .destructive) { _ in
      self.remove(polaroidView: polaroidView)
    }
    
    let changeDateAction = UIAlertAction(title: "Change date", style: .default) { _ in
      
    }
    
    alertController.addAction(cancelAction)
    alertController.addAction(deletePhotoAction)
    alertController.addAction(changeDateAction)
    
    self.present(alertController, animated: true)
  }
  
  func remove(polaroidView: PolaroidView) {
   
    guard let entity = polaroidView.entity else {
      return
    }
    
    managedContext.delete(entity)
    appDelegate.saveContext()
    
    self.fillWithPolaroids()
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
  
  private func animatePolaroids() {
    
//    guard polaroidViews.count>1 else {
//      return
//    }
//    
//    let firstPolaroid = polaroidViews.last!
//    let secondPolaroid = polaroidViews[polaroidViews.count-2]
//    
//    let firstPolaroidCenter = firstPolaroid.center
//    let secondPolaroidCenter = secondPolaroid.center
//    
//    firstPolaroid.center.x += firstPolaroid.frame.width
//    secondPolaroid.center.x += secondPolaroid.frame.width
//    
//    UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear, animations: {
//      firstPolaroid.center = firstPolaroidCenter
//    }, completion: nil)
//    
//    UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveLinear, animations: {
//      secondPolaroid.center = secondPolaroidCenter
//    }, completion: nil)
  }
}

// MARK: - UIImagePickerControllerDelegate

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    
    if let image = info["UIImagePickerControllerEditedImage"] as? UIImage {
      
      let photo = NSEntityDescription.insertNewObject(forEntityName: "PhotoEntity", into: managedContext) as! PhotoEntity
      photo.image = UIImagePNGRepresentation(image) as NSData?
      photo.date = Date() as NSDate
      
      appDelegate.saveContext()
      status = .newPhoto
    }
    
    self.dismiss(animated: true, completion: nil)
  }
}
