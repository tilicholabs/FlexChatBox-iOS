//
//  ContactsSheet.swift
//  TestSwiftUI
//
//  Created by Aditya Kumar Bodapati on 07/03/23.
//

import SwiftUI

struct ContactsSheet: View {
    @EnvironmentObject var fetchedContacts: FetchedContacts
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var selection = Set<UUID>()
    @State private var searchText: String = FlexHelper.emptyString
    @State private var editMode = EditMode.active
    let completion: ([Contact]) -> Void
    
    var body: some View {
        NavigationStack {
            VStack {
                SearchBar(text: $searchText)
                
                List(fetchedContacts.contacts.filter({
                    searchText.isEmpty ? true : ($0.firstName + FlexHelper.space + $0.lastName).lowercased().contains(searchText.lowercased())
                }),
                     selection: $selection,
                     rowContent: { contact in
                    VStack(alignment: .leading) {
                        Text(contact.firstName + FlexHelper.space + contact.lastName)
                            .foregroundColor(.primary)
                            .font(Font.headline)
                            .bold()
                        Text(contact.phoneNumbers.first ?? FlexHelper.emptyString)
                            .foregroundColor(.gray)
                            .font(Font.subheadline)
                        Text(contact.emailAddresses.first ?? FlexHelper.emptyString)
                            .foregroundColor(Color(.lightGray))
                            .font(Font.subheadline)
                    }
                })
            }
            .toolbar {
                Button(FlexHelper.doneButtonTitle) {
                    let selectedContacts = fetchedContacts.contacts.filter { selection.contains($0.id) }
                    if !selectedContacts.isEmpty {
                        completion(selectedContacts)
                    }
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .environment(\.editMode, $editMode)
            .navigationTitle(FlexHelper.contactsTitle)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
