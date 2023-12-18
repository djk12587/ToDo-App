//
//  PersistedTaskService.swift
//  ToDo
//
//  Created by Dan Koza on 12/15/23.
//

import Foundation
import SwiftData

protocol PersistedTaskServiceLayer {
    func getTasks() async throws -> [TaskModel]
    func create(text: String) async throws -> TaskModel
    func update(taskModel: TaskModel) async throws
    func delete(taskModel: TaskModel) async throws
    init() async throws
}

actor PersistedTaskService: ModelActor, PersistedTaskServiceLayer {

    let modelContainer: ModelContainer
    let modelExecutor: ModelExecutor

    init() async throws {
        let modelContainer = try ModelContainer(for: PersistedTask.self)
        self.modelContainer = modelContainer
        self.modelExecutor = await Task.detached {
            let context = ModelContext(modelContainer) // Creating the ModelContext off the main thread ensures CRUD operations run on a background thread
            return DefaultSerialModelExecutor(modelContext: context)
        }.value
    }

    func getTasks() async throws -> [TaskModel] {
        let fetchDescription = FetchDescriptor<PersistedTask>(sortBy: [SortDescriptor(\.creationDate, order: .reverse)])
        return try modelContext.fetch(fetchDescription).toTaskModels
    }

    func create(text: String) async throws -> TaskModel {
        let newTask = PersistedTask(text: text)
        modelContext.insert(newTask)
        try modelContext.save()
        return newTask.toTaskModel
    }

    func delete(taskModel: TaskModel) async throws {
        guard let persistantTaskToDelete = self[taskModel.persistentModelID, as: PersistedTask.self] else { throw Error.persistantTaskDoesNotExist }
        modelContext.delete(persistantTaskToDelete)
        try modelContext.save()
    }

    func update(taskModel: TaskModel) async throws {
        guard let persistantTaskToUpdate = self[taskModel.persistentModelID, as: PersistedTask.self] else { throw Error.persistantTaskDoesNotExist }
        persistantTaskToUpdate.text = taskModel.text
        persistantTaskToUpdate.isCompleted = taskModel.isCompleted
        try modelContext.save()
    }
}

extension PersistedTaskService {
    enum Error: Swift.Error {
        case persistantTaskDoesNotExist
    }
}
