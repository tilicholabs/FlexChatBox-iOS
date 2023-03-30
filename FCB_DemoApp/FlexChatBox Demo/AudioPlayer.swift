//
//  AudioPlayer.swift
//  TestSwiftUI
//
//  Created by Damerla Bhanu Prakash on 06/03/23.
//

import Foundation
import AVFoundation

class AudioPlayer: NSObject, AVAudioPlayerDelegate, ObservableObject {
    private var audioPlayer: AVAudioPlayer?
    @Published var isPlaying = false
    
    func startPlaying(url: URL) {
        let playSession = AVAudioSession.sharedInstance()
        
        do {
            try playSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
        } catch {
            print("Playing failed in Device")
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            isPlaying = true
        } catch {
            print("Playing Failed")
        }
    }
    
    func stopPlaying() {
        audioPlayer?.stop()
        isPlaying = false
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
    }
}
