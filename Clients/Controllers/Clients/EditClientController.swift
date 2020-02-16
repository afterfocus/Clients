//
//  EditClientController.swift
//  Clients
//
//  Created by Максим Голов on 16.01.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import UIKit
import Photos

class EditClientController: UITableViewController, UINavigationControllerDelegate {
    
    // MARK: - IBOutlets
    
    /// Фотография клиента
    @IBOutlet weak var photoImageView: UIImageView!
    /// Кнопка выбора фотографии
    @IBOutlet weak var pickPhotoButton: UIButton!
    /// Кнопка смены/удаления фотографии
    @IBOutlet weak var changePhotoButton: UIButton!
    /// Поле имени
    @IBOutlet weak var nameTextField: UITextField!
    /// Поле фамилии
    @IBOutlet weak var surnameTextField: UITextField!
    /// Поле номера телефона
    @IBOutlet weak var phoneTextField: UITextField!
    /// Поле ссылки на профиль ВКонтакте
    @IBOutlet weak var vkTextField: UITextField!
    /// Поле заметок
    @IBOutlet weak var notesTextField: UITextField!
    /// Метка управления черным списком
    @IBOutlet weak var blacklistLabel: UILabel!
    
    /// Иконка для `nameTextField`
    @IBOutlet weak var nameIcon: UIImageView!
    /// Иконка для `surnameTextField`
    @IBOutlet weak var surnameIcon: UIImageView!
    /// Иконка для `phoneTextField`
    @IBOutlet weak var phoneIcon: UIImageView!
    /// Иконка для `vkTextField`
    @IBOutlet weak var vkIcon: UIImageView!
    /// Иконка для `notesTextField`
    @IBOutlet weak var notesIcon: UIImageView!
    
    
    // MARK: - Segue properties
    
    /// Идентификатор клиента
    var client: Client?
    
    
    // MARK: - Private properties
    
    /// Определяет, выбрана ли фотография
    private var isPhotoPicked = false {
        /// Если выбрана, прячет кнопку выбора и отображает кнопку смены/удаления фотографии
        didSet {
            pickPhotoButton.isHidden = isPhotoPicked
            changePhotoButton.isHidden = !isPhotoPicked
        }
    }
    /// Определяет, находится ли клиент в черном списке
    private var isBlocked = false {
        /// При изменении обновляет метку кнопки черного списка
        didSet {
            blacklistLabel.text = isBlocked ? NSLocalizedString("UNBLOCK_CLIENT", comment: "Извлечь из чёрного списка") : NSLocalizedString("BLOCK_CLIENT", comment: "Внести в чёрный список")
        }
    }
    
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        // Добавление распознавателя изменения текста в поле номера телефона
        phoneTextField.addTarget(self, action: #selector(self.phoneTextFieldDidChange), for: .editingChanged)
        // Закрывать клавиатуру при нажатии вне полей
        hideKeyboardWhenTappedAround()
        // Заполнить поля данными, если контроллер не в режиме создания нового клиента
        if let client = client {
            configureClientInfo(client)
        }
    }
    
    
    // MARK: - Configure Subviews
    
    /// Заполняет поля данными клиента `client`
    private func configureClientInfo(_ client: Client) {
        // Отобразить фотографию при наличии
        if let photo = client.photo {
            photoImageView.image = photo
            isPhotoPicked = true
        }
        // Заполнить поля
        nameTextField.text = client.name
        surnameTextField.text = client.surname
        phoneTextField.text = client.phonenumber.formattedPhoneNumber
        vkTextField.text = client.vk
        notesTextField.text = client.notes
        isBlocked = client.isBlocked
    }
    
    /**
     Изменить цвет  иконки, связанной с `textField` на новое значение `color`
     - Parameter textField: поле, цвет иконки которого требуется обновить
     - Parameter color: новое значение цвета заливки иконки
     */
    private func setIconTint(for textField: UITextField, color: UIColor) {
        /// Иконка, связанная с `textField`
        var icon: UIImageView
        switch textField {
        case nameTextField: icon = nameIcon
        case surnameTextField: icon = surnameIcon
        case phoneTextField: icon = phoneIcon
        case vkTextField: icon = vkIcon
        case notesTextField: icon = notesIcon
        default: fatalError("Cannot find the icon associated with field \(textField)")
        }
        UIView.animate(withDuration: 0.2) {
            icon.tintColor = color
        }
    }
    

    // MARK: - IBActions
    
