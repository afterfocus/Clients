//
//  ClientViewModel.swift
//  Clients
//
//  Created by Максим Голов on 06.03.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import UIKit

class ClientViewModel {
    private let client: Client
    
    init(client: Client) {
        self.client = client
    }
    
    var photoImage: UIImage {
        if let data = client.photoData {
            return UIImage(data: data)!
        } else {
            return UIImage(named: "default_photo")!
        }
    }
    
    var nameText: String {
        return "\(client)"
    }
    
    var phonenumberText: String {
        return client.phonenumber.formattedPhoneNumber
    }
    
    var vkUrlText: String {
        return client.vk
    }
    
    var notesText: String {
        return client.notes.isEmpty ? "" : "«\(client.notes)»"
    }
    
    var hasPhonenumber: Bool {
        return !client.phonenumber.isEmpty
    }
    
    var hasVkUrl: Bool {
        return !client.vk.isEmpty
    }
    
    var hasNotes: Bool {
        return !client.notes.isEmpty
    }
    
    var isBlocked: Bool {
        return client.isBlocked
    }
}
