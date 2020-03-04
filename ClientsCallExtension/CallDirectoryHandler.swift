//
//  CallDirectoryHandler.swift
//  ClientsCallExtension
//
//  Created by Максим Голов on 08.02.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import Foundation
import CallKit

// TODO: Добавлять/удалять номера инкрементально, а не полной перезагрузкой всей базы номеров

class CallDirectoryHandler: CXCallDirectoryProvider {

    override func beginRequest(with context: CXCallDirectoryExtensionContext) {
        context.delegate = self
        context.removeAllBlockingEntries()
        context.removeAllIdentificationEntries()

        let data = ClientRepository.identificationPhoneNumbers
        if AppSettings.shared.shouldBlockIncomingCalls {
            data.forEach {
                if let phone = Int64($0.number) {
                    $0.isBlocked ?
                        context.addBlockingEntry(withNextSequentialPhoneNumber: phone) :
                        context.addIdentificationEntry(withNextSequentialPhoneNumber: phone, label: $0.label)
                }
            }
        } else {
            data.forEach {
                if let phone = Int64($0.number) {
                    context.addIdentificationEntry(withNextSequentialPhoneNumber: phone, label: $0.label)
                }
            }
        }
        context.completeRequest()
    }

    private func addOrRemoveIncrementalBlockingPhoneNumbers(to context: CXCallDirectoryExtensionContext) {
        // Retrieve any changes to the set of phone numbers to block from data store. For optimal performance and memory usage when there are many phone numbers,
        // consider only loading a subset of numbers at a given time and using autorelease pool(s) to release objects allocated during each batch of numbers which are loaded.
        // Record the most-recently loaded set of blocking entries in data store for the next incremental load...
    }

    private func addOrRemoveIncrementalIdentificationPhoneNumbers(to context: CXCallDirectoryExtensionContext) {
        // Retrieve any changes to the set of phone numbers to identify (and their identification labels) from data store. For optimal performance and memory usage when there are many phone numbers,
        // consider only loading a subset of numbers at a given time and using autorelease pool(s) to release objects allocated during each batch of numbers which are loaded.
        // Record the most-recently loaded set of identification entries in data store for the next incremental load...
    }

}

extension CallDirectoryHandler: CXCallDirectoryExtensionContextDelegate {

    func requestFailed(for extensionContext: CXCallDirectoryExtensionContext, withError error: Error) {
        // An error occurred while adding blocking or identification entries, check the NSError for details.
        // For Call Directory error codes, see the CXErrorCodeCallDirectoryManagerError enum in <CallKit/CXError.h>.
        //
        // This may be used to store the error details in a location
        // accessible by the extension's containing app, so that the
        // app may be notified about errors which occured while loading
        // data even if the request to load data was initiated by
        // the user in Settings instead of via the app itself.
    }

}
