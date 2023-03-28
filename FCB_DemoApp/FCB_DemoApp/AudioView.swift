//
//  AudioView.swift
//  TestSwiftUI
//
//  Created by Damerla Bhanu Prakash on 15/03/23.
//

import SwiftUI
import AVFoundation

struct AudioView: View {
    let url: URL
    @EnvironmentObject var viewModel: AudioPlayer
    @State private var player: AVAudioPlayer?
    @State private var timer: Timer?
    @State private var elapsedTime = 0
    @State private var duration = 0
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "waveform")
            Text("Audio")
            Text(viewModel.isPlaying ? formatTime(elapsedTime): formatTime(duration))
                .onAppear {
                    do {
                        player = try AVAudioPlayer(contentsOf: url)
                        player?.prepareToPlay()
                        duration = Int(player?.duration ?? 0.0)
                    } catch {
                        print("Error loading audio file: \(error.localizedDescription)")
                    }
                }
            Button {
                viewModel.isPlaying ? viewModel.stopPlaying(): viewModel.startPlaying(url: url)
                viewModel.isPlaying ? startTimer(): stopTimer()
            } label: {
                Image(systemName: viewModel.isPlaying ? "pause.circle": "play.circle")
            }
        }
        .padding()
        .flexBackground()
        .flexRoundedCorner()
    }
    
    func formatTime(_ time: Int) -> String {
        let minutes = time / 60
        let seconds = time % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if elapsedTime < Int(player?.duration ?? 0.0) {
                elapsedTime += 1
            } else {
                stopTimer()
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        elapsedTime = 0
    }
}
