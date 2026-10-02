//
//  AudioPlayer.swift
//  MetronomeApp
//
//  Created by Alex Shubin on 25.09.26.
//  Copyright © 2026 Alex Shubin. All rights reserved.
//

import AVFoundation

/// Thin wrapper over `AVAudioPlayerNode`. Owns no state — it plays what it's told, when it's told.
protocol AudioPlayerType: Sendable {
    /// Frames per second of the player's timeline; sample times and buffers are expressed in it.
    var sampleRate: Double { get }

    /// Position of the playhead in frames since `play()`, `nil` while stopped.
    var playheadSampleTime: Int64? { get }

    func play()
    func stop()

    /// Schedules a buffer to sound at the given player sample time.
    /// `onConsumed` fires once the player has taken the buffer's frames, i.e. there's room to schedule the next one.
    /// It is not invoked for buffers discarded by `stop()`.
    func schedule(_ buffer: ClickBuffer, at sampleTime: Int64, onConsumed: @escaping @Sendable () async -> Void)
}

/// Plays buffers in `AVAudioFormat.metronome`.
struct AudioPlayer: AudioPlayerType {
    private let audioPlayerNode: AVAudioPlayerNode
    private let audioEngine: AVAudioEngine

    var sampleRate: Double { AVAudioFormat.metronome.sampleRate }

    init() {
        audioPlayerNode = AVAudioPlayerNode()

        audioEngine = AVAudioEngine()
        audioEngine.attach(audioPlayerNode)

        audioEngine.connect(audioPlayerNode,
                            to: audioEngine.mainMixerNode,
                            format: .metronome)
        try! audioEngine.start()
    }

    var playheadSampleTime: Int64? {
        guard let nodeTime = audioPlayerNode.lastRenderTime,
              let playerTime = audioPlayerNode.playerTime(forNodeTime: nodeTime) else {
            return nil
        }
        return playerTime.sampleTime
    }

    func play() {
        audioPlayerNode.play()
    }

    func stop() {
        audioPlayerNode.stop()
    }

    func schedule(_ buffer: ClickBuffer, at sampleTime: Int64, onConsumed: @escaping @Sendable () async -> Void) {
        audioPlayerNode.scheduleBuffer(
            buffer.pcm,
            at: AVAudioTime(sampleTime: sampleTime, atRate: sampleRate),
            options: [],
            completionCallbackType: .dataConsumed
        ) { _ in Task { await onConsumed() } }
    }
}
