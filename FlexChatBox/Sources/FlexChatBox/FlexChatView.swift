//
//  FlexChatView.swift
//
//
//  Created by Aditya Kumar Bodapati on 23/02/23.
//

import SwiftUI

public enum FlexType {
    case camera
    case gallery
    case mic
    case custom
}

extension FlexType {
    var icon: String {
        switch self {
        case .camera:
            return "camera"
        case .gallery:
            return "photo"
        case .mic:
            return "mic"
        case .custom:
            return "paperclip"
        }
    }
}

public struct FlexChatView: View {
    
    @FocusState private var start
    @EnvironmentObject private var viewModel: ViewModel
    
    let flexType: FlexType
    let textFieldPlaceHolder: String
    let completion: (UIImage?) -> Void
    
    public init(flexType: FlexType = .camera,
                placeholder: String = "Type your text here",
                _ completion: @escaping (UIImage?) -> Void) {
        self.flexType = flexType
        self.textFieldPlaceHolder = placeholder
        self.completion = completion
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
                .onReceive(viewModel.$image) { image in
                    guard let image else { return }
                    self.completion(image)
                }
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
            Image(systemName: flexType.icon)
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
        FlexChatView({ image in
            guard let image else { return }
            print(image)
        })
            .frame(maxHeight: .infinity, alignment: .bottom)
            .environmentObject(ViewModel())
    }
}
