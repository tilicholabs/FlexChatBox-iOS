//
//  CustomView.swift
//  FlexChatBox Demo
//
//  Created by Appala Naidu Uppada on 17/05/23.
//

import SwiftUI

struct CustomView: View {
    var successCallback: () -> Void
    
    var body: some View {
        Text("Custom Type")
            .frame(height: 32)
            .onTapGesture {
                successCallback()
            }
    }
}

struct CustomView_Previews: PreviewProvider {
    static var previews: some View {
        CustomView { }
    }
}
