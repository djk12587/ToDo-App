//
//  TaskModel.swift
//  ToDo
//
//  Created by Dan Koza on 12/15/23.
//

import Foundation
import SwiftData

struct TaskModel: Sendable {
    
    let id: UUID
    var text: String
    let creationDate: Date
    var isCompleted = false

    let persistentModelID: PersistentIdentifier // An identifier that maps to a PersistantTask

    init(id: UUID, text: String, creationDate: Date, isCompleted: Bool, persistentModelID: PersistentIdentifier) {
        self.id = id
        self.text = text
        self.creationDate = creationDate
        self.isCompleted = isCompleted
        self.persistentModelID = persistentModelID
    }
}
