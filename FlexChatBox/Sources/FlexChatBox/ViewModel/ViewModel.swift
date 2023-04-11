//
//  ViewModel.swift
//
//  Created by Damerla Bhanu Prakash on 28/02/23.
//

import SwiftUI
import AVFoundation
import CoreLocation

enum FlexButtonAuthStatus {
    case notDetermined, authorised, denied
}

class ViewModel: ObservableObject {
    private var audioRecorder: AVAudioRecorder?
    var fileName: URL?
    
    @Published var showAudioPreview = false
    @Published var isRecording = false
    @Published var isMicPermissionGranted = FlexButtonAuthStatus.notDetermined
    
    @Published var textFieldText = FlexHelper.emptyString
    @Published var showSettingsAlert = false
    @Published var presentCamera = false
    @Published var cameraStatus: FlexButtonAuthStatus = .notDetermined
    @Published var capturedImage: Image?
    @Published var videoURL: URL?
    @Published var location: Location?
    @Published private var elapsedTime = 0
    @Published private var timer: Timer?
    @Published var isDragged = false
    
    func checkCameraAuthorizationStatus() {
        showSettingsAlert = false
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return }
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            (cameraStatus, presentCamera) = (.authorised, true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    (self.presentCamera, self.cameraStatus) = granted ? (true, .authorised): (false, .denied)
                }}
        case .denied:
            (cameraStatus, showSettingsAlert) = (.denied, true)
        default:
            cameraStatus = .notDetermined
            break
        }
    }
    
    func checkCameraStatusWhenAppear() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return }
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .denied:
            cameraStatus = .denied
        default:
            cameraStatus = .notDetermined
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
        guard let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
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
    
    func stopRecording() {
        stopTimer()
        audioRecorder?.stop()
        isRecording = false
    }
    
    func checkMicrophoneAuthorizationStatus() {
        let audioSession = AVAudioSession.sharedInstance()
        showSettingsAlert = false
        switch audioSession.recordPermission {
        case .undetermined:
            audioSession.requestRecordPermission { self.isMicPermissionGranted = $0 ? .authorised: .denied }
        case .denied:
            isMicPermissionGranted = .denied
            showSettingsAlert = true
        case .granted:
            isMicPermissionGranted = .authorised
        @unknown default:
            isMicPermissionGranted = .notDetermined
        }
    }
    
    func checkMicPermissionWhenAppear() {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .denied:
            isMicPermissionGranted = .denied
        default:
            isMicPermissionGranted = .notDetermined
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
