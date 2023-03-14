//
//  ViewModel.swift
//
//  Created by Damerla Bhanu Prakash on 28/02/23.
//

import SwiftUI
import AVFoundation
import CoreLocation

class ViewModel: ObservableObject {
    private var audioRecorder: AVAudioRecorder?
    private var fileName: URL?
    @Published var isRecording = false
    @Published var isMicPermissionGranted: Bool?
    
    @Published var textFieldText = FlexHelper.emptyString
    @Published var showSettingsAlert = false
    @Published var presentCamera = false
    @Published var cameraStatus: Bool?
    @Published var capturedImage: Image?
    @Published var videoURL: URL?
    @Published var location: Location?
    @Published private var elapsedTime = 0
    @State private var timer: Timer?
    
    func checkCameraAuthorizationStatus() {
        showSettingsAlert = false
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return }
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            (cameraStatus, presentCamera) = (true, true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    (self.presentCamera, self.cameraStatus) = (granted, granted)
                }}
        case .denied:
            (cameraStatus, showSettingsAlert) = (false, true)
        default:
            cameraStatus = nil
            break
        }
    }
    
    func checkCameraStatusWhenAppear() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return }
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .denied:
            cameraStatus = false
        default:
            cameraStatus = nil
        }
    }
    
    func startRecording() {
        setupRecordingSession()
        audioRecorder?.prepareToRecord()
        startTimer()
        audioRecorder?.record()
        isRecording = true
    }
    
    private func setupRecordingSession() {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        fileName = path.appendingPathComponent(UUID().uuidString + ".m4a")
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
        } catch {}
    }
    
    func stopRecording() -> URL? {
        stopTimer()
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
            isMicPermissionGranted = false
            showSettingsAlert = true
        case .granted:
            isMicPermissionGranted = true
        @unknown default:
            isMicPermissionGranted = nil
        }
    }
    
    func checkMicPermissionWhenAppear() {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .denied:
            isMicPermissionGranted = false
        default:
            isMicPermissionGranted = nil
        }
    }
    
    func formatTime() -> String {
        let minutes = elapsedTime / 60
        let seconds = elapsedTime % 60
        return String(format: FlexHelper.recordingTimeFormat, minutes, seconds)
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.elapsedTime += 1
        }
    }
       
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        elapsedTime = 0
    }
}
