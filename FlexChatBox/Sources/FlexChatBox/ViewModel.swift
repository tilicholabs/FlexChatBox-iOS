//
//  ViewModel.swift
//
//  Created by Damerla Bhanu Prakash on 28/02/23.
//

import SwiftUI
import AVFoundation

class ViewModel: ObservableObject {
    private var audioRecorder: AVAudioRecorder?
    private var fileName: URL?
    @Published var isRecording = false
    @Published var isMicPermissionGranted = false
    
    @Published var textFieldText = ""
    @Published var showSettingsAlert = false
    @Published var presentCamera = false
    @Published var capturedImage: Image?
    
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
    
    func startRecording() {
        setupRecordingSession()
        audioRecorder?.prepareToRecord()
        audioRecorder?.record()
        isRecording = true
    }
    
    private func setupRecordingSession() {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        fileName = path.appendingPathComponent("audioRecorded.m4a")
        guard let fileName else { return }
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            let recordingSession = AVAudioSession.sharedInstance()
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            audioRecorder = try AVAudioRecorder(url: fileName, settings: settings)
        } catch {
            print("Failed to Setup the Recording")
        }
    }
    
    func stopRecording() -> URL? {
        audioRecorder?.stop()
        isRecording = false
        return fileName
    }
    
    func checkMicrophoneAuthorizationStatus() {
        let audioSession = AVAudioSession.sharedInstance()
        showSettingsAlert = false
        switch audioSession.recordPermission {
        case .undetermined:
            audioSession.requestRecordPermission { self.isMicPermissionGranted = $0 }
        case .denied:
            showSettingsAlert = true
        case .granted:
            isMicPermissionGranted = true
        @unknown default:
            break
        }
    }
}
