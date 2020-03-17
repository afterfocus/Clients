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
    
    /// Создает экземпляр `UIAlertController` вида `.alert` с заданным заголовком `title`,
    /// сообщением `message` и единственной кнопкой `OK`
    class func alertWithOkAction(title: String?, message: String?) -> UIAlertController {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction.ok)
        return alert
    }
    
    /**
     Создает экземпляр `UIAlertController` заданного вида `preferredStyle` c заголовком `title`,
     сообщением `message` и кнопками подтверждения и отмены действия
     - Parameters:
        - style: Предпочитаемый стиль
        - title: Заголовок
        - message: Сообщение
        - confirmActionTitle: Заголовок кнопки подтверждения действия
        - handler: Замыкание, выполняемое при подтверждении
    */
    class func confirmationAlertController(preferredStyle style: UIAlertController.Style,
                                           title: String?,
                                           message: String?,
                                           confirmActionTitle: String?,
                                           handler: @escaping () -> Void) -> UIAlertController {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: style)
        let confirmAction = UIAlertAction(title: confirmActionTitle,
                                          style: .destructive,
                                          handler: { _ in handler() })
        alert.addAction(confirmAction)
        alert.addAction(UIAlertAction.cancel)
        return alert
    }
    
    class var servicesNotSpecifiedAlert: UIAlertController {
        return alertWithOkAction(
            title: NSLocalizedString("SERVICES_NOT_SPECIFIED", comment: "Не задано ни одной услуги"),
            message: NSLocalizedString("SERVICES_NOT_SPECIFIED_DETAILS",
                                       comment: "Задайте список предоставляемых услуг во вкладке «‎Настройки»‎"))
    }

    class var maximumAdditionalServicesSelectedAlert: UIAlertController {
        return alertWithOkAction(
            title: nil,
            message: NSLocalizedString("MAXIMUM_NUMBER_OF_ADDITIONAL_SERVICES_IS_SELECTED",
                                       comment: "Выбрано максимальное количество дополнительных услуг"))
    }

    class var clientInBlacklistAlert: UIAlertController {
        return alertWithOkAction(
            title: NSLocalizedString("CLIENT_IN_BLACKLIST", comment: "Клиент в чёрном списке"),
            message: NSLocalizedString("CLIENT_IN_BLACKLIST_DETAILS",
                                       comment: "Запись недоступна для клиентов, находящихся в чёрном списке."))
    }

    class var photoAccessDeniedAlert: UIAlertController {
        return alertWithOkAction(
            title: NSLocalizedString("PHOTO_ACCESS_DENIED", comment: "Доступ к медиатеке запрещён"),
            message: NSLocalizedString("PHOTO_ACCESS_DENIED_DESCRIPTION",
                                       comment: "Вы можете разрешить доступ в настройках устройства"))
    }

    class var clientSavingErrorAlert: UIAlertController {
        return alertWithOkAction(
            title: NSLocalizedString("SAVE_ERROR", comment: "Ошибка сохранения"),
            message: NSLocalizedString("SAVE_CLIENT_ERROR_DESCRIPTION",
                                       comment: "Необходимо указать имя и фамилию клиента"))
    }

    class var serviceSavingErrorAlert: UIAlertController {
        return alertWithOkAction(
            title: NSLocalizedString("SAVE_ERROR", comment: "Ошибка сохранения"),
            message: NSLocalizedString("SAVE_SERVICE_ERROR_DESCRIPTION",
                                       comment: "Необходимо указать название и стоимость услуги"))
    }

    class func visitSavingErrorAlert(clientNotSpecified: Bool) -> UIAlertController {
        let message = clientNotSpecified ?
            NSLocalizedString("SAVE_VISIT_ERROR_CLIENT_NOT_SPECIFIED",
                              comment: "Необходимо указать клиента, для которого создается запись") :
            NSLocalizedString("SAVE_VISIT_ERROR_PRICE_NOT_SPECIFIED",
                              comment: "Необходимо указать стоимость услуги")
        return alertWithOkAction(
            title: NSLocalizedString("SAVE_ERROR", comment: "Ошибка сохранения"),
            message: message)
    }

    class func confirmClientDeletionAlert(handler: @escaping () -> Void) -> UIAlertController {
        return confirmationAlertController(
            preferredStyle: .alert,
            title: NSLocalizedString("CONFIRM_DELETION", comment: "Подтвердите удаление"),
            message: NSLocalizedString("CONFIRM_CLIENT_DELETION_DESCRIPTION",
                                       comment: "Удаление профиля клиента повлечет за собой удаление из календаря всех его записей!"),
            confirmActionTitle: NSLocalizedString("REMOVE_PROFILE", comment: "Удалить профиль"),
            handler: handler)
    }

    class func confirmServiceDeletionAlert(handler: @escaping () -> Void) -> UIAlertController {
        return confirmationAlertController(
            preferredStyle: .alert,
            title: NSLocalizedString("CONFIRM_DELETION", comment: "Подтвердите удаление"),
            message: NSLocalizedString("CONFIRM_SERVICE_DELETION_DESCRIPTION",
                                       comment: "Удаление услуги повлечет за собой удаление всех записей, связанных с этой услугой!"),
            confirmActionTitle: NSLocalizedString("REMOVE_SERVICE", comment: "Удалить услугу"),
            handler: handler)
    }

    class func confirmAdditionalServiceDeletionAlert(handler: @escaping () -> Void) -> UIAlertController {
        return confirmationAlertController(
            preferredStyle: .alert,
            title: NSLocalizedString("CONFIRM_DELETION", comment: "Подтвердите удаление"),
            message: NSLocalizedString("CONFIRM_ADDITIONAL_SERVICE_DELETION_DESCRIPTION", comment: "Дополнительная услуга будет вычеркнута из всех записей, где она указана"),
            confirmActionTitle: NSLocalizedString("REMOVE_ADDITIONAL_SERVICE", comment: "Удалить дополнительную услугу"),
            handler: handler)
    }
    
    // MARK: - Action sheets

    class func blockClientActionSheet(handler: @escaping () -> Void) -> UIAlertController {
        return confirmationAlertController(
            preferredStyle: .actionSheet,
            title: nil,
            message: NSLocalizedString("BLOCK_CLIENT_WARNING",
                                       comment: "Вы не сможете создавать записи для клиентов, внесенных в список заблокированных."),
            confirmActionTitle: NSLocalizedString("BLOCK_PROFILE", comment: "Заблокировать профиль"),
            handler: handler)
    }

    class func archiveServiceActionSheet(handler: @escaping () -> Void) -> UIAlertController {
        return confirmationAlertController(
            preferredStyle: .actionSheet,
            title: nil,
            message: NSLocalizedString("SERVICE_ARCHIVING_ALERT",
                                       comment: "Вы не сможете создавать записи для архивированных услуг"),
            confirmActionTitle: NSLocalizedString("ARCHIVE", comment: "Архивировать"),
            handler: handler)
    }
    
    class func updateIsWeekendActionSheet(currentValue isWeekend: Bool, handler: @escaping () -> Void) -> UIAlertController {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let action = UIAlertAction(
            title: isWeekend ?
                NSLocalizedString("CANCEL_A_DAY_OFF", comment: "Удалить выходной") :
                NSLocalizedString("MAKE_IT_A_DAY_OFF", comment: "Сделать выходным днём"),
            style: isWeekend ? .destructive : .default,
            handler: { _ in handler() })
        actionSheet.addAction(action)
        actionSheet.addAction(UIAlertAction.cancel)
        return actionSheet
    }

    class func removeOrCancelVisitActionSheet(isVisitCancelled: Bool,
                                               isClientNotCome: Bool,
                                               removeVisitHandler: @escaping () -> Void,
                                               visitCancelledByClientHandler: @escaping () -> Void,
                                               clientNotComeHandler: @escaping () -> Void) -> UIAlertController {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(
            title: NSLocalizedString("REMOVE_VISIT", comment: "Удалить запись"),
            style: .destructive) { _ in
                removeVisitHandler()
            }
        let visitCancelledAction = UIAlertAction(
            title: isVisitCancelled ?
                NSLocalizedString("VISIT_NOT_CANCELLED_BY_CLIENT_BUTTON", comment: "Клиент не отменил запись") :
                NSLocalizedString("VISIT_CANCELLED_BY_CLIENT", comment: "Клиент отменил запись"),
            style: .default) { _ in
                visitCancelledByClientHandler()
            }
        let notComeAction = UIAlertAction(
            title: isClientNotCome ?
                NSLocalizedString("CLIENT_IS_COME_BUTTON", comment: "Клиент явился по записи") :
                NSLocalizedString("CLIENT_IS_NOT_COME_BUTTON", comment: "Клиент не явился по записи"),
            style: .default) { _ in
                clientNotComeHandler()
            }
        actionSheet.addAction(notComeAction)
        actionSheet.addAction(visitCancelledAction)
        actionSheet.addAction(deleteAction)
        actionSheet.addAction(UIAlertAction.cancel)
        return actionSheet
    }
    
    class func pickOrRemovePhotoActionSheet(pickPhotoHandler: @escaping () -> Void,
                                             removePhotoHandler: @escaping () -> Void) -> UIAlertController {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let pickAction = UIAlertAction(
            title: NSLocalizedString("PICK_PHOTO", comment: "Выбрать фото"),
            style: .default) { _ in
                pickPhotoHandler()
            }
        let deleteAction = UIAlertAction(
            title: NSLocalizedString("REMOVE_PHOTO", comment: "Удалить фото"),
            style: .default) { _ in
                removePhotoHandler()
            }
        actionSheet.addAction(pickAction)
        actionSheet.addAction(deleteAction)
        actionSheet.addAction(UIAlertAction.cancel)
        return actionSheet
    }
}

extension UIAlertAction {
    class var ok: UIAlertAction {
        return UIAlertAction(title: "OK", style: .default)
    }

    class var cancel: UIAlertAction {
        return UIAlertAction(title: NSLocalizedString("CANCEL", comment: "Отменить"), style: .cancel)
    }
}
