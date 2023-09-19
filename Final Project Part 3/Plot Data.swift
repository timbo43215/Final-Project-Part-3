//
//  Plot Data.swift
//  Final Project Part 3
//
//  Created by IIT PHYS 440 on 5/2/23.
//

import Foundation

struct DensityOfStatesHistogram: Identifiable {
    
    var id: Double { energies }
    var energies: Double
    var densityOfStates: Double
    var histogram: Double
    
}

struct EnergyAndMagHistogramData: Identifiable {
    var id: Double { energyAndMags }
    var energyAndMags: Double
    var energyAndMagHistogram: Double
    var energyAndMagDOS: Double
}

struct ThermodynamicsPlot: Identifiable {
    
    var id: Double { kT }
    var kT: Double
    var specificHeat: Double
    var magnetismForPlot: Double
    
}
