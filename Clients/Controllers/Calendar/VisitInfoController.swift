//
//  VisitInfoController.swift
//  Clients
//
//  Created by Максим Голов on 17.01.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import UIKit

/// Контроллер подробной информации о записи
class VisitInfoController: UITableViewController {

    // MARK: - IBOutlets

    /// Ячейка, отображающая информацию о клиенте
    @IBOutlet weak var clientTableCell: UITableViewCell!
    /// Фотография клиента
    @IBOutlet weak var photoImageView: UIImageView!
    /// Метка имени клиента
    @IBOutlet weak var nameLabel: UILabel!
    /// Метка даты записи
    @IBOutlet weak var dateLabel: UILabel!
    /// Метка времени записи
    @IBOutlet weak var timeLabel: UILabel!
    /// Метка названия услуги
    @IBOutlet weak var serviceLabel: UILabel!
    /// Индикатор цвета услуги
    @IBOutlet weak var serviceColorView: UIView!
    /// Метка стоимости
    @IBOutlet weak var costLabel: UILabel!
    /// Метка продолжительности записи
    @IBOutlet weak var lengthLabel: UILabel!
    /// Метка заметок
    @IBOutlet weak var notesLabel: UILabel!
    /// Массив меток названий дополнительных услуг
    @IBOutlet var additionalServiceLabels: [UILabel]!

    // MARK: - Segue properties

    /// Запись
    var visit: Visit!
    // Для защиты от циклических переходов [профиль клиента -> запись -> профиль клеинта -> запись...]
    /// Определяет, возможен ли переход к профилю клиента (`true` по умолчанию)
    var canSegueToClientProfile: Bool = true

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        // Отключить возможность перехода к профилю клиента, если установлен запрет на переход
        clientTableCell.accessoryType = canSegueToClientProfile ? .disclosureIndicator : .none
        clientTableCell.isUserInteractionEnabled = canSegueToClientProfile
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Отобразить данные если запись не была удалена
        if visit.managedObjectContext != nil {
            configureVisitInfo()
        } else {
            // Закрыть экран, если запись удалена с другого экрана)
            navigationController?.popViewController(animated: true)
        }
    }

    // MARK: - Configure Subviews

    /// Заполнить контроллер данными о записи
    private func configureVisitInfo() {
        photoImageView.image = visit.client.photo ?? UIImage(named: "default_photo")
        nameLabel.text = "\(visit.client)"
        dateLabel.text = visit.date.string(style: .full)
        timeLabel.text = NSLocalizedString("FROM", comment: "с") + " \(visit.time) " +
            NSLocalizedString("TO", comment: "до") + " \(visit.time + visit.duration)"
        serviceLabel.text = visit.service.name
        serviceColorView.backgroundColor = visit.service.color
        lengthLabel.text = visit.duration.string(style: .duration)
        notesLabel.text = visit.notes

        if visit.isClientNotCome {
            costLabel.text = NSLocalizedString("CLIENT_IS_NOT_COME", comment: "Клиент не явился")
        } else if visit.isCancelled {
            costLabel.text = NSLocalizedString("VISIT_CANCELLED", comment: "Запись отменена")
        } else {
            costLabel.text = NumberFormatter.convertToCurrency(visit.cost)
        }

        for (index, service) in visit.additionalServicesSorted.enumerated() where index < 10 {
            additionalServiceLabels[index].text = service.name
        }
    }
}

// MARK: - SegueHandler

extension VisitInfoController: SegueHandler {

    enum SegueIdentifier: String {
        /// Отобразить экран редактирования записи
        case showEditVisit
        /// Отобразить профиль клиента
        case showClientProfile
    }

    // Подготовиться к переходу
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segueIdentifier(for: segue) {
        case .showEditVisit:
            guard let destination = segue.destination as? UINavigationController,
                let target = destination.topViewController as? EditVisitController else { return }
            // Отправить запись в EditVisitController
            target.visit = visit
            target.delegate = self
        case .showClientProfile:
            guard let target = segue.destination as? ClientProfileController else { return }
            // Отправить клиента в ClientProfileController
            target.client = visit.client
        }
    }
}

// MARK: - EditVisitControllerDelegate

extension VisitInfoController: EditVisitControllerDelegate {
    func editVisitController(_ viewController: EditVisitController, didFinishedEditing visit: Visit) {
        configureVisitInfo()
        tableView.reloadData()
    }
}

// MARK: - UITableViewDelegate

extension VisitInfoController {
    // Нажатие на кнопку отмены/удаления записи
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 3 {
            let actionSheet = UIAlertController.removeOrCancelVisitActionSheet(
                isVisitCancelled: visit.isCancelled,
                isClientNotCome: visit.isClientNotCome,
                removeVisitHandler: {
                    VisitRepository.remove(self.visit!)
                    CoreDataManager.shared.saveContext()
                    self.navigationController?.popViewController(animated: true)
                },
                visitCancelledByClientHandler: {
                    self.visit.isCancelled = !self.visit.isCancelled
                    CoreDataManager.shared.saveContext()
                    self.configureVisitInfo()
                },
                clientNotComeHandler: {
                    self.visit.isClientNotCome = !self.visit.isClientNotCome
                    CoreDataManager.shared.saveContext()
                    self.configureVisitInfo()
                })
            present(actionSheet, animated: true)
        }
    }

    // Подготовка к отображению заголовка секции
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        // Скрыть заголовок секции при необходимости
        if shouldHideSection(section: section),
            let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel!.textColor = .clear
        }
    }

    // Высота заголовка секции
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // Скрыть заголовок секции при необходимости
        return shouldHideSection(section: section) ? 0.1 : super.tableView(tableView, heightForHeaderInSection: section)
    }

    // Высота футера секции
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        // Скрыть футер секции при необходимости
        return shouldHideSection(section: section) ? 0.1 : super.tableView(tableView, heightForFooterInSection: section)
    }

    /**
     Определяет, требуется ли скрыть секцию с номером `section`
     - Parameter section: номер секции
     - returns: булево значение, определяющее требуется ли скрыть секцию
     
     * Секция с индеком 1 (секция дополнительных услуг) требует сокрытия,
        если в записи не обозначена ни одна дополнительная услуга;
     * Секция с индексом 2 (секция заметок) требует сокрытия, если к записи не добавлены заметки
     */
    private func shouldHideSection(section: Int) -> Bool {
        switch section {
        case 1: return visit.additionalServices.isEmpty
        case 2: return visit.notes.isEmpty
        default: return false
        }
    }
}

// MARK: - UITableViewDataSource

extension VisitInfoController {

    // Количество ячеек в секции
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 1:
            // Секция дополнительных услуг содержит до 10 ячеек, в зависимости
            // от количества доп.услуг, обозначенных в записи
            return visit.additionalServices.count
        case 2:
            // Секция заметок содержит одну ячейку с заметками при их наличии
            return visit.notes.isEmpty ? 0 : 1
        default:
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
    }
}
