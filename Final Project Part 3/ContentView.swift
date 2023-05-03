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
    @State var kT: String = "100.0"
    @State var randParticleX: Int = 0
    @State var randParticleY: Int = 0
    @State var potentialArray: [Double] = []
    @State var previousEnergy: Double = 0.0
    @State var energy: Double = 0.0
    @State var deltaE: Double = 0.0
    @State var newEnergy: Double = 0.0
    @State var particleValue: Int = 0
    @State var f: Double = 1.0
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
        HStack {
            VStack {
                
                Chart {
                    ForEach(histogramData, id: \.energies) { item in
                        BarMark(
                            x: .value("Energy", item.energies),
                            y: .value("Density of States", item.densityOfStates)
                        )
                    }
                }
                .padding()
                
                
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
                //                Button(action: {
                //                    self.calculateArbitraryDensityOfStates()})
                //                {Text("Calculate Density of States")}
                //                Button(action: {
                //                    self.calculateTrialConfiguration2D()})
                //                {Text("Calculate Trial Configuration")}
                //                Button(action: {
                //                    self.calculateWangLandau()})
                //                {Text("Calculate Wang Landau")}
                //                Button(action: {
                //                    self.calculateArbitraryMetropolisAlgorithm2D()})
                //                {Text("Calculate Cold Metropolis Algorithm")}

            }
            
            VStack(){
                TimelineView(.animation) { timeline in
                    Canvas { context, size in
                        twoDMagnet.update(to: timeline.date)
                        
                        for spin in twoDMagnet.plotSpinConfiguration.plotSpinConfiguration {
                            let rect = CGRect(x: spin.x * (size.width/CGFloat(spinWidth)), y: spin.y * (size.height/CGFloat(spinWidth)), width: (size.height/CGFloat(spinWidth)), height: (size.height/CGFloat(spinWidth)))
                            let shape = Rectangle().path(in: rect)
                            if (spin.spin){
                                context.fill(shape, with: .color(upColor))}
                            else{
                                context.fill(shape, with: .color(downColor))
                            }
                        }
                    }
                }
                .background(.black)
                .ignoresSafeArea()
                .padding()
                
                
                //                Button("Start from Cold", action: setupColdSpins)
                //   Button("Start from Arbitrary", action: setupArbitrarySpins)
                
                Button("Start from Cold", action: setupSpinsfromCold)
                Button("SpinMeCold", action: changeSpinsfromCold)
                
                Button("Start from Arbitrary", action: setupSpinsfromArbitrary)
                Button("SpinMeArbitrary", action: changeSpinsfromArbitrary)
            }
        }
        }
    
    func setupSpinsfromCold(){
        let N = Double(Num)!
        spinWidth = Int(N)
        var currentSpinValue = true
        self.calculateColdSpinConfiguration2D()
        
        for j in 0..<spinWidth {
            for i in 0..<spinWidth {
                if (mySpins.spinConfiguration[i][j] == 0.5) {
                                    currentSpinValue = true
                                }
                                else {
                                    currentSpinValue = false
                                }
                twoDMagnet.plotSpinConfiguration.plotSpinConfiguration.append(Spin(x: Double(i), y: Double(j), spin: currentSpinValue))
            }
        }
    }
    
    func changeSpinsfromCold(){
        Task{
            await self.calculateWangLandau()
            }
        }
    
    func setupSpinsfromArbitrary(){
        let N = Double(Num)!
        spinWidth = Int(N)
        var currentSpinValue = true
        self.calculateArbitrarySpinConfiguration2D()
        
        for j in 0..<spinWidth {
            for i in 0..<spinWidth {
                if (mySpins.spinConfiguration[i][j] == 0.5) {
                                    currentSpinValue = true
                                }
                                else {
                                    currentSpinValue = false
                                }
                twoDMagnet.plotSpinConfiguration.plotSpinConfiguration.append(Spin(x: Double(i), y: Double(j), spin: currentSpinValue))
            }
        }
    }
    
    func changeSpinsfromArbitrary(){
        Task{
            await self.calculateWangLandau()
            }
        }
    
    func setupColdSpins() -> [[Double]] {
        let N = Double(Num)!
        self.clearParameters ()
        self.calculateColdSpinConfiguration2D()
        return mySpins.spinConfiguration
    }
    
    func clearParameters () {
        myEnergy.energy = []
        mySpins.spinConfiguration = []
        myDensityOfStates.densityOfStates = []
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
                spinValue.append(-1.0)
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
    
    func calculateTrialConfiguration2D () -> [[Double]] {
        particleValue = 0
        let N = Int(Num)!
        randParticleX = Int.random(in: 0...(N - 1))
        randParticleY = Int.random(in: 0...(N - 1))
        var trialConfiguration = mySpins.spinConfiguration
        particleValue = (randParticleX*N) + randParticleY
        
        if (trialConfiguration[randParticleX][randParticleY] == 1.0) {
            trialConfiguration[randParticleX][randParticleY] = -1.0
        }
        else {
            trialConfiguration[randParticleX][randParticleY] = 1.0
        }
        //print(trialConfiguration)
        trialConfigurationForCheck = trialConfiguration
        
        print("Particle i Value for g(E):")
        print(particleValue)
        print(trialConfiguration)
        return trialConfiguration
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
    
    func calculateArbitraryDensityOfStates () {
        let N = Int(Num)!
//        let upperLimit = pow(N, 2.0)
        
//indices 0...(2^N-1)
        for i in 0...N {
// 0.0 because ln(1) = 0 and in ln form
            let gLogValue = log(1.0)
            myDensityOfStates.densityOfStates.append(1.0)
        }
        print("Density of States: ")
        print(myDensityOfStates.densityOfStates)
    }
    
    // Adds 1 to g(newEnergy) and multiplies by f in case need to change
    // Do this on acceptance of trial
    
    func calculateTrialDensityOfStates (gIndexTrial: Int) -> [Double] {
        let N = Int(Num)!
        var trialDensityOfStates = myDensityOfStates.densityOfStates
//indices 0...(2^N-1)
        trialDensityOfStates[gIndexTrial] += (1.0)
        for i in 0...N {
            trialDensityOfStates[i] = f*trialDensityOfStates[i]
        }
        print("Density of States:")
        print(trialDensityOfStates)
        return trialDensityOfStates
        }
    
    func calculatePreviousEnergySpinConfiguration (x: Int) {

        if x == 0 {

        }
        else if x > 0 {
            
            previousEnergy = myEnergy.energy[x-1]
            print("Previous Energy:")
            print(myEnergy.energy[x-1])
        }
    }
    
    
    func calculatePossibleEnergies () {
        let N = Int(Num)!
        var energyValue: Double = 0.0
        
        for E in 0...N {
            energyValue = Double(4*E) - Double(2*N)
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
        var trialDensityOfStates = calculateTrialDensityOfStates(gIndexTrial: gIndexTrial)
        
            P = myDensityOfStates.densityOfStates[gIndexPrevious]/trialDensityOfStates[gIndexTrial]
        
        return P
    }
    
    func calculateDensityOfStatesCheck () {
        let gIndexTrial = calculateGIndexOfTrialFromPossibleEnergies()
        let gIndexPrevious = calculateGIndexOfPreviousFromPossibleEnergies()
        let P = calculateProbabilityOfAcceptance(gIndexTrial: gIndexTrial, gIndexPrevious: gIndexPrevious)
        let uniformRandomNumber = Double.random(in: 0...1)
        
        if (myDensityOfStates.densityOfStates[gIndexTrial] <= myDensityOfStates.densityOfStates[gIndexPrevious]) {
            
            // Make the trial configuration the new spin configuration
            mySpins.spinConfiguration = trialConfigurationForCheck
            // Add 1 to Density of States and Multiply by f
            myDensityOfStates.densityOfStates[gIndexTrial] += 1.0
            for i in 0..<myDensityOfStates.densityOfStates.count {
                myDensityOfStates.densityOfStates[i] = f*myDensityOfStates.densityOfStates[i]
            }
            // Append the energy of the trial configuration to the energy array
            myEnergy.energy.append(newEnergy)
            print("Trial Accepted")
        }
        else if (myDensityOfStates.densityOfStates[gIndexTrial] > myDensityOfStates.densityOfStates[gIndexPrevious]) {
            if (P >= uniformRandomNumber) {
                
                // Make the trial configuration the new spin configuration
                mySpins.spinConfiguration = trialConfigurationForCheck
                // Add 1 to Density of States and Multiply by f
                myDensityOfStates.densityOfStates[gIndexTrial] += 1
                for i in 0..<myDensityOfStates.densityOfStates.count {
                    myDensityOfStates.densityOfStates[i] = f*myDensityOfStates.densityOfStates[i]
                }
                // Append the energy of the trial configuration to the energy array
                myEnergy.energy.append(newEnergy)
                print("Trial Accepted")
            }
            else if (P < uniformRandomNumber) {
                print("Trial Rejected")
            }
        }
    }
    
    func calculateWangLandau () async {
        myEnergy.energy = []
        myEnergy.possibleEnergyArray = []
        let N = Int(Num)!
        var currentSpinValue = true

        calculatePossibleEnergies()
        calculateArbitraryDensityOfStates()
        
        while stoppingPoint > 0.2 {
            for x in 0...N {
                calculatePreviousEnergySpinConfiguration(x: x)
                if x == 0 {
                    let N = Double(N)
                    previousEnergy = -2*N
                    myEnergy.energy.append(previousEnergy)
                    myEnergy.deltaEValues.append(0.0)
                }
                else if x > 0 {
                    calculateTrialConfiguration2D()
                    deltaE = 0.0
                    deltaE = calculateDeltaE()
                    newEnergy = deltaE + previousEnergy
                    calculateDensityOfStatesCheck()
                    
                    let densityMax: Double = myDensityOfStates.densityOfStates.max()!
                    let densityMin: Double = myDensityOfStates.densityOfStates.min()!
                    stoppingPoint = (densityMax - densityMin)/(densityMax + densityMin)
                    
                }
                
                await withTaskGroup(of: Void.self) { group in
                    for j in 0..<spinWidth {
                        for i in 0..<spinWidth {
                            if (mySpins.spinConfiguration[i][j] == 0.5) {
                                currentSpinValue = true
                            }
                            else {
                                currentSpinValue = false
                            }
                            
                            
                            twoDMagnet.plotSpinConfiguration.plotSpinConfiguration.append(Spin(x: Double(i), y: Double(j), spin: currentSpinValue))
                        }
                    }
                }
                
                for i in 0...(myEnergy.possibleEnergyArray.count - 1) {
                    histogramData.append(DensityOfStatesHistogram(energies: myEnergy.possibleEnergyArray[i], densityOfStates: myDensityOfStates.densityOfStates[i]))
                }
        
            }
        }
        print("While Loop is Over!")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
