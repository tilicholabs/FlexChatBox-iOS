//
//  ViewModel.swift
//
//  Created by Damerla Bhanu Prakash on 28/02/23.
//

import SwiftUI
import AVFoundation

class ViewModel: ObservableObject {
    @Published var textFieldText = ""
    @Published var showSettingsAlert = false
    @Published var presentCamera = false
    @Published var image: UIImage?
    
    func checkCameraAuthorizationStatus() {
        showSettingsAlert = false
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return }
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            presentCamera = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { self.presentCamera = $0 }
        case .denied:
            showSettingsAlert = true
        case .restricted:
            break
        default:
            break
        }
    }
}
