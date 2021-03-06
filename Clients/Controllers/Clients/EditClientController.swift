//
//  EditClientController.swift
//  Clients
//
//  Created by Максим Голов on 16.01.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import UIKit
import Photos

// MARK: - EditClientControllerDelegate

protocol EditClientControllerDelegate: class {
    func editClientController(_ viewController: EditClientController, didFinishedEditing client: Client)
    func editClientController(_ viewController: EditClientController, hasDeleted client: Client)
}

extension EditClientControllerDelegate {
    func editClientController(_ viewController: EditClientController, hasDeleted client: Client) { }
}

// MARK: - EditClientController

/// Контроллер редактирования клиента
class EditClientController: UITableViewController, UINavigationControllerDelegate {

    // MARK: IBOutlets

    /// Фотография клиента
    @IBOutlet weak var photoImageView: UIImageView!
    /// Кнопка выбора фотографии
    @IBOutlet weak var pickPhotoButton: UIButton!
    /// Кнопка смены/удаления фотографии
    @IBOutlet weak var changePhotoButton: UIButton!
    /// Поле имени
    @IBOutlet weak var nameTextField: TextFieldWithIcon!
    /// Поле фамилии
    @IBOutlet weak var surnameTextField: TextFieldWithIcon!
    /// Поле номера телефона
    @IBOutlet weak var phoneTextField: TextFieldWithIcon!
    /// Поле ссылки на профиль ВКонтакте
    @IBOutlet weak var vkTextField: TextFieldWithIcon!
    /// Поле заметок
    @IBOutlet weak var notesTextField: TextFieldWithIcon!
    /// Метка кнопки черного списка
    @IBOutlet weak var blacklistLabel: UILabel!
    
    // MARK: - Segue properties

    /// Редактируемый клиент
    var client: Client?
    weak var delegate: EditClientControllerDelegate?

    // MARK: - Private properties
    
    /// Определяет, выбрана ли фотография
    private var isPhotoPicked = false {
        didSet {
            pickPhotoButton.isHidden = isPhotoPicked
            changePhotoButton.isHidden = !isPhotoPicked
        }
    }
    /// Определяет, находится ли клиент в черном списке
    private var isBlocked = false {
        /// При изменении обновляет метку кнопки черного списка
        didSet {
            blacklistLabel.text = isBlocked ?
                NSLocalizedString("UNBLOCK_CLIENT", comment: "Извлечь из чёрного списка") :
                NSLocalizedString("BLOCK_CLIENT", comment: "Внести в чёрный список")
        }
    }

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
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
        if let photoData = client.photoData {
            photoImageView.image = UIImage(data: photoData)
            isPhotoPicked = true
        }
        nameTextField.text = client.name
        surnameTextField.text = client.surname
        phoneTextField.text = client.phonenumber.formattedPhoneNumber
        vkTextField.text = client.vk
        notesTextField.text = client.notes
        isBlocked = client.isBlocked
    }

    // MARK: - IBActions

    /// Нажтие на кнопку сохранения изменений
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        // Если поле имени или фамилии не заполнено, вывести сообщение об ошибке
        if !surnameTextField.hasText || !nameTextField.hasText {
            present(UIAlertController.clientSavingErrorAlert, animated: true)
        } else {
            /// Обновить существующий профиль клиента или создать новый
            let client = self.client ?? Client(context: CoreDataManager.shared.managedContext)
            
            client.photoData = isPhotoPicked ? photoImageView.image?.pngData() : nil
            client.surname = surnameTextField.text!
            client.name = nameTextField.text!
            client.phonenumber = phoneTextField.text!.cleanPhoneNumber
            client.vk = vkTextField.text!
            client.notes = notesTextField.text!
            client.isBlocked = isBlocked
            
            CoreDataManager.shared.saveContext()
            delegate?.editClientController(self, didFinishedEditing: client)
            dismiss(animated: true)
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
        case .authorized:
            showImagePicker()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization {
                if $0 == .authorized {
                    DispatchQueue.main.async { self.showImagePicker() }
                } else {
                    self.showAccessDeniedAlert()
                }
            }
        case .denied, .restricted:
            showAccessDeniedAlert()
        @unknown default: fatalError()
        }
    }

    /// Нажатие на кнопку смены/удаления фотографии
    @IBAction func changePhotoButtonPressed(_ sender: Any) {
        // Отобразить меню с возможностью выбора новой фотографии и удаления существующей
        let actionSheet = UIAlertController.pickOrRemovePhotoActionSheet(
            pickPhotoHandler: {
                self.pickPhotoButtonPressed(sender)
            },
            removePhotoHandler: {
                // Заменить фотографию заглушкой
                self.photoImageView.image = UIImage(named: "default_photo")
                self.isPhotoPicked = false
            })
        present(actionSheet, animated: true)
    }

    /// Отображает UIImagePickerController
    private func showImagePicker() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .photoLibrary
            picker.allowsEditing = true
            present(picker, animated: true)
        }
    }

    /// Отображает сообщение о запрете доступа к медиатеке
    private func showAccessDeniedAlert() {
        present(UIAlertController.photoAccessDeniedAlert, animated: true)
    }
}

// MARK: - UITextFieldDelegate

extension EditClientController: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let textField = textField as? TextFieldWithIcon else { return }
        textField.isIconHighlighted = true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let textField = textField as? TextFieldWithIcon else { return }
        textField.isIconHighlighted = false
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Закрыть клавиатуру
        view.endEditing(true)
        return true
    }

    @objc func phoneTextFieldDidChange(sender: UITextField) {
        // Форматировать номер телефона
        sender.text = sender.text?.formattedPhoneNumber
    }
}

// MARK: - UIImagePickerControllerDelegate

extension EditClientController: UIImagePickerControllerDelegate {
    /// Пользователь выбрал фотографию в UIImagePickerController
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.editedImage] as? UIImage {
            // Масштабировать фотографию до 500х500 px
            photoImageView.image = image.resize(toWidthAndHeight: 500)
            isPhotoPicked = true
            picker.dismiss(animated: true)
        }
    }
}

// MARK: - UITableViewDelegate

extension EditClientController {
    // Нажатие на кнопку черного списка или удаления
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            tableView.deselectRow(at: indexPath, animated: true)
            // Нажата кнопка черного списка
            if indexPath.row == 0 {
                if !isBlocked {
                    let actionSheet = UIAlertController.blockClientActionSheet {
                        self.isBlocked = true
                    }
                    present(actionSheet, animated: true)
                } else {
                    isBlocked = false
                }
            }
            // Нажата кнопка удаления
            else {
                let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                let deleteAction = UIAlertAction(
                    title: NSLocalizedString("REMOVE_PROFILE", comment: "Удалить профиль"),
                    style: .destructive) { _ in
                        let confirmAlert = UIAlertController.confirmClientDeletionAlert {
                            ClientRepository.remove(self.client!)
                            CoreDataManager.shared.saveContext()
                            self.delegate?.editClientController(self, hasDeleted: self.client!)
                            self.dismiss(animated: true)
                        }
                        self.present(confirmAlert, animated: true)
                }
                actionSheet.addAction(deleteAction)
                actionSheet.addAction(UIAlertAction.cancel)
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