    /// Нажтие на кнопку сохранения изменений
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        // Если поле имени или фамилии не заполнено, вывести сообщение об ошибке
        if !surnameTextField.hasText || !nameTextField.hasText {
            let alert = UIAlertController(
                title: NSLocalizedString("SAVE_ERROR", comment: "Ошибка сохранения"),
                message: NSLocalizedString("SAVE_CLIENT_ERROR_DESCRIPTION", comment: "Необходимо указать имя и фамилию клиента"),
                preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        } else {
            /// Обновленный профиль клиента
            if let client = client {
                client.photo = isPhotoPicked ? photoImageView.image! : nil
                client.surname = surnameTextField.text!
                client.name = nameTextField.text!
                client.phonenumber = phoneTextField.text!.replacingOccurrences( of:"[^0-9]", with: "", options: .regularExpression)
                client.vk = vkTextField.text!
                client.notes = notesTextField.text!
                client.isBlocked = isBlocked
            } else {
                _ = Client(
                    photo: isPhotoPicked ? photoImageView.image! : nil,
                    surname: surnameTextField.text!,
                    name: nameTextField.text!,
                    phonenumber: phoneTextField.text!.replacingOccurrences( of:"[^0-9]", with: "", options: .regularExpression),
                    vk: vkTextField.text!,
                    notes: notesTextField.text!,
                    isBlocked: isBlocked
                )
            }
            CoreDataManager.instance.saveContext()
            // Вернуться к списку клиентов или к экрану профиля клиента
            performSegue(withIdentifier: client == nil ? .unwindFromAddClientToClientsTable : .unwindFromEditClientToClientProfile, sender: sender)
        }
    }
    
    /// Нажатие на кнопку отмены
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true)
    }
    
    
    // MARK: Photo Selection
    
    /// Нажатие на кнопку выбора фотографии
    @IBAction func pickPhotoButtonPressed(_ sender: Any) {
        // Проверить наличие доступа к медиатеке
        switch PHPhotoLibrary.authorizationStatus() {
            // Если доступ разрешен, вызвать UIImagePickerController
        case .authorized:
            showImagePicker()
            // Если доступ не определен, запросить доступ
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization {
                // На основании ответа пользователя вызвать UIImagePickerController или отобразить сообщение о запрете доступа
                $0 == .authorized ? self.showImagePicker() : self.showAccessDeniedAlert()
            }
            // Если доступ запрещен, отобразить сообщение о запрете доступа
        case .denied, .restricted: showAccessDeniedAlert()
        @unknown default: fatalError()
        }
    }
    
    /// Нажатие на кнопку смены/удаления фотографии
    @IBAction func changePhotoButtonPressed(_ sender: Any) {
        // Отобразить меню с возможностью выбора новой фотографии и удаления существующей
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let pickAction = UIAlertAction(
            title: NSLocalizedString("PICK_PHOTO", comment: "Выбрать фото"),
            style: .default) {
                action in
                // Проверить наличие доступа к медиатеке и отобразить UIImagePickerController или сообщение о запрете доступа
                self.pickPhotoButtonPressed(sender)
        }
        let deleteAction = UIAlertAction(
            title: NSLocalizedString("REMOVE_PHOTO", comment: "Удалить фото"),
            style: .default) {
                action in
                // Заменить фотографию заглушкой
                self.photoImageView.image = UIImage(named:"default_photo")
                self.isPhotoPicked = false
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("CANCEL", comment: "Отменить"), style: .cancel)
        actionSheet.addAction(pickAction)
        actionSheet.addAction(deleteAction)
        actionSheet.addAction(cancelAction)
        present(actionSheet, animated: true)
    }
    
    /// Отображает UIImagePickerController
    private func showImagePicker() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .photoLibrary;
            picker.allowsEditing = true
            self.present(picker, animated: true)
        }
    }
    
    /// Отображает сообщение о запрете доступа к медиатеке
    private func showAccessDeniedAlert() {
        let alert = UIAlertController(
            title: NSLocalizedString("PHOTO_ACCESS_DENIED", comment: "Доступ к медиатеке запрещён"),
            message: NSLocalizedString("PHOTO_ACCESS_DENIED_DESCRIPTION", comment: "Вы можете разрешить доступ в настройках устройства"),
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
}


// MARK: - UITextFieldDelegate

extension EditClientController: UITextFieldDelegate {
    /// Пользователь начал редактирование текста
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Выделить иконку, связанную с активным textField
        setIconTint(for: textField, color: .systemBlue)
    }
    
    /// Пользователь завершил редактирование текста
    func textFieldDidEndEditing(_ textField: UITextField) {
        // Снять выделение с иконки, связанной с textField
        setIconTint(for: textField, color: .gray)
    }
    
    /// Нажата кнопка Return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Закрыть клавиатуру
        view.endEditing(true)
        return true
    }
    
    /// Пользователь изменил текст в поле номера телефона
    @objc func phoneTextFieldDidChange(sender: UITextField) {
        // Форматировать номер телефона
        sender.text = sender.text?.formattedPhoneNumber
    }
}


