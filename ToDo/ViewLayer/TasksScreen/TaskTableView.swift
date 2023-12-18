//
//  TaskTableView.swift
//  ToDo
//
//  Created by Dan Koza on 12/16/23.
//

import UIKit

protocol TaskTableViewDelegate: AnyObject {
    func userSwipedToDeleted(task: TaskModel)
    func userUpdated(task: TaskModel)
    func userTapped(task: TaskModel)
}

extension TasksViewController {
    class TaskTableView: UITableView, UITableViewDelegate {

        private weak var userActionDelegate: TaskTableViewDelegate?

        init(userActionDelegate: TaskTableViewDelegate) {
            self.userActionDelegate = userActionDelegate
            super.init(frame: .zero, style: .plain)
            delegate = self
            register(TaskTableViewCell.self, forCellReuseIdentifier: "TaskTableViewCell")
        }

        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

        lazy private var diffableDataSource: SwipeableDataSource = {
            return SwipeableDataSource(tableView: self, cellProvider: { [weak self] (tableView, indexPath, cellType) -> UITableViewCell? in
                switch cellType {
                    case .task(let task):
                        guard let taskCell = tableView.dequeueReusableCell(withIdentifier: "TaskTableViewCell", for: indexPath) as? TaskTableViewCell else { return nil }
                        taskCell.configure(for: task)
                        return taskCell
                }
            })
        }()

        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
            let selectedTask = diffableDataSource.snapshot().itemIdentifiers[indexPath.row]
            userActionDelegate?.userTapped(task: selectedTask.getTask)
        }

        func updateDataSource(tasks: [TaskModel], animationStyle: RowAnimation = .automatic, updateDidComplete: (() -> Void)? = nil) {
            var snapShot = NSDiffableDataSourceSnapshot<SectionType, CellType>()
            snapShot.appendSections([.tasks])
            let cellTypes: [CellType] = tasks.compactMap { taskModel in
                return .task(taskModel)
            }
            snapShot.appendItems(cellTypes, toSection: .tasks)
            diffableDataSource.defaultRowAnimation = animationStyle
            diffableDataSource.apply(snapShot, animatingDifferences: true, completion: updateDidComplete)
        }

        func insert(new task: TaskModel, updateDidComplete: (() -> Void)? = nil) {
            var taskItems = diffableDataSource.snapshot().itemIdentifiers
            guard !taskItems.isEmpty else {
                updateDataSource(tasks: [task], updateDidComplete: updateDidComplete)
                return
            }
            taskItems.insert(.task(task), at: 0)
            updateDataSource(tasks: taskItems.getTasks, updateDidComplete: updateDidComplete)
        }

        func delete(task: TaskModel, updateDidComplete: (() -> Void)? = nil) {
            var taskItems = diffableDataSource.snapshot().itemIdentifiers
            guard let indexOfTaskToDelete = taskItems.firstIndex(of: CellType.task(task)) else { return }
            taskItems.remove(at: indexOfTaskToDelete)
            updateDataSource(tasks: taskItems.getTasks, updateDidComplete: updateDidComplete)
        }

        func update(task: TaskModel, updateDidComplete: (() -> Void)? = nil) {
            var taskItems = diffableDataSource.snapshot().itemIdentifiers
            guard let taskCellToUpdateIndex = taskItems.firstIndex(where: { $0.getTask.id == task.id }) else { return  }
            taskItems[taskCellToUpdateIndex] = CellType.task(task)
            updateDataSource(tasks: taskItems.getTasks, animationStyle: .fade, updateDidComplete: updateDidComplete)
        }

        func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            var task = diffableDataSource.snapshot().itemIdentifiers[indexPath.row].getTask

            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] action, view, handler in
                self?.userActionDelegate?.userSwipedToDeleted(task: task)
                handler(true)
            }
            deleteAction.backgroundColor = .systemRed

            let completeTaskAction = UIContextualAction(style: .normal, title: task.isCompleted ? "Incomplete" : "Complete") { [weak self] action, view, handler in
                task.isCompleted = !task.isCompleted
                self?.userActionDelegate?.userUpdated(task: task)
                handler(true)
            }

            let configuration = UISwipeActionsConfiguration(actions: [deleteAction, completeTaskAction])
            configuration.performsFirstActionWithFullSwipe = true
            return configuration
        }
    }
}

extension TasksViewController.TaskTableView {
    // One small annoyance with diffable datasources... you have to subclass UITableViewDiffableDataSource to enable swiping of cells
    // https://stackoverflow.com/a/58116755
    private class SwipeableDataSource: UITableViewDiffableDataSource<SectionType, CellType> {
        override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
            return true
        }
    }

    private enum SectionType: Hashable {
        case tasks
    }

    fileprivate enum CellType: Hashable {
        case task(TaskModel)

        var getTask: TaskModel {
            switch self {
                case .task(let task):
                    return task
            }
        }
    }
}

private extension Array where Element == TasksViewController.TaskTableView.CellType {
    var getTasks: [TaskModel] {
        return compactMap { $0.getTask }
    }
}
