//
//  FetchedContacts.swift
//  TestSwiftUI
//
//  Created by Aditya Kumar Bodapati on 07/03/23.
//

import SwiftUI
import Contacts

public struct Contact: Identifiable, Hashable {
    public var id = UUID()
    public var firstName: String
    public var lastName: String
    public var phoneNumbers: [String]
    public var emailAddresses: [String]
    
}

class FetchedContacts: ObservableObject, Identifiable {
    let store = CNContactStore()
    @Published var contactsStatus = FlexButtonAuthStatus.notDetermined
    @Published var presentContacts = false
    @Published var showSettingsAlert = false
    @Published var contacts = [Contact]()
    @Environment(\.presentationMode) private var presentationMode
    
    private func fetchContacts() {
        contacts.removeAll()
        let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactEmailAddressesKey]
        let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
        do {
            try self.store.enumerateContacts(with: request, usingBlock: { (contact, stopPointer) in
                self.contacts.append(Contact(firstName: contact.givenName,
                                             lastName: contact.familyName,
                                             phoneNumbers: contact.phoneNumbers.map { $0.value.stringValue },
                                             emailAddresses: contact.emailAddresses.map { $0.value as String }))
                self.contacts.sort(by: { $0.firstName < $1.firstName })
            })
            DispatchQueue.main.async {
                self.presentContacts = true
            }
            
        } catch let error {
            DispatchQueue.main.async {
                self.presentContacts = false
            }
            print(error.localizedDescription)
        }
    }
    
    func checkAuthorizationStatus() {
        showSettingsAlert = false
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .notDetermined:
            store.requestAccess(for: .contacts) { granted, _ in
                DispatchQueue.main.async {
                    self.contactsStatus = granted ? .authorised: .denied
                    guard granted else {
                        self.presentContacts = false
                        return
                    }
                    self.fetchContacts()
                }
            }
        case .denied:
            (showSettingsAlert, contactsStatus) = (true, .denied)
        case .authorized:
            contactsStatus = .authorised
            fetchContacts()
        default:
            contactsStatus = .notDetermined
        }
    }
    
    func checkContactsStatusWhenAppear() {
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .denied:
            contactsStatus = .denied
        default:
            contactsStatus = .notDetermined
        }
    }
}
