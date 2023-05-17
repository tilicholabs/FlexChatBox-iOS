//
//  EntityStoreModel.swift
//  FlexChatBox Demo
//
//  Created by Appala Naidu Uppada on 17/05/23.
//

import Foundation
import FlexChatBox
import SwiftUI

class EntityStoreModel: ObservableObject {
    private var entities: [Entity] = [
        EntityBuilder.flexCameraEntity({ _, _ in }),
        EntityBuilder.flexGalleryEntity({ _ in }),
        EntityBuilder.flexCustomEntity({
            CustomView { }
        })
    ]
    
    @Published var selectedEntity: Entity = EntityBuilder.flexCameraEntity({ _, _  in })
    
    var selectedIndex = 0
    
    func changeEntity() {
        selectedIndex = (selectedIndex == (entities.count - 1)) ? 0 : selectedIndex + 1
        selectedEntity = entities[selectedIndex]
    }
}

