//
//  TaskModel.swift
//  ToDo
//
//  Created by Dan Koza on 12/15/23.
//

import Foundation
import SwiftData

struct TaskModel: Equatable, Hashable {

    let id: UUID
    var text: String
    let creationDate: Date
    var isCompleted = false

    let persistentModelID: PersistentIdentifier // An identifier that maps to a PersistedTask

    init(id: UUID, text: String, creationDate: Date, isCompleted: Bool, persistentModelID: PersistentIdentifier) {
        self.id = id
        self.text = text
        self.creationDate = creationDate
        self.isCompleted = isCompleted
        self.persistentModelID = persistentModelID
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(text)
        hasher.combine(isCompleted)
    }
}
