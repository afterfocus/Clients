//
//  ServicesNotSpecifiedAlertController.swift
//  Clients
//
//  Created by Максим Голов on 23.02.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import UIKit

extension UIAlertController {
    
    // MARK: Alerts
    
    static var servicesNotSpecifiedAlert: UIAlertController {
        let alert = UIAlertController(
            title: NSLocalizedString("SERVICES_NOT_SPECIFIED", comment: "Не задано ни одной услуги"),
            message: NSLocalizedString("SERVICES_NOT_SPECIFIED_DETAILS", comment: "Задайте список предоставляемых услуг во вкладке «‎Настройки»‎"),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction.ok)
        return alert
    }
    
    static var maximumNumberOfAdditionalServicesSelectedAlert: UIAlertController {
        let alert = UIAlertController(
            title: nil,
            message: NSLocalizedString("MAXIMUM_NUMBER_OF_ADDITIONAL_SERVICES_IS_SELECTED",
            comment: "Выбрано максимальное количество дополнительных услуг"),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction.ok)
        return alert
    }
    
    static var clientInBlacklistAlert: UIAlertController {
        let alert = UIAlertController(
            title: NSLocalizedString("CLIENT_IN_BLACKLIST", comment: "Клиент в чёрном списке"),
            message: NSLocalizedString("CLIENT_IN_BLACKLIST_DETAILS", comment: "Запись недоступна для клиентов, находящихся в чёрном списке."),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction.ok)
        return alert
    }
    
    static var photoAccessDeniedAlert: UIAlertController {
        let alert = UIAlertController(
            title: NSLocalizedString("PHOTO_ACCESS_DENIED", comment: "Доступ к медиатеке запрещён"),
            message: NSLocalizedString("PHOTO_ACCESS_DENIED_DESCRIPTION", comment: "Вы можете разрешить доступ в настройках устройства"),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction.ok)
        return alert
    }
    
    static var clientSavingErrorAlert: UIAlertController {
        let alert = UIAlertController(
            title: NSLocalizedString("SAVE_ERROR", comment: "Ошибка сохранения"),
            message: NSLocalizedString("SAVE_CLIENT_ERROR_DESCRIPTION", comment: "Необходимо указать имя и фамилию клиента"),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction.ok)
        return alert
    }
    
    static var serviceSavingErrorAlert: UIAlertController {
        let alert = UIAlertController(
            title: NSLocalizedString("SAVE_ERROR", comment: "Ошибка сохранения"),
            message: NSLocalizedString("SAVE_SERVICE_ERROR_DESCRIPTION", comment: "Необходимо указать название и стоимость услуги"),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction.ok)
        return alert
    }
    
    static func visitSavingErrorAlert(clientNotSpecified: Bool) -> UIAlertController {
        let alert = UIAlertController(
            title: NSLocalizedString("SAVE_ERROR", comment: "Ошибка сохранения"),
            message: clientNotSpecified ?
                NSLocalizedString("SAVE_VISIT_ERROR_CLIENT_NOT_SPECIFIED", comment: "Необходимо указать клиента, для которого создается запись") :
                NSLocalizedString("SAVE_VISIT_ERROR_PRICE_NOT_SPECIFIED", comment:"Необходимо указать стоимость услуги"),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction.ok)
        return alert
    }
    
    static func confirmClientDeletionAlert(handler: @escaping () -> ()) -> UIAlertController {
        let alert = UIAlertController(
            title: NSLocalizedString("CONFIRM_DELETION", comment: "Подтвердите удаление"),
            message: NSLocalizedString("CONFIRM_CLIENT_DELETION_DESCRIPTION", comment: "\nУдаление профиля клиента повлечет за собой удаление из календаря всех его записей!"),
            preferredStyle: .alert
        )
        let confirmAction = UIAlertAction(
            title: NSLocalizedString("REMOVE_PROFILE", comment: "Удалить профиль"),
            style: .destructive) {
                action in handler()
            }
        alert.addAction(confirmAction)
        alert.addAction(UIAlertAction.cancel)
        return alert
    }
    
    static func confirmServiceDeletionAlert(handler: @escaping () -> ()) -> UIAlertController {
        let alert = UIAlertController(
            title: NSLocalizedString("CONFIRM_DELETION", comment: "Подтвердите удаление"),
            message: NSLocalizedString("CONFIRM_SERVICE_DELETION_DESCRIPTION", comment: "Удаление услуги повлечет за собой удаление всех записей, связанных с этой услугой!"),
            preferredStyle: .alert
        )
        let confirmAction = UIAlertAction(
            title: NSLocalizedString("REMOVE_SERVICE", comment: "Удалить услугу"),
            style: .destructive) {
                action in handler()
            }
        alert.addAction(confirmAction)
        alert.addAction(UIAlertAction.cancel)
        return alert
    }
    
    static func confirmAdditionalServiceDeletionAlert(handler: @escaping () -> ()) -> UIAlertController {
        let alert = UIAlertController(
            title: NSLocalizedString("CONFIRM_DELETION", comment: "Подтвердите удаление"),
            message: NSLocalizedString("CONFIRM_ADDITIONAL_SERVICE_DELETION_DESCRIPTION", comment: "Дополнительная услуга будет вычеркнута из всех записей, где она указана"),
            preferredStyle: .alert
        )
        let confirmAction = UIAlertAction(
            title: NSLocalizedString("REMOVE_ADDITIONAL_SERVICE", comment: "Удалить дополнительную услугу"),
            style: .destructive) {
                action in handler()
            }
        alert.addAction(confirmAction)
        alert.addAction(UIAlertAction.cancel)
        return alert
    }
    
    
    // MARK: - Action sheets
    
    static func blockClientActionSheet(handler: @escaping () -> ()) -> UIAlertController {
        let actionSheet = UIAlertController(
            title: nil,
            message: NSLocalizedString("BLOCK_CLIENT_WARNING", comment: "Вы не сможете создавать записи для клиентов, внесенных в список заблокированных."),
            preferredStyle: .actionSheet
        )
        let blockAction = UIAlertAction(
            title: NSLocalizedString("BLOCK_PROFILE", comment: "Заблокировать профиль"),
            style: .destructive) {
                action in handler()
            }
        actionSheet.addAction(blockAction)
        actionSheet.addAction(UIAlertAction.cancel)
        return actionSheet
    }
    
    static func archiveServiceActionSheet(handler: @escaping () -> ()) -> UIAlertController {
        let actionSheet = UIAlertController(
            title: nil,
            message: NSLocalizedString("SERVICE_ARCHIVING_ALERT", comment: "Вы не сможете создавать записи для архивированных услуг"),
            preferredStyle: .actionSheet
        )
        let archiveAction = UIAlertAction(
            title: NSLocalizedString("ARCHIVE", comment: "Архивировать"),
            style: .destructive) {
                action in handler()
            }
        actionSheet.addAction(archiveAction)
        actionSheet.addAction(UIAlertAction.cancel)
        return actionSheet
    }
}

extension UIAlertAction {
    static var ok: UIAlertAction {
        return UIAlertAction(title: "OK", style: .default)
    }
    
    static var cancel: UIAlertAction {
        return UIAlertAction(title: NSLocalizedString("CANCEL", comment: "Отменить"), style: .cancel)
    }
}
