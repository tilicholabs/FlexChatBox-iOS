//
//  ViewModel.swift
//  FlexChatBox Demo
//
//  Created by Aditya Kumar Bodapati on 20/04/23.
//

import SwiftUI
import FlexChatBox

enum Message {
    case images([Image])
    case videos([URL])
    case mic(URL)
    case location(Location)
    case contacts([Contact])
    case files([URL])
    case text(String)
}

class ViewModel: ObservableObject {
    @Published var messages = [Message]()
    @Published var flexType: FlexType = FlexTypeFactory.flexCamera { _, _ in }
    
    var listOfFlexTypes: [(FlexType, String)] = []
    
    init() {
        prepareFlexTypesArray()
        if let flexCamera = listOfFlexTypes.first?.0 {
            flexType = flexCamera
        }
    }
    
    func prepareFlexTypesArray() {
        listOfFlexTypes = [
            (FlexTypeFactory.flexCamera { [weak self] (image, videoURL) in
                guard let self else { return }
                if let image {
                    self.messages.append(.images([image]))
                }
                
                if let videoURL {
                    self.messages.append(.videos([videoURL]))
                }
            }, "Camera"),
            
            (FlexTypeFactory.flexGallery { [weak self] media in
                guard let self else { return }
                if !media.images.isEmpty {
                    self.messages.append(.images(media.images))
                }
                
                if !media.videos.isEmpty {
                    self.messages.append(.videos(media.videos))
                }
            }, "Gallery"),
            
            (FlexTypeFactory.flexMic { [weak self] url in
                guard let self else { return }
                self.messages.append(.mic(url))
            }, "Mic"),
            
            (FlexTypeFactory.flexLocation { [weak self] location in
                guard let self else { return }
                self.messages.append(.location(location))
            }, "Location"),
            
            (FlexTypeFactory.flexContacts { [weak self] contacts in
                guard let self else { return }
                self.messages.append(.contacts(contacts))
            }, "Contacts"),
            
            (FlexTypeFactory.flexFiles { [weak self] urls in
                guard let self else { return }
                self.messages.append(.files(urls))
            }, "Files")]
    }
}
