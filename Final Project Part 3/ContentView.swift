//
//  ContentView.swift
//  Final Project Part 3
//
//  Created by Tim Stack on 4/28/23.
//

import SwiftUI
import Foundation
import Charts

struct ContentView: View {
    
    @State var upOrDown = [1.0, -1.0]
    @State var spinArray: [Double] = []
    @State var nextSpinArray: [Double] = []
    @State var timeArray: [Double] = []
    @State var Num: String = "4"
    @State var J: String = "1.0"
    @State var g: String = "1.0"
    @State var B: String = "0.0"
    @State var kT: String = "1.0"
    @State var kTArray: [Double] = [1,2,3,4,5,6,7,8,9,10]
    @State var specificHeatArray: [Double] = []
    @State var randParticleX: Int = 0
    @State var randParticleY: Int = 0
    @State var potentialArray: [Double] = []
    @State var previousEnergy: Double = 0.0
    @State var previousMag: Double = 0.0
    @State var energy: Double = 0.0
    @State var deltaE: Double = 0.0
    @State var deltaM: Double = 0.0
    @State var newEnergy: Double = 0.0
    @State var newMag: Double = 0.0
    @State var particleValue: Int = 0
    @State var f: Double = exp(1.0)
    @State var fTolerance: Double = 1e-5
    @State var stoppingPoint: Double = 10.0
    @State var stoppingPointEnergyAndMag: Double = 10.0
    @State var histogramData = [DensityOfStatesHistogram]()
    @State var energyAndMagHistogramData = [EnergyAndMagHistogramData]()
    @State var thermodynamicsPlotData = [ThermodynamicsPlot]()
    @State var trialConfigurationForCheck: [[Double]] = []
    @StateObject var mySpins = Spins()
    @StateObject var myEnergy = Energy()
    @StateObject var myDensityOfStates = DensityOfStates()
    //@State var myDensityOfStatesHistogram = [DensityOfStatesHistogram]()
    //    @StateObject var myPotential = Potential()
    @StateObject var twoDMagnet = TwoDMagnet()
    let upColor = Color(red: 0.25, green: 0.5, blue: 0.75)
    let downColor = Color(red: 0.75, green: 0.5, blue: 0.25)
    @State var spinWidth = 25
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    Text("Density of States g(E)")
                    Chart {
                        ForEach(histogramData, id: \.energies) { item in
                            BarMark(
                                x: .value("Energy", item.energies),
                                y: .value("Density of States", item.densityOfStates)
                            )
                        }
                    }
                    .padding()
                }
                VStack {
                    Text("Histogram from g(E)")
                    Chart {
                        ForEach(histogramData, id: \.energies) { item in
                            BarMark(
                                x: .value("Energy", item.energies),
                                y: .value("Histogram", item.histogram)
                            )
                        }
                    }
                    .padding()
                }
                VStack {
                    Text("Histogram from g(E,M)")
                    Chart {
                        ForEach(energyAndMagHistogramData, id: \.energyAndMags) { item in
                            BarMark(
                                x: .value("Energy", item.energyAndMags),
                                y: .value("Histogram", item.energyAndMagHistogram)
                            )
                        }
                    }
                    .padding()
                }
                VStack {
                    Text("Specific Heat vs. T")
                    Chart {
                        ForEach(thermodynamicsPlotData, id: \.kT) { item in
                            BarMark(
                                x: .value("kT", item.kT),
                                y: .value("Specific Heat", item.specificHeat)
                            )
                        }
                    }
                    .padding()
                }
            }
            
            HStack {
                Text("N:")
                TextField("N:", text: $Num)
                    .padding()
        
                Text("kT:")
                TextField("kT:", text: $kT)
                    .padding()
                
                Button("Start", action: startWangLandau)
                    .padding()
            }
        }
    }
    
    func clearParameters () {
        myEnergy.energy = []
        myEnergy.possibleEnergyArray = []
        myEnergy.deltaEValues = []
        mySpins.spinConfiguration = []
        mySpins.plotSpinConfiguration = []
        myDensityOfStates.lnDensityOfStates = []
        histogramData = []
        //        twoDMagnet.plotSpinConfiguration = []
    }
    
    func calculateColdSpinConfiguration2D () async {
        mySpins.spinConfiguration = []
        let N = Int(Num)!
        var spinValue: [Double] = []
        for j in 1...N {
            for i in 1...(N) {
                if (j > 1) {
                    spinValue.removeLast()
                }
                spinValue.append(1.0)
            }
            mySpins.spinConfiguration.append(spinValue)
        }
        print(mySpins.spinConfiguration)
    }
    
    func calculateArbitrarySpinConfiguration2D () async{
        mySpins.spinConfiguration = []
        let N = Int(Num)!
        var spinValue: [Double] = []
        
        for j in 1...N {
            for i in 1...N {
                if (j > 1) {
                    spinValue.removeLast()
                }
                let s = Int.random(in: 0...1)
                spinValue.append(upOrDown[s])
            }
            mySpins.spinConfiguration.append(spinValue)
        }
        previousEnergy = -2*Double(N)
        //print(mySpins.spinConfiguration)
    }
    
    func calculateTrialConfiguration2D () async -> Bool {
        
        var isNegative = false
        particleValue = 0
        let N = Int(Num)!
        randParticleX = Int.random(in: 0...(N - 1))
        randParticleY = Int.random(in: 0...(N - 1))
        var trialConfiguration = mySpins.spinConfiguration
        particleValue = (randParticleX*N) + randParticleY
        
        if trialConfiguration[randParticleX][randParticleY] > 0 {
            isNegative = true
        }
        
        trialConfiguration[randParticleX][randParticleY] = trialConfiguration[randParticleX][randParticleY]*(-1.0)
        //print(trialConfiguration)
        trialConfigurationForCheck = trialConfiguration
        
         //print(trialConfiguration)
        
        return isNegative
    }
    
    func calculateDeltaE () async -> Double {
        let N = Int(Num)!
        
        if (randParticleX > 0 && randParticleX < (N-1) && randParticleY > 0 && randParticleY < (N-1)) {
            deltaE = (2*mySpins.spinConfiguration[randParticleX][randParticleY])*(mySpins.spinConfiguration[randParticleX+1][randParticleY] + mySpins.spinConfiguration[randParticleX-1][randParticleY] + mySpins.spinConfiguration[randParticleX][randParticleY+1] + mySpins.spinConfiguration[randParticleX][randParticleY-1])
            myEnergy.deltaEValues.append(deltaE)
        }
        else if (randParticleX == 0 && randParticleY == 0) {
            deltaE = (2*mySpins.spinConfiguration[0][0])*(mySpins.spinConfiguration[1][0] + mySpins.spinConfiguration[0][1] + mySpins.spinConfiguration[N-1][0] + mySpins.spinConfiguration[0][N-1])
            myEnergy.deltaEValues.append(deltaE)
        }
        else if (randParticleX == 0 && randParticleY == (N-1)) {
            deltaE = (2*mySpins.spinConfiguration[0][N-1])*(mySpins.spinConfiguration[0][N-2] + mySpins.spinConfiguration[1][N-1] + mySpins.spinConfiguration[N-1][N-1] + mySpins.spinConfiguration[0][0])
            myEnergy.deltaEValues.append(deltaE)
        }
        else if (randParticleX == (N-1) && randParticleY == 0) {
            deltaE = (2*mySpins.spinConfiguration[N-1][0])*(mySpins.spinConfiguration[N-1][1] + mySpins.spinConfiguration[N-2][0] + mySpins.spinConfiguration[N-1][N-1] + mySpins.spinConfiguration[0][0])
            myEnergy.deltaEValues.append(deltaE)
        }
        else if (randParticleX == (N-1) && randParticleY == (N-1)) {
            deltaE = (2*mySpins.spinConfiguration[N-1][N-1])*(mySpins.spinConfiguration[N-2][N-1] + mySpins.spinConfiguration[N-1][0] + mySpins.spinConfiguration[N-1][N-2] + mySpins.spinConfiguration[0][N-1])
            myEnergy.deltaEValues.append(deltaE)
        }
        // 0<x<N-1   y = N-1
        else if (randParticleX > 0 && randParticleX < (N-1) && randParticleY == (N-1)) {
            deltaE = (2*mySpins.spinConfiguration[randParticleX][randParticleY])*(mySpins.spinConfiguration[randParticleX+1][randParticleY] + mySpins.spinConfiguration[randParticleX-1][randParticleY] + mySpins.spinConfiguration[randParticleX][randParticleY-1] + mySpins.spinConfiguration[randParticleX][0])
        }
        // 0<x<N-1   y = 0
        else if (randParticleX > 0 && randParticleX < (N-1) && randParticleY == 0) {
            deltaE = (2*mySpins.spinConfiguration[randParticleX][randParticleY])*(mySpins.spinConfiguration[randParticleX+1][randParticleY] + mySpins.spinConfiguration[randParticleX-1][randParticleY] + mySpins.spinConfiguration[randParticleX][randParticleY+1] + mySpins.spinConfiguration[randParticleX][N-1])
            myEnergy.deltaEValues.append(deltaE)
        }
        // 0 < y < N-1     x = 0
        else if (randParticleY > 0 && randParticleY < (N-1) && randParticleX == 0) {
            deltaE = (2*mySpins.spinConfiguration[randParticleX][randParticleY])*(mySpins.spinConfiguration[randParticleX][randParticleY+1] + mySpins.spinConfiguration[randParticleX][randParticleY-1] + mySpins.spinConfiguration[randParticleX+1][randParticleY] + mySpins.spinConfiguration[N-1][randParticleY])
            myEnergy.deltaEValues.append(deltaE)
        }
        // 0 < y < N-1     x = N-1
        else if (randParticleY > 0 && randParticleY < (N-1) && randParticleX == N-1) {
            deltaE = (2*mySpins.spinConfiguration[randParticleX][randParticleY])*(mySpins.spinConfiguration[randParticleX][randParticleY+1] + mySpins.spinConfiguration[randParticleX][randParticleY-1] + mySpins.spinConfiguration[randParticleX-1][randParticleY] + mySpins.spinConfiguration[0][randParticleY])
            myEnergy.deltaEValues.append(deltaE)
        }
        // print("Delta E:")
        // print(deltaE)
        return deltaE
    }
    
    func calculateColdDensityOfStates () async{
        let N = Double(Num)!
        let totalSpins = pow(N, 2.0)
        let spinTotal = Int(totalSpins)
        
        for i in 0...spinTotal {
            // 0.0 because ln(1) = 0 and in ln form
            myDensityOfStates.lnDensityOfStates.append(0.0)
        }
        print("Density of States: ")
        print(myDensityOfStates.lnDensityOfStates)
    }
    
    func calculateHistogramData () async {
        let N = Double(Num)!
        let totalSpins = pow(N, 2.0)
        let spinTotal = Int(totalSpins)
        let possibleMagnetismValues = Int(0)
        var ENERGY = Double(0.0)
        myDensityOfStates.histogram = []
        myDensityOfStates.densityOfStatesEnergyandMag = []
        
        for i in 0...spinTotal {
            // 0.0 because ln(1) = 0 and in ln form
            myDensityOfStates.histogram.append(0.0)
            
            for M in stride(from: -spinTotal, through: spinTotal, by: 2) {
                myDensityOfStates.energyAndMags.append(Double(M))
                myDensityOfStates.densityOfStatesEnergyandMag.append(0.0)
            }
        }
        
        //  print("Histogram: ")
        //  print(myDensityOfStates.histogram)
    }
    
    // Adds 1 to g(newEnergy) and multiplies by f in case need to change
    // Do this on acceptance of trial
    
    func calculateLnTrialDensityOfStates (gIndexTrial: Int) -> [Double] {
        let N = Double(Num)!
        let totalSpins = pow(N, 2.0)
        let spinTotal = Int(totalSpins)
        var lnTrialDensityOfStates = myDensityOfStates.lnDensityOfStates
        //indices 0...(2^N-1)
        lnTrialDensityOfStates[gIndexTrial] = lnTrialDensityOfStates[gIndexTrial] + log(f)
        
        //  print("Density of States:")
        //   print(lnTrialDensityOfStates)
        return lnTrialDensityOfStates
    }
    
    func calculatePreviousEnergySpinConfiguration (x: Int) async {
        
        if x > 0 {
            previousEnergy = myEnergy.energy[x]
            previousMag = myEnergy.magnetism[x]
            //    print("Previous Energy:")
            //    print(myEnergy.energy[x])
        }
    }
    
    
    func calculatePossibleEnergiesAndMagnetisms () async {
        let N = Double(Num)!
        let totalSpins = pow(N, 2.0)
        let spinTotal = Int(totalSpins)
        var energyValue: Double = 0.0
        
            for Eprime in 0...spinTotal {
                
                energyValue = Double(4*Eprime) - Double(2*spinTotal)
                myEnergy.possibleEnergyArray.append(energyValue)
                
                for M in stride(from: -spinTotal, through: spinTotal, by: 2) {
                    let bob = (E: energyValue, M: Double(M))
                    myEnergy.possibleEnergyAndMagValues.append(bob)
                }
            }
        //    print("Amount of Possible Energies: ")
        //    print(myEnergy.possibleEnergyArray.count)
        //    print("Possible Energies: ")
        //    print(myEnergy.possibleEnergyArray)
        }

    
    func calculateGIndexes () async -> [Int] {
        var gIndexTrial: Int = 0
        var gIndexPrevious: Int = 0

        var energyAndMagHistogramIndexTrial: Int = 0
        var energyAndMagHistogramIndexPrevious: Int = 0

        //[gIndexTrial, gIndexPrevious, energyAndMagHistogramIndexTrial, energyAndMagHistogramIndexPrevious]
        var gIndexes: [Int] = []
        
        gIndexTrial = myEnergy.possibleEnergyArray.firstIndex(of: newEnergy)!
        gIndexes.append(gIndexTrial)
        
        gIndexPrevious = myEnergy.possibleEnergyArray.firstIndex(of: previousEnergy)!
        gIndexes.append(gIndexPrevious)
        
        for Index1 in 0...myEnergy.possibleEnergyAndMagValues.count-1 {
            if myEnergy.possibleEnergyAndMagValues[Index1] == (newEnergy, newMag){
                energyAndMagHistogramIndexTrial = Index1
                gIndexes.append(energyAndMagHistogramIndexTrial)
            }
        }
        for Index2 in 0...myEnergy.possibleEnergyAndMagValues.count-1 {
            if myEnergy.possibleEnergyAndMagValues[Index2] == (previousEnergy, newMag){
                energyAndMagHistogramIndexPrevious = Index2
                gIndexes.append(energyAndMagHistogramIndexPrevious)
            }
        }
        return gIndexes
    }
    
    func calculateGIndexOfPreviousFromPossibleEnergies () -> Int {
        var gIndexPrevious: Int = 0
        gIndexPrevious = myEnergy.possibleEnergyArray.firstIndex(of: previousEnergy)!
        return gIndexPrevious
    }
    
    func calculateProbabilityOfAcceptance (gIndexTrial: Int, gIndexPrevious: Int) async -> Double {
        var P: Double = 0.0
        var lnTrialDensityOfStates = calculateLnTrialDensityOfStates(gIndexTrial: gIndexTrial)
        
        
        P = exp(myDensityOfStates.lnDensityOfStates[gIndexPrevious] - myDensityOfStates.lnDensityOfStates[gIndexTrial])
        
        return P
    }
    
    func calculateDensityOfStatesCheck () async {
        let gIndexes = await calculateGIndexes()
        let uniformRandomNumber = Double.random(in: 0...1)
        let gIndexTrial = gIndexes[0]
        let gIndexPrevious = gIndexes[1]
        let energyAndMagnetismIndexTrial = gIndexes[2]
        let energyAndMagnetismIndexPrevious = gIndexes[3]
        
        if (myDensityOfStates.lnDensityOfStates[gIndexTrial] <= myDensityOfStates.lnDensityOfStates[gIndexPrevious]) {
            
            // Make the trial configuration the new spin configuration
            mySpins.spinConfiguration = trialConfigurationForCheck
            // Add 1 to Density of States and Multiply by f
            myDensityOfStates.histogram[gIndexTrial] += 1.0
            myDensityOfStates.lnDensityOfStates[gIndexTrial] += log(f)
            myDensityOfStates.densityOfStatesEnergyandMag[energyAndMagnetismIndexTrial] += 1.0
            // Append the energy of the trial configuration to the energy array
            myEnergy.energy.append(newEnergy)
            myEnergy.magnetism.append(newMag)
            
            //myEnergy.energyAndMagValues[(E: newEnergy, M: newMag)] += 1.0
            
            let bob = (E: newEnergy, M:newMag)
            //print(bob)
            myEnergy.energyAndMagValues.append(bob)
            //            print("Trial Accepted")
                    }
        else if (myDensityOfStates.lnDensityOfStates[gIndexTrial] > myDensityOfStates.lnDensityOfStates[gIndexPrevious]) {
                let P = await calculateProbabilityOfAcceptance(gIndexTrial: gIndexTrial, gIndexPrevious: gIndexPrevious)
                if (P >= uniformRandomNumber) {
                    
                    // Make the trial configuration the new spin configuration
                    mySpins.spinConfiguration = trialConfigurationForCheck
                    // Add 1 to Density of States and Multiply by f
                    myDensityOfStates.histogram[gIndexTrial] += 1.0
                    myDensityOfStates.lnDensityOfStates[gIndexTrial] += log(f)
                    myDensityOfStates.densityOfStatesEnergyandMag[energyAndMagnetismIndexTrial] += 1.0
                    //                for i in 0..<myDensityOfStates.densityOfStates.count {
                    //                    myDensityOfStates.densityOfStates[i] = myDensityOfStates.densityOfStates[i] + log(f)
                    //                }
                    // Append the energy of the trial configuration to the energy array
                    myEnergy.energy.append(newEnergy)
                    myEnergy.magnetism.append(newMag)
                    
                    let bob = (E: newEnergy, M: newMag)
                    //print(bob)
                    myEnergy.energyAndMagValues.append(bob)
                    
                    //                print("Trial Accepted")
                    
                    //                print(myDensityOfStates.lnDensityOfStates)
                }
            else if (P < uniformRandomNumber) {
                    
                    myDensityOfStates.histogram[gIndexPrevious] += 1.0
                    myDensityOfStates.lnDensityOfStates[gIndexPrevious] += log(f)
                    myDensityOfStates.densityOfStatesEnergyandMag[energyAndMagnetismIndexPrevious] += 1.0
                    
                    myEnergy.energy.append(previousEnergy)
                    myEnergy.magnetism.append(previousMag)
                    
                    let bob = (E: previousEnergy, M:previousMag)
                    //print(bob)
                    myEnergy.energyAndMagValues.append(bob)
                    //                print("Trial Rejected")
                    //                print(myDensityOfStates.lnDensityOfStates)
                    
                }
            }
        //print(myDensityOfStates.densityOfStatesEnergyandMag)
    }
    
    /// Equation for Calculating the Specific Heat from Wang Landau Paper: "Efficient, Multiple-Range Random Walk Algorithm to Calculate the Density of States"
    ///                 <E^2>_T - <E>_T^2
    ///         C =     ---------------------------------------
    ///                       T^2
    ///
    /// Where:
    ///                    _
    ///                    |     E*g(E)*exp(-BE)
    ///         <E>_T = sum|     ---------------------------
    ///                    |       g(E)*exp(-BE)
    ///                    -
    
    func calculateSpecificHeat () async {
        
        var specificHeat: Double = 0.0
        var eT: [Double] = []
        var EsubT: Double = 0.0
        var ESquaredT: Double = 0.0
        var beta: Double = 1.0
        var sumNumerator1: Double = 0.0
        var sumDenominator1: Double = 0.0
        var sumNumerator2: Double = 0.0
        var sumDenominator2: Double = 0.0
        
            for T in 0...(kTArray.count - 1) {
            
                    for i in 0...(myEnergy.possibleEnergyArray.count - 1) {
                        sumNumerator1 += myEnergy.possibleEnergyArray[i]*myDensityOfStates.lnDensityOfStates[i]*exp(-kTArray[T]*myEnergy.possibleEnergyArray[i])
                        sumDenominator1 += myDensityOfStates.lnDensityOfStates[i]*exp(-kTArray[T]*myEnergy.possibleEnergyArray[i])
                        sumNumerator2 += pow(myEnergy.possibleEnergyArray[i],2)*myDensityOfStates.lnDensityOfStates[i]*exp(-kTArray[T]*myEnergy.possibleEnergyArray[i])
                        sumDenominator2 += pow(myEnergy.possibleEnergyArray[i],2)*myDensityOfStates.lnDensityOfStates[i]*exp(-kTArray[T]*myEnergy.possibleEnergyArray[i])
                    }
                EsubT = sumNumerator1/sumDenominator1
                ESquaredT = sumNumerator2/sumDenominator2

                specificHeat = (ESquaredT - pow(EsubT,2))/pow(kTArray[T],2)
                specificHeatArray.append(specificHeat)
        }
        //Will return an array of specific heats and already have an array of kT values 1-10 so can plot all of that.
    }
    
    func calculatePlotData (BobArray: [Double]) async {
        
        for i in 0...(myEnergy.possibleEnergyArray.count - 1) {
            
            histogramData.append(DensityOfStatesHistogram(energies: myEnergy.possibleEnergyArray[i], densityOfStates: BobArray[i], histogram: myDensityOfStates.histogram[i]))
        }
        
        for i in 0...(myEnergy.possibleEnergyArray.count - 1) {
            
            energyAndMagHistogramData.append(EnergyAndMagHistogramData(energyAndMags: myDensityOfStates.energyAndMags[i], energyAndMagHistogram: myDensityOfStates.densityOfStatesEnergyandMag[i]))
        }
        
        for i in 0...(kTArray.count-1) {
            thermodynamicsPlotData.append(ThermodynamicsPlot(kT: kTArray[i], specificHeat: specificHeatArray[i]))
        }
        
    }
    
    func startWangLandau () {
        Task {await calculateWangLandaufromCold()}
    }
    
    func calculateWangLandaufromCold () async {
        myEnergy.energy = []
        myEnergy.possibleEnergyArray = []
        myEnergy.magnetism = []
        myEnergy.deltaMValues = []
        let N = Int(Num)!
        await calculateColdSpinConfiguration2D()
        await calculatePossibleEnergiesAndMagnetisms()
        await calculateColdDensityOfStates()
        await calculateHistogramData()
        let something = Double(N)
        let totalSpins = pow(something, 2.0)
        let spinTotal = Int(totalSpins)
        previousEnergy = -2*totalSpins
        previousMag = totalSpins
        myEnergy.energy.append(previousEnergy)
        myEnergy.magnetism.append(previousMag)
        myEnergy.deltaEValues.append(0.0)
        myEnergy.deltaMValues.append(0.0)
        
        myEnergy.energyAndMagValues.append((E:previousEnergy, M:previousMag))
        //        myDensityOfStates.lnDensityOfStates.append()
        
        var x: Int = 0
        var containZeroes = true
        var containZeroesEnergy = true
        var containZeroesMag = true
        
        while f >= (1 + fTolerance) {
            // for x in 0...10000 {
            let isNegative = await calculateTrialConfiguration2D()
            await calculatePreviousEnergySpinConfiguration(x: x)
            deltaE = 0.0
            deltaE = await calculateDeltaE()
            newEnergy = deltaE + previousEnergy
            if isNegative {
                
                deltaM = -2.0
            }
            else{
                
                deltaM = 2.0
            }
            
            newMag = previousMag + deltaM
            
            await calculateDensityOfStatesCheck()
            x += 1
            //print(x)
            // }
            if (x.isMultiple(of: 50000) == true) {
                
                var currentMinimumDOS = 10000000.0
                var currentMinimumEnergy = 10000000.0
                var currentMinimumMag = 10000000.0
                var zeros = 0
                // spinTotal = N^2
                for i in 0...spinTotal {
                    if (myDensityOfStates.histogram[i] < currentMinimumDOS) && i != 1 && i != (spinTotal-1) {
                        currentMinimumDOS = myDensityOfStates.histogram[i]
                        
                    //Check if there are any zeros
                        if abs(currentMinimumDOS) <= 1e-12 {
                            containZeroes = true
                            zeros += 1
                        }
                        
                        else {
                            containZeroes = false
                        }
                    }
                    
//                    let energyAndMagValuesLength = Int(myEnergy.energyAndMagValues.count)
//                    for i in 0...energyAndMagValuesLength-1 {
//                        if (myEnergy.energyAndMagValues[i].0 < currentMinimumEnergy) && i != 1 && i != (energyAndMagValuesLength-1){
//                            currentMinimumEnergy = myEnergy.energyAndMagValues[i].0
//
//                            //Check if there are any zeros
//                            if abs(currentMinimumEnergy) <= 1e-12 {
//                                containZeroesEnergy = true
//                                zeros += 1
//                            }
//
//                            else {
//                                containZeroesEnergy = false
//                            }
//
//                        }
//
//                    if (myEnergy.energyAndMagValues[i].1 < currentMinimumMag) && i != 1 && i != (energyAndMagValuesLength-1){
//                        currentMinimumMag = myEnergy.energyAndMagValues[i].1
//
//                        //Check if there are any zeros
//                        if abs(currentMinimumMag) <= 1e-12 {
//                            containZeroesMag = true
//                            zeros += 1
//                        }
//
//                        else {
//                            containZeroesMag = false
//                        }
//
//                    }
//                }
                    
                }
                    if (zeros == 0) {
                        
                        let densityMax: Double = myDensityOfStates.histogram.max()!
                        //let densityMin = currentMinimum
                        let densityMin = getMin(value1: myDensityOfStates.histogram)
                        let energyAndMagDOSMax: Double = myDensityOfStates.densityOfStatesEnergyandMag.max()!
                        let energyAndMagDOSMin = getMin(value1: myDensityOfStates.densityOfStatesEnergyandMag)
                        
                        stoppingPoint = (densityMax - densityMin)/(densityMax + densityMin)
                        stoppingPointEnergyAndMag = (energyAndMagDOSMax - energyAndMagDOSMin)/(energyAndMagDOSMax + energyAndMagDOSMin)
                        
//                        if (stoppingPoint < 0.2) && (stoppingPointEnergyAndMag < 0.2) {
                        if (stoppingPoint < 0.2) {
                                f = sqrt(f)
                            if f < (1 + fTolerance){}
                            else {
                                    await calculateHistogramData()
                            }
                            //print(myDensityOfStates.lnDensityOfStates)
                        }
                        print(String("f value: ") + String(f))
                        print(String("Iteration: ") + String(x))
                    }
                }
            }
        
        print("Final Density of States Calculated!")
        var lnDOSForPlot = myDensityOfStates.lnDensityOfStates
        var BobArray :[Double] = []
        for i in 0..<(myDensityOfStates.lnDensityOfStates.count) {
            BobArray.append(lnDOSForPlot[i] - lnDOSForPlot[0] + log(2))
            // exp(lnDOSForPlot[i] - lnDOSForPlot[0] + log(2))             // probably 24 or 25
            if BobArray[i] < 0.0 {
                BobArray[i] = 0.0
            }
        }
        await calculatePlotData(BobArray: BobArray)
        await calculateSpecificHeat()
        
        print("Bob")
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
