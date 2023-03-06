//
//  FlexChatView.swift
//
//
//  Created by Aditya Kumar Bodapati on 23/02/23.
//

import SwiftUI
import PhotosUI
import CoreLocationUI

public struct FlexChatView: View {
    
    @FocusState private var start
    @EnvironmentObject private var viewModel: ViewModel
    @StateObject var imagePicker = ImagePicker()
    @StateObject var locationManager = LocationManager.shared
    @State private var flexButtonName: String
    
    let flexType: FlexType
    let textFieldPlaceHolder: String
    let flexCompletion: (FlexOutput) -> Void
    let onClickSend: (String?) -> Void
    
    public init(flexType: FlexType,
                placeholder: String,
                flexCompletion: @escaping (FlexOutput) -> Void,
                onClickSend: @escaping (String?) -> Void) {
        self.flexType = flexType
        self.textFieldPlaceHolder = placeholder
        self.flexCompletion = flexCompletion
        self.onClickSend = onClickSend
        flexButtonName = flexType.icon
    }
    
    public var body: some View {
        HStack(alignment: .bottom, spacing: 12.0) {
            flexTextField
            
            if flexType == .gallery {
                photosPicker
            } else {
                flexButton
            }
            flexSend
        }
        .padding(.all, 8.0)
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
    private var photosPicker: some View {
        PhotosPicker(selection: $imagePicker.imageSelections,
                     maxSelectionCount: 10,
                     matching: .any(of: [.images, .videos]),
                     photoLibrary: .shared()) {
            Image(systemName: flexType.icon)
        }
                     .padding(.all, 10)
                     .overlay(RoundedRectangle(cornerRadius: 4)
                        .stroke(Color(.lightGray)))
                     .onReceive(imagePicker.$media) {
                         self.flexCompletion(.gallery($0))
                     }
    }
    
    @ViewBuilder
    private var flexButton: some View {
        Button(action: {
            switch flexType {
            case .camera:
                viewModel.checkCameraAuthorizationStatus()
            case .location:
                locationManager.requestLocationUpdates()
            default:
                break
            }
        }, label: {
            Image(systemName: flexButtonName)
                .onLongPressGesture(minimumDuration: 0.5) {
                    guard flexType == .mic else { return }
                    viewModel.checkMicrophoneAuthorizationStatus()
                    guard viewModel.isMicPermissionGranted else { return }
                    flexButtonName = "stop"
                    viewModel.startRecording()
                }
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onEnded { _ in
                            if flexType == .mic,
                               viewModel.isRecording,
                               let recordedAudio = viewModel.stopRecording() {
                                flexButtonName = flexType.icon
                                flexCompletion(.mic(recordedAudio))
                            }
                        }
                )
        })
        .padding(.all, 10)
        .overlay(RoundedRectangle(cornerRadius: 4)
            .stroke(Color(.lightGray)))
        .sheet(isPresented: $viewModel.presentCamera) {
            CaptureImage(capturedImage: $viewModel.capturedImage)
                .ignoresSafeArea()
                .onReceive(viewModel.$capturedImage) { image in
                    guard let image else { return }
                    self.flexCompletion(.camera(image))
                    
                }
        }
        .onReceive(locationManager.$getCoordinates, perform: { isGranted in
            if isGranted, let coordinates = locationManager.coordinates {
                self.flexCompletion(.location(coordinates))
            }
        })
        .alert("Go to settings", isPresented: $viewModel.showSettingsAlert) {
            Button {
                // nothing needed here
            } label: {
                Text("Cancel")
            }
            Button {
                guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                UIApplication.shared.open(url)
            } label: {
                Text("Settings")
            }
        } message: {
            Text("Please click on the Settings to enable the camera permission")
        }
        .alert("Go to settings", isPresented: $locationManager.showSettingsAlert) {
            Button {
                // nothing needed here
            } label: {
                Text("Cancel")
            }
            Button {
                guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                UIApplication.shared.open(url)
            } label: {
                Text("Settings")
            }
        } message: {
            Text("Please click on the Settings to enable the Location permission")
        }
    }
    
    @ViewBuilder
    private var flexSend: some View {
        Button(action: {
            onClickSend(viewModel.textFieldText)
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
        FlexChatView(flexType: .location,
                     placeholder: "Enter your text",
                     flexCompletion: { image in
            print(image)
        }, onClickSend: { print($0 ?? "")} )
        .frame(maxHeight: .infinity, alignment: .bottom)
        .environmentObject(ViewModel())
    }
}
