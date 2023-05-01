//
//  ContentView.swift
//  Final Project Part 3
//
//  Created by IIT PHYS 440 on 4/28/23.
//

import SwiftUI

struct ContentView: View {
    
    @State var upOrDown = [1.0, -1.0]
    @State var spinArray: [Double] = []
    @State var nextSpinArray: [Double] = []
    @State var timeArray: [Double] = []
    @State var Num: String = "2"
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
    @StateObject var mySpins = Spins()
    @StateObject var myEnergy = Energy()
    @StateObject var myDensityOfStates = DensityOfStates()
//    @StateObject var myPotential = Potential()
    @StateObject var twoDMagnet = TwoDMagnet()
    let upColor = Color(red: 0.25, green: 0.5, blue: 0.75)
    let downColor = Color(red: 0.75, green: 0.5, blue: 0.25)
    
    var body: some View {
        HStack {
            VStack {
                HStack {
                    Text("N:")
                    TextField("N:", text: $Num)
                }
                HStack {
                    Text("kT:")
                    TextField("kT:", text: $kT)
                }
                Button(action: {
                    self.calculateColdSpinConfiguration2D()})
                {Text("Calculate Cold Spin Configuration")}
                Button(action: {
                    self.calculateArbitraryDensityOfStates()})
                {Text("Calculate Density of States")}
                Button(action: {
                    self.calculateTrialConfiguration2D()})
                {Text("Calculate Trial Configuration")}
                Button(action: {
                    self.calculateWangLandau()})
                {Text("Calculate Wang Landau")}
//                Button(action: {
//                    self.calculateArbitraryMetropolisAlgorithm2D()})
//                {Text("Calculate Cold Metropolis Algorithm")}
            }
        }
            VStack(){
                TimelineView(.animation) { timeline in
                    Canvas { context, size in
                        twoDMagnet.update(to: timeline.date, N: Int(Double(Num)!), isThereAnythingInMyVariable: false)
                        
                        for spin in twoDMagnet.spins {
                            let N = Double(Num)!
                            let upperLimit = sqrt(N)
                            let upperLimitInteger = Int(upperLimit)
                            let rect = CGRect(x: spin.x * (size.width/CGFloat(mySpins.spinConfiguration.count)), y: spin.y * (size.height/CGFloat(upperLimitInteger)), width: (size.height/CGFloat(mySpins.spinConfiguration.count - 1)), height: (size.height/CGFloat(upperLimitInteger)))
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
                
                
              //  Button("Start from Cold", action: setupColdSpins)
             //   Button("Start from Arbitrary", action: setupArbitrarySpins)
            }
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
        //print(mySpins.spinConfiguration)
    }
    
    func calculateTrialConfiguration2D () -> [[Double]] {
        particleValue = 0
        let N = Int(Num)!
        randParticleX = Int.random(in: 0...(N - 1))
        randParticleY = Int.random(in: 0...(N - 1))
        var trialConfiguration = mySpins.spinConfiguration
        deltaE = 0.0
        particleValue = (randParticleX*N) + randParticleY
        
        if (trialConfiguration[randParticleX][randParticleY] == 1.0) {
            trialConfiguration[randParticleX][randParticleY] = -1.0
        }
        else {
            trialConfiguration[randParticleX][randParticleY] = 1.0
        }
        deltaE = calculateDeltaE()
        newEnergy = deltaE + previousEnergy
        //print(trialConfiguration)
        print("Particle i Value for g(E):")
        print(particleValue)
        print(trialConfiguration)
        return trialConfiguration
    }
    
    func calculateDeltaE () -> Double {
        let N = Int(Num)!
        var trialConfiguration = mySpins.spinConfiguration
        
        if (randParticleX > 0 && randParticleX < (N-1) && randParticleY > 0 && randParticleY < (N-1)) {
            deltaE = (2*trialConfiguration[randParticleX][randParticleY])*(trialConfiguration[randParticleX+1][randParticleY] + trialConfiguration[randParticleX-1][randParticleY] + trialConfiguration[randParticleX][randParticleY+1] + trialConfiguration[randParticleX][randParticleY-1])
        }
        else if (randParticleX == 0 && randParticleY == 0) {
            deltaE = (2*trialConfiguration[0][0])*((trialConfiguration[1][0] + trialConfiguration[0][1] + trialConfiguration[N-1][0] + trialConfiguration[0][N-1]))
        }
        else if (randParticleX == 0 && randParticleY == (N-1)) {
            deltaE = (2*trialConfiguration[0][N-1])*((trialConfiguration[0][N-2] + trialConfiguration[1][N-1] + trialConfiguration[N-1][N-1] + trialConfiguration[0][0]))
        }
        else if (randParticleX == (N-1) && randParticleY == 0) {
            deltaE = (2*trialConfiguration[N-1][0])*((trialConfiguration[N-1][1] + trialConfiguration[N-2][0] + trialConfiguration[N-1][N-1] + trialConfiguration[0][0]))
        }
        else if (randParticleX == (N-1) && randParticleY == (N-1)) {
            deltaE = (2*trialConfiguration[N-1][N-1])*((trialConfiguration[N-2][N-1] + trialConfiguration[N-1][0] + trialConfiguration[N-1][N-2] + trialConfiguration[0][N-1]))
        }
        return deltaE
    }
    
    func calculateArbitraryDensityOfStates () {
        let N = Double(Num)!
        let upperLimit = pow(N, 2.0)
        let upperLimitInteger = Int(upperLimit)
        
//indices 0...(2^N-1)
        for i in 1...upperLimitInteger {
            myDensityOfStates.arbitraryDensityOfStates.append(0.0)
        }
        print(mySpins.densityOfStates)
    }
    
    func calculateTrialDensityOfStates () -> [Double] {
        let N = Double(Num)!
        let upperLimit = pow(N, 2.0)
        let upperLimitInteger = Int(upperLimit)
        var trialDensityOfStates = myDensityOfStates.arbitraryDensityOfStates
//indices 0...(2^N-1)
        trialDensityOfStates[particleValue] += 1.0
        
        print(trialDensityOfStates)
        return trialDensityOfStates
        }
    
    func calculateEnergySpinConfiguration () {
        let N = Int(Num)!
        //really spinConfiguration but didnt want to change everything
        var trialConfiguration = mySpins.spinConfiguration
        
        for j in 0...(N-1) {
            for i in 0...(N-1) {
                if (i > 0 && i < (N-1) && j > 0 && j < (N-1)){
                    let previousEnergyValue = -((trialConfiguration[i][j]*trialConfiguration[i+1][j]) + (trialConfiguration[i][j]*trialConfiguration[i][j-1]) + (trialConfiguration[i][j]*trialConfiguration[i-1][j]) +  (trialConfiguration[i][j]*trialConfiguration[i][j+1]) + (trialConfiguration[0][j]*trialConfiguration[N-1][j]) + (trialConfiguration[i][0]*trialConfiguration[i][N-1]))
                    previousEnergy = previousEnergy + previousEnergyValue
                }
                else if (i == 0 && j == 0) {
                    let previousEnergyValue = -((trialConfiguration[0][0]*trialConfiguration[1][0]) + (trialConfiguration[0][0]*trialConfiguration[0][1]) + (trialConfiguration[0][0]*trialConfiguration[N-1][0]) + (trialConfiguration[0][0]*trialConfiguration[0][N-1]))
                    previousEnergy = previousEnergy + previousEnergyValue
                }
                else if (i == 0 && j == (N-1)) {
                    let previousEnergyValue = -((trialConfiguration[0][N-1]*trialConfiguration[1][N-1]) + (trialConfiguration[0][N-1]*trialConfiguration[0][N-2]) + (trialConfiguration[0][N-1]*trialConfiguration[0][0]) + (trialConfiguration[0][N-1]*trialConfiguration[N-1][N-1]))
                    previousEnergy = previousEnergy + previousEnergyValue
                }
                else if (i == (N-1) && j == 0) {
                    let previousEnergyValue = -((trialConfiguration[N-1][0]*trialConfiguration[0][0]) + (trialConfiguration[N-1][0]*trialConfiguration[N-2][0]) + (trialConfiguration[N-1][0]*trialConfiguration[N-1][1]) + (trialConfiguration[N-1][0]*trialConfiguration[N-1][N-1]))
                    previousEnergy = previousEnergy + previousEnergyValue
                }
                else if (i == (N-1) && j == (N-1)) {
                    let previousEnergyValue = -((trialConfiguration[N-1][N-1]*trialConfiguration[N-2][N-1]) + (trialConfiguration[N-1][N-1]*trialConfiguration[N-1][N-2]) + (trialConfiguration[N-1][N-1]*trialConfiguration[N-1][0]) + (trialConfiguration[N-1][N-1]*trialConfiguration[0][N-1]))
                }
            }
        }
        print("Previous Energy:")
        print(previousEnergy)
    }
    
    func calculatePossibleEnergies () {
        let N = Int(Num)!
        var energyValue: Double = 0.0
        
        for E in 0...N {
            energyValue = Double(4*E) - Double(2*N)
            myEnergy.possibleEnergyArray.append(energyValue)
            print(myEnergy.possibleEnergyArray.count)
        }
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
    
    func calculateProbabilityOfAcceptance () -> Double {
        var P: Double = 0.0
        var trialDensityOfStates = calculateTrialDensityOfStates()
        
            P = myDensityOfStates.arbitraryDensityOfStates[particleValue]/trialDensityOfStates[particleValue]
        
        return P
    }
    
    func calculateDensityOfStatesCheck () {
        var trialConfiguration = calculateTrialConfiguration2D()
        var P = calculateProbabilityOfAcceptance()
        var gIndexTrial = calculateGIndexOfTrialFromPossibleEnergies()
        var gIndexPrevious = calculateGIndexOfPreviousFromPossibleEnergies()
        let uniformRandomNumber = Double.random(in: 0...1)
        let f = 1.0
        
        if (myDensityOfStates.arbitraryDensityOfStates[gIndexTrial] <= myDensityOfStates.arbitraryDensityOfStates[gIndexPrevious]) {
            
            mySpins.spinConfiguration = trialConfiguration
            myDensityOfStates.arbitraryDensityOfStates[gIndexTrial] += 1
            myDensityOfStates.arbitraryDensityOfStates[gIndexTrial] = f*myDensityOfStates.arbitraryDensityOfStates[gIndexTrial]
            myEnergy.energy.append(newEnergy)
            print("Trial Accepted")
        }
        else if (myDensityOfStates.arbitraryDensityOfStates[gIndexTrial] > myDensityOfStates.arbitraryDensityOfStates[gIndexPrevious]) {
            if (P >= uniformRandomNumber) {
                
                mySpins.spinConfiguration = trialConfiguration
                myDensityOfStates.arbitraryDensityOfStates[gIndexTrial] += 1
                myDensityOfStates.arbitraryDensityOfStates[gIndexTrial] = f*myDensityOfStates.arbitraryDensityOfStates[gIndexTrial]
                myEnergy.energy.append(newEnergy)
                print("Trial Accepted")
            }
            else if (P < uniformRandomNumber) {
                myEnergy.energy.append(previousEnergy)
                print("Trial Rejected")
            }
        }
    }
    // g(Ea(k+1)) --> f*g(Ea(k+1))
    func calculateDensityOfStatesModification () {
        let f = 1.0
        
        for i in 0...(myDensityOfStates.arbitraryDensityOfStates.count - 1) {
            myDensityOfStates.arbitraryDensityOfStates[i] = f*myDensityOfStates.arbitraryDensityOfStates[i]
        }
    }
    
    func calculateWangLandau () {
        calculateColdSpinConfiguration2D()
        calculateArbitraryDensityOfStates()
        calculateEnergySpinConfiguration()
        calculatePossibleEnergies()
        calculateDensityOfStatesCheck()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
