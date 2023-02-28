//
//  FlexChatView.swift
//
//
//  Created by Aditya Kumar Bodapati on 23/02/23.
//

import SwiftUI

public enum FlexType: String {
    case camera = "camera"
    case gallery = "photo"
    case mic = "mic"
    case custom = "paperclip"
}

public struct FlexChatView: View {
    
    @FocusState private var start
    @EnvironmentObject private var viewModel: ViewModel
    
    let flexType: FlexType
    let textFieldPlaceHolder: String
    
    public init(flexType: FlexType = .camera,
                placeholder: String = "Type your text here") {
        self.flexType = flexType
        self.textFieldPlaceHolder = placeholder
    }
    
    public var body: some View {
        HStack(alignment: .bottom, spacing: 12.0) {
            flexTextField
            flexButton
            flexSend
        }
        .padding(.all, 8.0)
        .sheet(isPresented: $viewModel.presentCamera) {
            ImagePicker(capturedImage: $viewModel.image)
                .ignoresSafeArea()
        }
        
        .alert("Go to settings", isPresented: $viewModel.showSettingsAlert) {
            Button {
                // nothing needed here
            } label: {
                Text("Cancel")
            }
            Button {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            } label: {
                Text("Settings")
            }
        } message: {
            Text("Please click on the Settings to enable the camera permission")
        }
    }
    
    @ViewBuilder
    private var flexTextField: some View {
        TextField(textFieldPlaceHolder, text: $viewModel.textFieldText, axis: .vertical)
            .padding(.all, 8.0)
            .lineLimit(0...4)
            .overlay(RoundedRectangle(cornerRadius: 4)
                .stroke(Color(start ? .tintColor: .lightGray)))
            .focused($start)
    }
    
    @ViewBuilder
    private var flexButton: some View {
        Button(action: {
            viewModel.checkCameraAuthorizationStatus()
        }, label: {
            Image(systemName: flexType.rawValue)
        })
        .padding(.all, 10)
        .overlay(RoundedRectangle(cornerRadius: 4)
            .stroke(Color(.lightGray)))
    }
    
    @ViewBuilder
    private var flexSend: some View {
        Button(action: {
            print("Send button clicked")
        }, label: {
            Image(systemName: "paperplane")
        })
        .padding(.all, 10)
        .overlay(RoundedRectangle(cornerRadius: 4)
            .stroke(Color(.lightGray)))
    }
}

struct FlexChatView_Previews: PreviewProvider {
    static var previews: some View {
        FlexChatView()
            .frame(maxHeight: .infinity, alignment: .bottom)
    }
}
