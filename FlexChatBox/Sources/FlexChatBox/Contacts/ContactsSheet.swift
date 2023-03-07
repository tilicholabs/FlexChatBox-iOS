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
    @State private var searchText: String = ""
    @State private var editMode = EditMode.active
    let completion: ([Contact]) -> Void
    
    var body: some View {
        NavigationStack {
            VStack {
                SearchBar(text: $searchText)
                
                List(contacts.contacts.filter({
                    searchText.isEmpty ? true : ($0.firstName + " " + $0.lastName).lowercased().contains(searchText.lowercased())
                }),
                     selection: $selection,
                     rowContent: { contact in
                    VStack(alignment: .leading) {
                        Text(contact.firstName + " " + contact.lastName)
                            .font(Font.headline)
                            .bold()
                        Text(contact.phoneNumbers.first ?? "")
                            .font(Font.subheadline)
                        Text(contact.emailAddresses.first ?? "")
                            .font(Font.subheadline)
                    }
                })
            }
            .toolbar {
                Button(action: {
                    let selectedContacts = contacts.contacts.filter { selection.contains($0.id) }
                    completion(selectedContacts)
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Text("Done")
                })
            }
            .environment(\.editMode, $editMode)
            .navigationTitle("Contacts")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
