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

    /// Reads the whole file into a buffer in the player's format.
    func makeBuffer(reading file: AVAudioFile) -> AVAudioPCMBuffer

    func play()
    func stop()

    /// Schedules a buffer to sound at the given player sample time.
    /// `onConsumed` fires once the player has taken the buffer's frames, i.e. there's room to schedule the next one.
    /// It is not invoked for buffers discarded by `stop()`.
    func schedule(_ buffer: AVAudioPCMBuffer, at sampleTime: Int64, onConsumed: @escaping @Sendable () async -> Void)
}

/// Every file handed to `makeBuffer` must be in `format`: 48 kHz, mono. The bundled clicks are exported that way.
struct AudioPlayer: AudioPlayerType {
    private let audioPlayerNode: AVAudioPlayerNode
    private let audioEngine: AVAudioEngine
    private let format = AVAudioFormat(standardFormatWithSampleRate: 48000, channels: 1)!

    var sampleRate: Double { format.sampleRate }

    init() {
        audioPlayerNode = AVAudioPlayerNode()

        audioEngine = AVAudioEngine()
        audioEngine.attach(audioPlayerNode)

        audioEngine.connect(audioPlayerNode,
                            to: audioEngine.mainMixerNode,
                            format: format)
        try! audioEngine.start()
    }

    var playheadSampleTime: Int64? {
        guard let nodeTime = audioPlayerNode.lastRenderTime,
              let playerTime = audioPlayerNode.playerTime(forNodeTime: nodeTime) else {
            return nil
        }
        return playerTime.sampleTime
    }

    func makeBuffer(reading file: AVAudioFile) -> AVAudioPCMBuffer {
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(file.length))!
        try! file.read(into: buffer)
        return buffer
    }

    func play() {
        audioPlayerNode.play()
    }

    func stop() {
        audioPlayerNode.stop()
    }

    func schedule(_ buffer: AVAudioPCMBuffer, at sampleTime: Int64, onConsumed: @escaping @Sendable () async -> Void) {
        audioPlayerNode.scheduleBuffer(
            buffer,
            at: AVAudioTime(sampleTime: sampleTime, atRate: format.sampleRate),
            options: [],
            completionCallbackType: .dataConsumed
        ) { _ in Task { await onConsumed() } }
    }
}
