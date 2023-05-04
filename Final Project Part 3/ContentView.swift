//
//  ContentView.swift
//  Final Project Part 3
//
//  Created by IIT PHYS 440 on 4/28/23.
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
    @State var randParticleX: Int = 0
    @State var randParticleY: Int = 0
    @State var potentialArray: [Double] = []
    @State var previousEnergy: Double = 0.0
    @State var energy: Double = 0.0
    @State var deltaE: Double = 0.0
    @State var newEnergy: Double = 0.0
    @State var particleValue: Int = 0
    @State var f: Double = Double.pi
    @State var fTolerance: Double = 1e-8
    @State var stoppingPoint: Double = 10.0
    @State var histogramData = [DensityOfStatesHistogram]()
    @State var trialConfigurationForCheck: [[Double]] = []
    @StateObject var mySpins = Spins()
    @StateObject var myEnergy = Energy()
    @StateObject var myDensityOfStates = DensityOfStates()
    @State var myDensityOfStatesHistogram = [DensityOfStatesHistogram]()
    //    @StateObject var myPotential = Potential()
    @StateObject var twoDMagnet = TwoDMagnet()
    let upColor = Color(red: 0.25, green: 0.5, blue: 0.75)
    let downColor = Color(red: 0.75, green: 0.5, blue: 0.25)
    @State var spinWidth = 25
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    Text("Density of States")
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
                    Text("Histogram")
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
            }
            
            HStack {
                Text("N:")
                TextField("N:", text: $Num)
                    .padding()
            }
            HStack {
                Text("kT:")
                TextField("kT:", text: $kT)
                    .padding()
            }
            //                Button(action: {
            //                    self.calculateColdSpinConfiguration2D()})
            //                {Text("Calculate Cold Spin Configuration")}
            
        }
        
        //            VStack(){
        //                TimelineView(.animation) { timeline in
        //                    Canvas { context, size in
        //                        twoDMagnet.update(to: timeline.date)
        //
        //                        for spin in twoDMagnet.plotSpinConfiguration.plotSpinConfiguration {
        //                            let rect = CGRect(x: spin.x * (size.width/CGFloat(spinWidth)), y: spin.y * (size.height/CGFloat(spinWidth)), width: (size.height/CGFloat(spinWidth)), height: (size.height/CGFloat(spinWidth)))
        //                            let shape = Rectangle().path(in: rect)
        //                            if (spin.spin){
        //                                context.fill(shape, with: .color(upColor))}
        //                            else{
        //                                context.fill(shape, with: .color(downColor))
        //                            }
        //                        }
        //                    }
        //                }
        //                .background(.black)
        //                .ignoresSafeArea()
        //                .padding()
        
        
        //                Button("Start from Cold", action: setupColdSpins)
        //   Button("Start from Arbitrary", action: setupArbitrarySpins)
        
        Button("Start from Cold", action: calculateWangLandaufromCold)
        
        //        Button("Start from Arbitrary", action: calculateWangLandaufromArbitrary)
        
        Button("Clear", action: clearParameters)
    }
    
    
    //    func setupSpinsfromCold(){
    //        let N = Double(Num)!
    //        spinWidth = Int(N)
    //        var currentSpinValue = true
    //        self.calculateColdSpinConfiguration2D()
    //
    //        for j in 0..<spinWidth {
    //            for i in 0..<spinWidth {
    //                if (mySpins.spinConfiguration[i][j] == 1.0) {
    //                                    currentSpinValue = true
    //                                }
    //                                else {
    //                                    currentSpinValue = false
    //                                }
    //                twoDMagnet.plotSpinConfiguration.plotSpinConfiguration.append(Spin(x: Double(i), y: Double(j), spin: currentSpinValue))
    //            }
    //        }
    //    }
    //
    //    func changeSpinsfromCold(){
    //        Task{
    //            await self.calculateWangLandau()
    //            }
    //        }
    //
    //    func setupSpinsfromArbitrary(){
    //        let N = Double(Num)!
    //        spinWidth = Int(N)
    //        var currentSpinValue = true
    //        self.calculateArbitrarySpinConfiguration2D()
    //
    //        for j in 0..<spinWidth {
    //            for i in 0..<spinWidth {
    //                if (mySpins.spinConfiguration[i][j] == 1.0) {
    //                                    currentSpinValue = true
    //                                }
    //                                else {
    //                                    currentSpinValue = false
    //                                }
    //                twoDMagnet.plotSpinConfiguration.plotSpinConfiguration.append(Spin(x: Double(i), y: Double(j), spin: currentSpinValue))
    //            }
    //        }
    //    }
    //
    //    func changeSpinsfromArbitrary(){
    //        Task{
    //            await self.calculateWangLandau()
    //            }
    //        }
    //
    //    func setupColdSpins() -> [[Double]] {
    //        let N = Double(Num)!
    //        self.clearParameters ()
    //        self.calculateColdSpinConfiguration2D()
    //        return mySpins.spinConfiguration
    //    }
    
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
    
    func calculateColdSpinConfiguration2D (){
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
    
    func calculateArbitrarySpinConfiguration2D (){
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
    
    func calculateTrialConfiguration2D () {
        particleValue = 0
        let N = Int(Num)!
        randParticleX = Int.random(in: 0...(N - 1))
        randParticleY = Int.random(in: 0...(N - 1))
        var trialConfiguration = mySpins.spinConfiguration
        particleValue = (randParticleX*N) + randParticleY
        
        trialConfiguration[randParticleX][randParticleY] = trialConfiguration[randParticleX][randParticleY]*(-1.0)
        //print(trialConfiguration)
        trialConfigurationForCheck = trialConfiguration
        
        print(trialConfiguration)
    }
    
    func calculateDeltaE () -> Double {
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
        print("Delta E:")
        print(deltaE)
        return deltaE
    }
    
    func calculateColdDensityOfStates () {
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
    
    func calculateHistogramData () {
        let N = Double(Num)!
        let totalSpins = pow(N, 2.0)
        let spinTotal = Int(totalSpins)
        
        for i in 0...spinTotal {
            // 0.0 because ln(1) = 0 and in ln form
            myDensityOfStates.histogram.append(0.0)
        }
        print("Histogram: ")
        print(myDensityOfStates.histogram)
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
        
        print("Density of States:")
        print(lnTrialDensityOfStates)
        return lnTrialDensityOfStates
    }
    
    func calculatePreviousEnergySpinConfiguration (x: Int) {
        
        if x > 0 {
            previousEnergy = myEnergy.energy[x]
            print("Previous Energy:")
            print(myEnergy.energy[x])
        }
    }
    
    
    func calculatePossibleEnergies () {
        let N = Double(Num)!
        let totalSpins = pow(N, 2.0)
        let spinTotal = Int(totalSpins)
        var energyValue: Double = 0.0
        
        for Eprime in 0...spinTotal {
            energyValue = Double(4*Eprime) - Double(2*spinTotal)
            myEnergy.possibleEnergyArray.append(energyValue)
        }
        
        print("Amount of Possible Energies: ")
        print(myEnergy.possibleEnergyArray.count)
        print("Possible Energies: ")
        print(myEnergy.possibleEnergyArray)
    }
    
    func calculateGIndexOfTrialFromPossibleEnergies () -> Int {
        var gIndexTrial: Int = 0
        gIndexTrial = myEnergy.possibleEnergyArray.firstIndex(of: newEnergy)!
        return gIndexTrial
    }
    
    func calculateGIndexOfPreviousFromPossibleEnergies () -> Int {
        var gIndexPrevious: Int = 0
        gIndexPrevious = myEnergy.possibleEnergyArray.firstIndex(of: previousEnergy)!
        return gIndexPrevious
    }
    
    func calculateProbabilityOfAcceptance (gIndexTrial: Int, gIndexPrevious: Int) -> Double {
        var P: Double = 0.0
        var lnTrialDensityOfStates = calculateLnTrialDensityOfStates(gIndexTrial: gIndexTrial)
        
        
        P = exp(myDensityOfStates.lnDensityOfStates[gIndexPrevious] - myDensityOfStates.lnDensityOfStates[gIndexTrial])
        
        return P
    }
    
    func calculateDensityOfStatesCheck () {
        let gIndexTrial = calculateGIndexOfTrialFromPossibleEnergies()
        let gIndexPrevious = calculateGIndexOfPreviousFromPossibleEnergies()
        let uniformRandomNumber = Double.random(in: 0...1)
        
        if (myDensityOfStates.lnDensityOfStates[gIndexTrial] <= myDensityOfStates.lnDensityOfStates[gIndexPrevious]) {
            
            // Make the trial configuration the new spin configuration
            mySpins.spinConfiguration = trialConfigurationForCheck
            // Add 1 to Density of States and Multiply by f
            myDensityOfStates.histogram[gIndexTrial] += 1.0
            myDensityOfStates.lnDensityOfStates[gIndexTrial] = myDensityOfStates.lnDensityOfStates[gIndexTrial] + log(f)
            //            for i in 0..<myDensityOfStates.densityOfStates.count {
            //                myDensityOfStates.densityOfStates[i] = myDensityOfStates.densityOfStates[i] + log(f)
            //            }
            // Append the energy of the trial configuration to the energy array
            myEnergy.energy.append(newEnergy)
            print("Trial Accepted")
        }
        else if (myDensityOfStates.lnDensityOfStates[gIndexTrial] > myDensityOfStates.lnDensityOfStates[gIndexPrevious]) {
            let P = calculateProbabilityOfAcceptance(gIndexTrial: gIndexTrial, gIndexPrevious: gIndexPrevious)
            if (P >= uniformRandomNumber) {
                
                // Make the trial configuration the new spin configuration
                mySpins.spinConfiguration = trialConfigurationForCheck
                // Add 1 to Density of States and Multiply by f
                myDensityOfStates.histogram[gIndexTrial] += 1.0
                myDensityOfStates.lnDensityOfStates[gIndexTrial] = myDensityOfStates.lnDensityOfStates[gIndexTrial] + log(f)
                //                for i in 0..<myDensityOfStates.densityOfStates.count {
                //                    myDensityOfStates.densityOfStates[i] = myDensityOfStates.densityOfStates[i] + log(f)
                //                }
                // Append the energy of the trial configuration to the energy array
                myEnergy.energy.append(newEnergy)
                print("Trial Accepted")
            }
            else if (P < uniformRandomNumber) {
                myEnergy.energy.append(previousEnergy)
                print("Trial Rejected")
            }
        }
    }
    
    func calculateWangLandaufromCold () {
        myEnergy.energy = []
        myEnergy.possibleEnergyArray = []
        let N = Int(Num)!
        calculateColdSpinConfiguration2D()
        calculatePossibleEnergies()
        calculateColdDensityOfStates()
        calculateHistogramData()
        let something = Double(N)
        let totalSpins = pow(something, 2.0)
        let spinTotal = Int(totalSpins)
        previousEnergy = -2*totalSpins
        myEnergy.energy.append(previousEnergy)
        
//       while f >= (1 + fTolerance) {
        for x in 0...1000000 {
                calculateTrialConfiguration2D()
                calculatePreviousEnergySpinConfiguration(x: x)
                deltaE = 0.0
                deltaE = calculateDeltaE()
                newEnergy = deltaE + previousEnergy
                calculateDensityOfStatesCheck()
        }
        
        let densityMax: Double = myDensityOfStates.histogram.max()!
        let densityMin: Double = myDensityOfStates.histogram.min()!
        stoppingPoint = (densityMax - densityMin)/(densityMax + densityMin)
        
    if (stoppingPoint < 0.2) {
        f = sqrt(f)
    }
        
        for i in 0...(myEnergy.possibleEnergyArray.count - 1) {
            
            histogramData.append(DensityOfStatesHistogram(energies: myEnergy.possibleEnergyArray[i], densityOfStates: myDensityOfStates.lnDensityOfStates[i], histogram: myDensityOfStates.histogram[i]))
        }
//       }
        print("While Loop is Over!")
    }
}
//    func calculateWangLandaufromArbitrary () {
//        myEnergy.energy = []
//        myEnergy.possibleEnergyArray = []
//        myDensityOfStates.lnDensityOfStates = []
//        let N = Int(Num)!
//        calculateArbitrarySpinConfiguration2D()
//        calculatePossibleEnergies()
//        calculateColdDensityOfStates()
//        calculateHistogramData()
//        let something = Double(N)
//        let totalSpins = pow(something, 2.0)
//        let spinTotal = Int(totalSpins)
//        previousEnergy = -2*totalSpins
//        myEnergy.energy.append(previousEnergy)
//        myEnergy.deltaEValues.append(0.0)
//
//        while stoppingPoint > 0.2 {
//            for x in 0...spinTotal {
//                calculateTrialConfiguration2D()
//                calculatePreviousEnergySpinConfiguration(x: x)
//                deltaE = 0.0
//                deltaE = calculateDeltaE()
//                newEnergy = deltaE + previousEnergy
//                calculateDensityOfStatesCheck()
//
//                let densityMax: Double = myDensityOfStates.lnDensityOfStates.max()!
//                let densityMin: Double = myDensityOfStates.lnDensityOfStates.min()!
//                stoppingPoint = (densityMax - densityMin)/(densityMax + densityMin)
//
//                for i in 0...(myEnergy.possibleEnergyArray.count - 1) {
//                    histogramData.append(DensityOfStatesHistogram(energies: myEnergy.possibleEnergyArray[i], densityOfStates: myDensityOfStates.lnDensityOfStates[i], histogram: myDensityOfStates.histogram[i]))
//                }
//
//            }
//        }
//
//
//        print("While Loop is Over!")
//    }
//}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
