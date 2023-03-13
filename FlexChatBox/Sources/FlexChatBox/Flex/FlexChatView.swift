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
    
    @State var media: Media?
    @State var showGalleryPreview = false
    @State var showLocationPreview = false
    @State var showPicker = false
    
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var viewModel: ViewModel
    @EnvironmentObject var contacts: FetchedContacts
    
    @StateObject var imagePicker = ImagePicker()
    @StateObject var locationManager = LocationManager.shared
    
    @FocusState private var start
    @State private var flexButtonName: String
    @State private var isPresentFiles = false
    
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
        _flexButtonName = State(initialValue: flexType.icon)
    }
    
    public var body: some View {
        HStack(alignment: .bottom, spacing: 12.0) {
            flexTextField
            
            switch flexType {
            case .camera:
                cameraButton
            case .gallery:
                photosPicker
            case .mic:
                micButton
            case .location:
                locationButton
            case .contacts:
                contactsButton
            case .files:
                filesButton
            case .custom:
                customButton
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
    private var cameraButton: some View {
        Button(action: {
            viewModel.checkCameraAuthorizationStatus()
        }, label: {
            Image(systemName: flexType.icon)
        })
        
        .onAppear(perform: {
            viewModel.checkCameraStatusWhenAppear()
        })
        .foregroundColor(!(viewModel.cameraStatus ?? true) ? FlexHelper.disabledButtonColor: FlexHelper.enabledButtonColor)
        
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
        
        .alert(FlexHelper.goToSettings, isPresented: $viewModel.showSettingsAlert) {
            Button {
                // nothing needed here
            } label: { Text(FlexHelper.cancelButtonTitle) }
            
            Button {
                guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                UIApplication.shared.open(url)
            } label: { Text(FlexHelper.settingsButtonTitle) }
        } message: {
            Text(FlexHelper.cameraPermissionAlert)
        }
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
                     .sheet(isPresented: $showGalleryPreview, onDismiss: {
                         self.showGalleryPreview = false
                     }) {
                         if let media {
                             GalleryPreview(media: media) { showPicker, selectedMedia in
                                 if showPicker {
                                     DispatchQueue.main.async {
                                         self.showPicker = true
                                     }
                                 } else {
                                     if let selectedMedia {
                                         self.flexCompletion(.gallery(selectedMedia))
                                     }
                                     imagePicker.imageSelections.removeAll()
                                 }
                             }
                         } else {
                             Text("No media")
                         }
                     }
                     .onAppear {
                         self.imagePicker.onCompletion = { selectedMedia in
                             DispatchQueue.main.async {
                                 self.media = selectedMedia
                                 self.showGalleryPreview = true
                             }
                         }
                     }
                     .photosPicker(isPresented: $showPicker,
                                   selection: $imagePicker.imageSelections,
                                   maxSelectionCount: 10,
                                   matching: .any(of: [.images, .videos]),
                                   photoLibrary: .shared())
    }
    
    @ViewBuilder
    private var micButton: some View {
        Button(action: {
            // Action long press
        }, label: {
            Image(systemName: flexButtonName)
                .onLongPressGesture(minimumDuration: 0.5) {
                    viewModel.checkMicrophoneAuthorizationStatus()
                    guard let granted = viewModel.isMicPermissionGranted, granted else { return }
                    flexButtonName = FlexHelper.recordingMicImageName
                    viewModel.startRecording()
                }
            
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onEnded { _ in
                            if viewModel.isRecording,
                               let recordedAudio = viewModel.stopRecording() {
                                flexButtonName = flexType.icon
                                flexCompletion(.mic(recordedAudio))
                            }
                        }
                )
        })
        .onAppear(perform: {
            viewModel.checkMicPermissionWhenAppear()
        })
        .foregroundColor(!(viewModel.isMicPermissionGranted ?? true) ? FlexHelper.disabledButtonColor: FlexHelper.enabledButtonColor)
        
        .padding(.all, 10)
        .overlay(RoundedRectangle(cornerRadius: 4)
            .stroke(Color(.lightGray)))
        
        .alert(FlexHelper.goToSettings, isPresented: $viewModel.showSettingsAlert) {
            Button {
                // nothing needed here
            } label: { Text(FlexHelper.cancelButtonTitle) }
            
            Button {
                guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                UIApplication.shared.open(url)
            } label: { Text(FlexHelper.settingsButtonTitle) }
        } message: {
            Text(FlexHelper.microphonePermissionAlert)
        }
    }
    
    @ViewBuilder
    private var locationButton: some View {
        Button(action: {
            locationManager.requestLocationUpdates()
        }, label: {
            Image(systemName: flexType.icon)
        })
        
        .onAppear(perform: {
            locationManager.checkLocationStatusWhenAppear()
        })
        .foregroundColor(!(locationManager.locationStatus ?? true) ? FlexHelper.disabledButtonColor: FlexHelper.enabledButtonColor)
        
        .padding(.all, 10)
        .overlay(RoundedRectangle(cornerRadius: 4)
            .stroke(Color(.lightGray)))
        
        .onReceive(locationManager.$getCoordinates, perform: { isGranted in
            if isGranted, let coordinates = locationManager.coordinates {
                showLocationPreview = true
                viewModel.coordinates = coordinates
            }
        })
        
        .alert(FlexHelper.goToSettings, isPresented: $locationManager.showSettingsAlert) {
            Button {
                // nothing needed here
            } label: { Text(FlexHelper.cancelButtonTitle) }
            
            Button {
                guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                UIApplication.shared.open(url)
            } label: { Text(FlexHelper.settingsButtonTitle) }
        } message: {
            Text(FlexHelper.locationPermissionAlert)
        }
        .sheet(isPresented: $showLocationPreview) {
            if let coordinates = viewModel.coordinates {
                LocationPreview(coordinates: coordinates) { map in
                    if let map {
                        self.flexCompletion(.location(map))
                    }
                    locationManager.getCoordinates = false
                }
            } else {
                Text("")
                    .onAppear {
                        presentationMode.wrappedValue.dismiss()
                    }
            }
        }
    }
    
    @ViewBuilder
    private var contactsButton: some View {
        Button(action: {
            contacts.checkAuthorizationStatus()
        }, label: {
            Image(systemName: flexType.icon)
        })
        
        .padding(.all, 10)
        .overlay(RoundedRectangle(cornerRadius: 4)
            .stroke(Color(.lightGray)))
        
        .sheet(isPresented: $contacts.presentContacts, content: {
            ContactsSheet(completion: { flexCompletion(.contacts($0)) })
                .environmentObject(contacts)
        })
        
        .onAppear(perform: {
            contacts.checkContactsStatusWhenAppear()
        })
        .foregroundColor(!(contacts.contactsStatus ?? true) ? FlexHelper.disabledButtonColor: FlexHelper.enabledButtonColor)
        
        .alert(FlexHelper.goToSettings, isPresented: $contacts.showSettingsAlert) {
            Button {
                // nothing needed here
            } label: { Text(FlexHelper.cancelButtonTitle) }
            
            Button {
                guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                UIApplication.shared.open(url)
            } label: { Text(FlexHelper.settingsButtonTitle) }
        } message: {
            Text(FlexHelper.contactsPermissionAlert)
        }
    }
    
    @ViewBuilder
    private var filesButton: some View {
        Button(action: {
            isPresentFiles.toggle()
        }, label: {
            Image(systemName: flexType.icon)
        })
        .padding(.all, 10)
        .overlay(RoundedRectangle(cornerRadius: 4)
            .stroke(Color(.lightGray)))
        .fileImporter(isPresented: $isPresentFiles, allowedContentTypes: [.item], allowsMultipleSelection: true, onCompletion: { result in
            do {
                let fileURLs = try result.get()
                DispatchQueue.main.async {
                    flexCompletion(.files(fileURLs))
                }
            } catch {
                print(error.localizedDescription)
            }
        })
    }
    
    @ViewBuilder
    private var customButton: some View {
        Button(action: {
            // Custom button action
            print("Custom button is not initialised")
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
            onClickSend(viewModel.textFieldText)
        }, label: {
            Image(systemName: FlexHelper.sendButtonImageName)
        })
        .padding(.all, 10)
        .overlay(RoundedRectangle(cornerRadius: 4)
            .stroke(Color(.lightGray)))
    }
}

struct FlexChatView_Previews: PreviewProvider {
    static var previews: some View {
        FlexChatView(flexType: .location,
                     placeholder: FlexHelper.textFieldPlaceholder,
                     flexCompletion: { image in
            print(image)
        }, onClickSend: { print($0 ?? FlexHelper.emptyString)} )
        .frame(maxHeight: .infinity, alignment: .bottom)
        .environmentObject(ViewModel())
    }
}
