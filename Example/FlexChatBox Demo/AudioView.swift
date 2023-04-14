//
//  AudioView.swift
//  TestSwiftUI
//
//  Created by Damerla Bhanu Prakash on 15/03/23.
//

import SwiftUI
import AVFoundation

struct AudioView: View {
    @EnvironmentObject var player: AudioPlayer
    @State private var timer: Timer?
    @State private var elapsedTime = 0
    
    private var formatTime: String {
        let time  = (player.isPlaying && (elapsedTime < player.duration)) ? elapsedTime: player.duration
        let minutes = time / 60
        let seconds = time % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "waveform")
            Text("Audio")
            Text(formatTime)
            Button {
                if player.isPlaying {
                    player.stopPlaying()
                    stopTimer()
                } else {
                    player.startPlaying()
                    startTimer()
                }
            } label: {
                Image(systemName: player.isPlaying ? "pause.circle": "play.circle")
            }
        }
        .padding()
        .flexBackground()
        .flexRoundedCorner()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if elapsedTime < player.duration {
                elapsedTime += 1
            } else {
                elapsedTime = 0
                stopTimer()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
