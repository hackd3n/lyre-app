//
//  Tracks.swift
//  lyre-app
//
//  Created by Denis Hackett on 04/07/2023.
//

import UIKit

struct Track {
    let albumArt: UIImage
    let title: String
    let artist: String
    let trackURLs: [TrackList]
}

struct TrackList {
    var baseSample: String
    var secondarySample: String
    var thirdSample: String
}


extension TrackList {
    static func refract() -> [TrackList] {
        return [
        TrackList(baseSample: "Armos Dry", secondarySample: "Lead Dry", thirdSample: "FX Dry"),
        TrackList(baseSample: "Basses Dry", secondarySample: "Kick Dry", thirdSample: "Kick and Basses Dry"),
        TrackList(baseSample: "Perc Dry", secondarySample: "Hats Dry", thirdSample: "Flute Break Dry")]
    }
    
    static func letsGroove() -> [TrackList]{
        return [
      //piano/other
            TrackList(baseSample: "08 Rhodes L", secondarySample: "synth - horns 2", thirdSample: "horns 1 - claps"),
        //guitar/bass
            TrackList(baseSample: "16 Moog Bass", secondarySample: "07 Guitar L (FX)", thirdSample: "15 Bass Guitar"),
        //drums
            TrackList(baseSample: "20 Snare", secondarySample: "22 Kit R", thirdSample: "19 Kick"),
        //vocals
            TrackList(baseSample: "01 Scratch Vox", secondarySample: "02 BG Vox 1", thirdSample: "05 BG Vox 2 R")
        ]
    }
    static func Ubitquitous() -> [TrackList]{
        return [
            TrackList(baseSample: "01_Kick", secondarySample: "02_HiHat1", thirdSample: "HiHat-Claps"),
            TrackList(baseSample: "08_Bass", secondarySample: "05_SFX1", thirdSample: "06_SFX2"),
            TrackList(baseSample: "10_Synth2_PitchModulated", secondarySample: "synth-shakers", thirdSample: "11_Synth2")

        ]
    }
    static func whiptails() -> [TrackList]{
        //WHIPTAILS
        return [
            TrackList(baseSample: "02_Loop2", secondarySample: "01_Loop1", thirdSample: "03_Kick"),
            TrackList(baseSample: "snare-claps-hihat1", secondarySample: "08_SFX", thirdSample: "07_HiHat2"),
            TrackList(baseSample: "13_Synth3", secondarySample: "12_Synth2", thirdSample: "11_Synth1"),
            TrackList(baseSample: "basses", secondarySample: "14_Vox_Dry", thirdSample: "15_Vox_Wet")

        ]
    }
    
    static func ABCDEFU() -> [TrackList]{
        return [
            TrackList(baseSample: "drums (CLEAN)", secondarySample: "drums (ORIGINAL)", thirdSample: "drums"),
            TrackList(baseSample: "bass (CLEAN)", secondarySample: "bass (ORIGINAL)", thirdSample: "bass"),
            TrackList(baseSample: "other (CLEAN)", secondarySample: "other (ORIGINAL)", thirdSample: "other"),
            TrackList(baseSample: "vocals (CLEAN)", secondarySample: "vocals (ORIGINAL)", thirdSample: "vocals")
        ]
    }
}
