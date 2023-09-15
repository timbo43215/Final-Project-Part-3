//
//  Energy.swift
//  Final Project
//
//  Created by Tim Stack PHYS 440 on 4/28/23.
//

import Foundation

class Energy: ObservableObject {
    
    @Published var possibleEnergyArray: [Double] = []
    @Published var energy: [Double] = []
    @Published var deltaEValues: [Double] = []
    @Published var magnetism: [Double] = []
    @Published var deltaMValues: [Double] = []
    @Published var energyAndMagValues:[(E:Double, M:Double)] = []
}
