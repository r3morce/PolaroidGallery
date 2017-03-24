//
//  PhotoEntity+CoreDataProperties.swift
//  PolaroidGallery
//
//  Created by mathias@privat on 24.03.17.
//  Copyright © 2017 mathias. All rights reserved.
//

import Foundation
import CoreData


extension PhotoEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PhotoEntity> {
        return NSFetchRequest<PhotoEntity>(entityName: "PhotoEntity");
    }

    @NSManaged public var date: NSDate?
    @NSManaged public var image: NSData?

}