// MARK: - UIImagePickerControllerDelegate

extension EditClientController: UIImagePickerControllerDelegate {
    /// Пользователь выбрал фотографию в UIImagePickerController
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Извлечь выбранную фотографию
        let image = info[.editedImage] as! UIImage
        // Масштабировать фотографию до 500х500 px
        photoImageView.image = image.resize(toWidthAndHeight: 500)
        isPhotoPicked = true
        self.dismiss(animated: true)
    }
}


// MARK: - SegueHandler

extension EditClientController: SegueHandler {
    
    enum SegueIdentifier: String {
        /// Вернуться к профилю клиента
        case unwindFromEditClientToClientProfile
        /// Вернуться к списку клиентов
        case unwindFromAddClientToClientsTable
    }
    
    /// Подготовиться к переходу
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segueIdentifier(for: segue) {
        case .unwindFromEditClientToClientProfile: break
        case .unwindFromAddClientToClientsTable: break
        }
    }
}


// MARK: - UITableViewDelegate

extension EditClientController {
    // Нажатие на кнопку черного списка или удаления
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            tableView.deselectRow(at: indexPath, animated: true)
            let cancelAction = UIAlertAction(title: NSLocalizedString("CANCEL", comment: "Отменить"), style: .cancel)
            
            // Нажата кнопка черного списка
            if indexPath.row == 0 {
                if !isBlocked {
                    let actionSheet = UIAlertController(
                        title: nil,
                        message: NSLocalizedString("BLOCK_CLIENT_WARNING", comment: "Вы не сможете создавать записи для клиентов, внесенных в список заблокированных."),
                        preferredStyle: .actionSheet)
                    let blockAction = UIAlertAction(
                        title: NSLocalizedString("BLOCK_PROFILE", comment: "Заблокировать профиль"),
                        style: .destructive) {
                            action in self.isBlocked = true
                    }
                    let cancel = UIAlertAction(title: NSLocalizedString("CANCEL", comment: "Отменить"), style: .cancel)
                    actionSheet.addAction(blockAction)
                    actionSheet.addAction(cancel)
                    present(actionSheet, animated: true)
                }
                else {
                    isBlocked = false
                }
            }
            // Нажата кнопка удаления
            else {
                let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                let deleteAction = UIAlertAction(
                    title: NSLocalizedString("REMOVE_PROFILE", comment: "Удалить профиль"),
                    style: .destructive) {
                        action in
                        let comfirmSheet = UIAlertController(
                            title: NSLocalizedString("CONFIRM_DELETION", comment: "Подтвердите удаление"),
                            message: NSLocalizedString("CONFIRM_CLIENT_DELETION_DESCRIPTION", comment: "\nУдаление профиля клиента повлечет за собой удаление из календаря всех его записей!"),
                            preferredStyle: .alert)
                        let comfirm = UIAlertAction(
                            title: NSLocalizedString("REMOVE_PROFILE", comment: "Удалить профиль"),
                            style: .destructive) {
                                action in
                                ClientRepository.remove(self.client!)
                                CoreDataManager.instance.saveContext()
                                self.performSegue(withIdentifier: .unwindFromEditClientToClientProfile, sender: self)
                            }
                         let cancel = UIAlertAction(title: NSLocalizedString("CANCEL", comment: "Отменить"), style: .cancel)
                        comfirmSheet.addAction(comfirm)
                        comfirmSheet.addAction(cancel)
                        self.present(comfirmSheet, animated: true)
                }
                actionSheet.addAction(deleteAction)
                actionSheet.addAction(cancelAction)
                present(actionSheet, animated: true)
            }
        }
    }
}


// MARK: - UITableViewDataSource

extension EditClientController {
    // Количество секций в списке (третья секция содержит кнопки черного списка и удаления)
    override func numberOfSections(in tableView: UITableView) -> Int {
        return client == nil ? 2 : 3
    }
}
