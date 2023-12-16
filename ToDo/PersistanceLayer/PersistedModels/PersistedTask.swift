//
//  PersistedTask.swift
//  ToDo
//
//  Created by Dan Koza on 12/13/23.
//

import Foundation
import SwiftData

@Model class PersistedTask {

    @Attribute(.unique) let id: UUID
    var text: String
    let creationDate: Date
    var isCompleted = false

    init(text: String = "") {
        id = UUID()
        self.text = text
        let now = Date.now
        creationDate = now
    }
}

extension PersistedTask {
    var toTaskModel: TaskModel {
        return TaskModel(id: id,
                         text: text,
                         creationDate: creationDate,
                         isCompleted: isCompleted, 
                         persistentModelID: persistentModelID)
    }
}

extension Array where Element == PersistedTask {
    var toTaskModels: [TaskModel] {
        return map { $0.toTaskModel }
    }
}
