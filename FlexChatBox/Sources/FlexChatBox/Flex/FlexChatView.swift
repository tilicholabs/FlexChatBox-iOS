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
    
    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.colorScheme) private var colorScheme
    
    @State var offset = CGSize.zero
    @State var isLongPressed = false
    @State var showGalleryPreview = false
    @State var showLocationPreview = false
    @State var showPicker = false
    
    @EnvironmentObject private var viewModel: ViewModel
    @EnvironmentObject var contacts: FetchedContacts
    
    @StateObject var imagePicker = ImagePicker()
    @StateObject var locationManager = LocationManager.shared
    
    @FocusState private var start
    @State private var isPresentFiles = false
    
    let flexType: FlexType
    let textFieldPlaceHolder: String
    let flexCompletion: (FlexOutput) -> Void
    
    private var themeColor: Color {
        colorScheme == .dark ? .white: .black
    }
    
    private var audioRecordingViewColor: Color {
        viewModel.isDragged ? .red : themeColor
    }
    
    public init(flexType: FlexType,
                placeholder: String,
                flexCompletion: @escaping (FlexOutput) -> Void) {
        self.flexType = flexType
        self.textFieldPlaceHolder = placeholder
        self.flexCompletion = flexCompletion
    }
    
    public var body: some View {
        HStack(alignment: .bottom) {
            if viewModel.isRecording {
                audioRecordingView
            } else {
                flexTextField
            }
            
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
        }
    }
    
    @ViewBuilder
    private var flexTextField: some View {
        HStack(alignment: .bottom) {
            TextField(textFieldPlaceHolder, text: $viewModel.textFieldText, axis: .vertical)
                .lineLimit(0...4)
                .focused($start)
                .onSubmit {
                    if !viewModel.textFieldText.isEmpty {
                        flexCompletion(.text(viewModel.textFieldText))
                    }
                }
                .padding(FlexHelper.padding)
                .padding(.trailing, -FlexHelper.padding)
            flexSend
        }
        .background(Color(.systemGray6))
        .cornerRadius(30)
    }
    
    @ViewBuilder
    private var cameraButton: some View {
        Button(action: {
            viewModel.checkCameraAuthorizationStatus()
        }, label: {
            Image(systemName: flexType.icon)
                .flexIconFrame()
                .padding()
                .foregroundColor(Color.white)
                .flexBackground(hex: hexColor(status: (viewModel.cameraStatus ?? true)))
                .flexIconCornerRadius()
        })
        
        .onAppear(perform: {
            viewModel.checkCameraStatusWhenAppear()
        })
        
        .sheet(isPresented: $viewModel.presentCamera) {
            CaptureImage(capturedImage: $viewModel.capturedImage, videoURL: $viewModel.videoURL)
                .ignoresSafeArea()
                .onReceive(viewModel.$capturedImage) { image in
                    guard let image else { return }
                    self.flexCompletion(.camera(image))
                }
                .onReceive(viewModel.$videoURL) { url in
                    guard let url else { return }
                    self.flexCompletion(.video(url))
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
                .flexIconFrame()
                .padding()
                .foregroundColor(Color.white)
                .flexBackground()
                .flexIconCornerRadius()
        }
                     .onAppear {
                         imagePicker.onCompletion = {
                             self.flexCompletion(.gallery($0))
                         }
                     }
    }
    
    @ViewBuilder
    private var micButton: some View {
        Image(systemName: viewModel.isRecording ? FlexHelper.recordingAudioImageName: flexType.icon)
            .flexIconFrame()
            .padding()
            .foregroundColor(Color.white)
            .flexBackground(hex: hexColor(status: (viewModel.isMicPermissionGranted ?? true)))
            .flexIconCornerRadius()
        //            .offset(x: offset.width, y: 0)
            .gesture(
                LongPressGesture(minimumDuration: 0.5)
                    .onEnded { value in
                        viewModel.checkMicrophoneAuthorizationStatus()
                        guard let granted = viewModel.isMicPermissionGranted, granted else { return }
                        viewModel.startRecording()
                        isLongPressed = true
                    }
                    .simultaneously(with: DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            viewModel.isDragged = !(value.translation.width >= -10)
                            if isLongPressed, value.translation.width > -120 {
                                offset.width = value.translation.width
                            }
                        }
                        .onEnded { value in
                            guard viewModel.isRecording,
                                  let recordedAudio = viewModel.stopRecording() else {
                                offset = .zero
                                return
                            }
                            
                            if !(offset.width < -100) {
                                flexCompletion(.mic(recordedAudio))
                            }
                            
                            isLongPressed = false
                            offset = .zero
                        }
                    )
            )
            .onAppear(perform: {
                viewModel.checkMicPermissionWhenAppear()
            })
        
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
                .flexIconFrame()
                .padding()
                .foregroundColor(Color.white)
                .flexBackground(hex: hexColor(status: (locationManager.locationStatus ?? true)))
                .flexIconCornerRadius()
        })
        
        .onAppear(perform: {
            locationManager.checkLocationStatusWhenAppear()
        })
        
        .onReceive(locationManager.$getCoordinates, perform: { isGranted in
            if isGranted, let location = locationManager.location {
                showLocationPreview = true
                viewModel.location = location
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
            if let location = viewModel.location {
                LocationPreview(location: location) { location in
                    if let location {
                        self.flexCompletion(.location(location))
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
                .flexIconFrame()
                .padding()
                .foregroundColor(Color.white)
                .flexBackground(hex: hexColor(status: (contacts.contactsStatus ?? true)))
                .flexIconCornerRadius()
        })
        
        .sheet(isPresented: $contacts.presentContacts, content: {
            ContactsSheet(completion: { flexCompletion(.contacts($0)) })
                .environmentObject(contacts)
        })
        
        .onAppear(perform: {
            contacts.checkContactsStatusWhenAppear()
        })
        
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
                .flexIconFrame()
                .padding()
                .foregroundColor(Color.white)
                .flexBackground()
                .flexIconCornerRadius()
            
        })
        
        .fileImporter(isPresented: $isPresentFiles, allowedContentTypes: [.item], allowsMultipleSelection: true, onCompletion: { result in
            do {
                let fileURLs = try result.get()
                DispatchQueue.main.async {
                    flexCompletion(.files(fileURLs.filter { $0.startAccessingSecurityScopedResource() }))
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
                .flexIconFrame()
                .padding()
                .foregroundColor(Color.white)
                .flexBackground()
                .flexIconCornerRadius()
        })
    }
    
    @ViewBuilder
    private var flexSend: some View {
        let isTextEmpty = viewModel.textFieldText.isEmpty
        Button(action: {
            if !isTextEmpty {
                flexCompletion(.text(viewModel.textFieldText))
            }
        }, label: {
            Image(systemName: FlexHelper.sendButtonImageName)
                .foregroundColor(isTextEmpty ? .gray: Color(hex: hexColor()))
        })
        .padding(FlexHelper.padding)
        .padding(.leading, -FlexHelper.padding)
    }
    
    @ViewBuilder
    private var audioRecordingView: some View {
        HStack {
            Image(systemName: FlexHelper.xmarkbin)
                .foregroundColor(viewModel.isDragged ? .red : Color(hex: hexColor()))
            Spacer()
            VStack(alignment: .center) {
                HStack {
                    Text(FlexHelper.recordingAudio)
                        .foregroundColor(audioRecordingViewColor)
                    Text(viewModel.formatTime())
                        .foregroundColor(audioRecordingViewColor)
                }
                Text(viewModel.isDragged ? FlexHelper.swipeToCancel: FlexHelper.releaseToSend)
                    .foregroundColor(audioRecordingViewColor)
            }
            Spacer()
            Image(systemName: FlexHelper.waveform)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func hexColor(status: Bool = true) -> String {
        status ? FlexHelper.enabledHexColor: FlexHelper.disabledHexColor
    }
}

struct FlexChatView_Previews: PreviewProvider {
    static var previews: some View {
        FlexChatView(flexType: .location, placeholder: FlexHelper.textFieldPlaceholder, flexCompletion: {
            print($0)
        })
        .frame(maxHeight: .infinity, alignment: .bottom)
        .environmentObject(ViewModel())
    }
}
