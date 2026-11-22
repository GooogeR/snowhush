import AVFoundation
import Foundation

/// A short, original synthesized winter jingle for a manually triggered snow-plow run.
/// No external music or copyrighted recording is bundled with the app.
final class SnowPlowMusic {
    static let shared = SnowPlowMusic()
    private var player: AVAudioPlayer?

    private init() {}

    func play() {
        do {
            let data = Self.makeJingleWAV()
            let nextPlayer = try AVAudioPlayer(data: data)
            nextPlayer.volume = 0.42
            nextPlayer.prepareToPlay()
            player?.stop()
            player = nextPlayer
            nextPlayer.play()
        } catch {
            NSLog("Snowhush: couldn't play snow-plow jingle: %@", error.localizedDescription)
        }
    }

    private static func makeJingleWAV() -> Data {
        let sampleRate: UInt32 = 22_050
        let notes: [(Double, Double)] = [
            (659.25, 0.24), (783.99, 0.24), (987.77, 0.30), (783.99, 0.22),
            (880.00, 0.24), (1046.50, 0.30), (880.00, 0.22), (783.99, 0.34),
            (659.25, 0.24), (783.99, 0.24), (880.00, 0.30), (987.77, 0.34),
            (1046.50, 0.28), (987.77, 0.24), (880.00, 0.28), (783.99, 0.42),
            (659.25, 0.24), (783.99, 0.24), (880.00, 0.30), (783.99, 0.24),
            (659.25, 0.42), (523.25, 0.28), (659.25, 0.30), (783.99, 0.58)
        ]
        var samples = [Int16]()
        var phase = 0.0
        for (frequency, duration) in notes {
            let count = Int(Double(sampleRate) * duration)
            for index in 0..<count {
                let t = Double(index) / Double(sampleRate)
                let edge = min(1.0, t / 0.025, (duration - t) / 0.045)
                let envelope = max(0, edge)
                phase += 2.0 * Double.pi * frequency / Double(sampleRate)
                let fundamental = sin(phase)
                let overtone = 0.22 * sin(phase * 2.0)
                let chime = 0.10 * sin(phase * 3.0)
                let value = (fundamental + overtone + chime) * envelope * 0.22
                samples.append(Int16(max(-1, min(1, value)) * Double(Int16.max)))
            }
        }

        let byteCount = UInt32(samples.count * MemoryLayout<Int16>.size)
        var data = Data()
        func appendASCII(_ value: String) { data.append(contentsOf: value.utf8) }
        func appendLE<T: FixedWidthInteger>(_ value: T) {
            var little = value.littleEndian
            withUnsafeBytes(of: &little) { data.append(contentsOf: $0) }
        }
        appendASCII("RIFF")
        appendLE(UInt32(36) + byteCount)
        appendASCII("WAVE")
        appendASCII("fmt ")
        appendLE(UInt32(16))
        appendLE(UInt16(1))
        appendLE(UInt16(1))
        appendLE(sampleRate)
        appendLE(sampleRate * 2)
        appendLE(UInt16(2))
        appendLE(UInt16(16))
        appendASCII("data")
        appendLE(byteCount)
        for sample in samples { appendLE(sample) }
        return data
    }
}
