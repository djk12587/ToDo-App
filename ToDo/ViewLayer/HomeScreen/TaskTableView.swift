//
//  TaskTableView.swift
//  ToDo
//
//  Created by Dan Koza on 12/16/23.
//

import UIKit

protocol TaskTableViewDelegate: AnyObject {
    func userSwipedToDeleted(task: TaskModel)
}

extension HomeViewController {
    class TaskTableView: UITableView, UITableViewDelegate {

        private weak var userActionDelegate: TaskTableViewDelegate?

        init(userActionDelegate: TaskTableViewDelegate) {
            self.userActionDelegate = userActionDelegate
            super.init(frame: .zero, style: .plain)
            delegate = self
        }

        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

        lazy private var diffableDataSource: SwipeableDataSource = {
            return SwipeableDataSource(tableView: self, cellProvider: { [weak self] (tableView, indexPath, cellType) -> UITableViewCell? in
                switch cellType {
                    case .task(let task):
                        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
                        cell.textLabel?.text = task.text
                        return cell
                }
            })
        }()

        func updateDataSource(tasks: [TaskModel], animationsDidComplete: (() -> Void)? = nil) {
            var snapShot = NSDiffableDataSourceSnapshot<SectionType, CellType>()
            snapShot.appendSections([.tasks])
            let cellTypes: [CellType] = tasks.compactMap { taskModel in
                return .task(taskModel)
            }
            snapShot.appendItems(cellTypes, toSection: .tasks)
            diffableDataSource.apply(snapShot, animatingDifferences: true, completion: animationsDidComplete)
        }

        func insert(new task: TaskModel, animationsDidComplete: (() -> Void)? = nil) {
            var taskItems = diffableDataSource.snapshot().itemIdentifiers
            guard !taskItems.isEmpty else {
                updateDataSource(tasks: [task], animationsDidComplete: animationsDidComplete)
                return
            }
            taskItems.insert(.task(task), at: 0)
            updateDataSource(tasks: taskItems.getTasks, animationsDidComplete: animationsDidComplete)
        }

        func delete(task: TaskModel, animationsDidComplete: (() -> Void)? = nil) {
            var taskItems = diffableDataSource.snapshot().itemIdentifiers
            guard let indexToRemove = taskItems.firstIndex(of: CellType.task(task)) else { return }
            taskItems.remove(at: indexToRemove)
            updateDataSource(tasks: taskItems.getTasks, animationsDidComplete: animationsDidComplete)
        }

        func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] action, view, handler in
                guard let taskToDelete = self?.diffableDataSource.snapshot().itemIdentifiers[indexPath.row].getTask else { handler(false); return }

                self?.delete(task: taskToDelete, animationsDidComplete: {
                    self?.userActionDelegate?.userSwipedToDeleted(task: taskToDelete)
                    handler(true)
                })
            }
            deleteAction.backgroundColor = .systemRed
            let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
            configuration.performsFirstActionWithFullSwipe = true
            return configuration
        }
    }
}

extension HomeViewController.TaskTableView {
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

private extension Array where Element == HomeViewController.TaskTableView.CellType {
    var getTasks: [TaskModel] {
        return compactMap { $0.getTask }
    }
}
