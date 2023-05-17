//
//  ContentViewV2.swift
//  FlexChatBox Demo
//
//  Created by Appala Naidu Uppada on 17/05/23.
//

import SwiftUI
import FlexChatBox

struct ContentViewV2: View {
    
    @StateObject var entityStore = EntityStoreModel()
    
    var body: some View {
        VStack {
            FlexChatViewV2(selectedEntity: entityStore.selectedEntity)
            Button("Change entity") {
                entityStore.changeEntity()
            }
        }
    }
}

struct ContentViewV2_Previews: PreviewProvider {
    static var previews: some View {
        ContentViewV2()
    }
}
