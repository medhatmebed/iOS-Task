//
//  Product+CoreDataProperties.swift
//  iOS Task
//
//  Created by Medhat Mebed on 2/17/19.
//  Copyright © 2019 Medhat Mebed. All rights reserved.
//
//

import Foundation
import CoreData


extension Product {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Product> {
        return NSFetchRequest<Product>(entityName: "Product")
    }

    @NSManaged public var name: String?
    @NSManaged public var price: Double
    @NSManaged public var productDescription: String?
    @NSManaged public var imageUrl: String?
    @NSManaged public var id: Int16

}
