//
//  ContactsSheet.swift
//  TestSwiftUI
//
//  Created by Aditya Kumar Bodapati on 07/03/23.
//

import SwiftUI

struct ContactsSheet: View {
    @EnvironmentObject var contacts: FetchedContacts
    @Environment(\.presentationMode) private var presentationMode
    @State private var selection = Set<UUID>()
    @State private var searchText: String = FlexHelper.emptyString
    @State private var editMode = EditMode.active
    let completion: ([Contact]) -> Void
    
    var body: some View {
        NavigationStack {
            VStack {
                SearchBar(text: $searchText)
                
                List(contacts.contacts.filter({
                    searchText.isEmpty ? true : ($0.firstName + FlexHelper.space + $0.lastName).lowercased().contains(searchText.lowercased())
                }),
                     selection: $selection,
                     rowContent: { contact in
                    VStack(alignment: .leading) {
                        Text(contact.firstName + FlexHelper.space + contact.lastName)
                            .foregroundColor(.black)
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
                Button(action: {
                    let selectedContacts = contacts.contacts.filter { selection.contains($0.id) }
                    if !selectedContacts.isEmpty {
                        completion(selectedContacts)
                    }
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Text(FlexHelper.doneButtonTitle)
                })
            }
            .environment(\.editMode, $editMode)
            .navigationTitle(FlexHelper.contactsTitle)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
