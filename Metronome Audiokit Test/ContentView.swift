//
//  ContentView.swift
//  Metronome Audiokit Test
//
//  Created by Eddy Salzmann on 02.12.20.
//

import AudioKit
import AVFoundation
import Combine
import SwiftUI

class DrumSequencerConductor: ObservableObject {
    
    let engine = AudioEngine()
    let drums = MIDISampler(name: "Drums")
    let sequencer = AppleSequencer(filename: "4tracks")

    @Published var tempo: Float = 120 {
        didSet {
            sequencer.setTempo(BPM(tempo))
        }
    }
    @Published var isPlaying = false {
        didSet {
            isPlaying ? sequencer.play() : sequencer.stop()
        }
    }

    init() {

        engine.output = drums
    }

    func start() {

        do {
            try engine.start()
        } catch {
            Log("AudioKit did not start! \(error)")
        }
        do {
            //let metronomeURL = Bundle.main.url(forResource: "TaktellJunior", withExtension: "wav")
            let metronomeURL = Bundle.main.resourceURL?.appendingPathComponent("metronome.wav")
            let metronomeFile = try AVAudioFile(forReading: metronomeURL!)
            try drums.loadAudioFiles([metronomeFile])
        } catch {
            Log("Files Didn't Load")
        }
        sequencer.clearRange(start: Duration(beats: 0), duration: Duration(beats: 100))
        sequencer.debug()
        sequencer.setGlobalMIDIOutput(drums.midiIn)
        sequencer.enableLooping(Duration(beats: 4))
        sequencer.setTempo(120)

        sequencer.tracks[0].add(noteNumber: 60, velocity: 127, position: Duration(beats: 0), duration: Duration(beats: 0.5))
        sequencer.tracks[0].add(noteNumber: 60, velocity: 127, position: Duration(beats: 1), duration: Duration(beats: 0.5))
        sequencer.tracks[0].add(noteNumber: 60, velocity: 127, position: Duration(beats: 2), duration: Duration(beats: 0.5))
        sequencer.tracks[0].add(noteNumber: 60, velocity: 127, position: Duration(beats: 3), duration: Duration(beats: 0.5))

    }

    func stop() {
        engine.stop()
    }
}

struct ContentView: View {
    @ObservedObject var conductor = DrumSequencerConductor()
    @State private var beat: Float = 120
    
    
    var body: some View {
        VStack(spacing: 10) {
            Text(conductor.isPlaying ? "Stop" : "Play").onTapGesture {
                conductor.isPlaying.toggle()
            }
            Slider(value: Binding(get: {
                self.beat
            }, set: { (newVal) in
                self.beat = newVal
                self.conductor.tempo = beat
            }), in: 20...240, step: 1)
                
                .padding()
            
            Text("\(Int(beat))")
        }
        .onAppear {
            self.conductor.start()
            self.conductor.tempo = beat
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
