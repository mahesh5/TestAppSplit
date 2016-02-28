//
//  Entity+CoreDataProperties.swift
//  UISplitViewControllerExample
//
//  Created by Admin on 26/02/16.
//  Copyright © 2016 tvsi. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Entity {

    @NSManaged var full_name: String?
    @NSManaged var language: String?
    @NSManaged var name: String?
    @NSManaged var default_branch: String?

}
