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
    @State var potentialArray: [Double] = []
    @State var trialEnergy: Double = 0.0
    @State var energy: Double = 0.0
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
//                Button(action: {
//                    self.calculateColdMetropolisAlgorithm2D()})
//                {Text("Calculate Cold Metropolis Algorithm")}
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
        let randParticleX = Int.random(in: 0...(N - 1))
        let randParticleY = Int.random(in: 0...(N - 1))
        var trialConfiguration = mySpins.spinConfiguration
        particleValue = (randParticleX*N) + randParticleY
        
        if (trialConfiguration[randParticleX][randParticleY] == 1.0) {
            trialConfiguration[randParticleX][randParticleY] = -1.0
        }
        else {
            trialConfiguration[randParticleX][randParticleY] = 1.0
        }
        //print(trialConfiguration)
        print("Particle i Value for g(E):")
        print(particleValue)
        print(trialConfiguration)
        return trialConfiguration
    }
    
    func calculateArbitraryDensityOfStates () {
        let N = Double(Num)!
        let upperLimit = pow(2.0, N)
        let upperLimitInteger = Int(upperLimit)
        
//indices 0...(2^N-1)
        for i in 1...upperLimitInteger {
            myDensityOfStates.arbitraryDensityOfStates.append(0.0)
        }
        print(mySpins.densityOfStates)
    }
    
    func calculateTrialDensityOfStates () -> [Double] {
        let N = Double(Num)!
        let upperLimit = pow(2.0, N)
        let upperLimitInteger = Int(upperLimit)
        var trialDensityOfStates = myDensityOfStates.arbitraryDensityOfStates
//indices 0...(2^N-1)
        trialDensityOfStates[particleValue] += 1.0
        
        print(trialDensityOfStates)
        return trialDensityOfStates
        }
    
    func calculateEnergyOfTrialSpinConfiguration () {
        let N = Int(Num)!
        var trialEnergy: Double = 0.0
        
        for i in 1...N {
            let trialEnergyValue = 
            trialEnergy = trialEnergy +
        }
    }
    
    func calculateProbabilityOfAcceptance () -> Double {
        var P: Double = 0.0
        var trialDensityOfStates = calculateTrialDensityOfStates()
        
            P = myDensityOfStates.arbitraryDensityOfStates[particleValue]/trialDensityOfStates[particleValue]
        
        return P
    }
    
    func calculateEnergyOfTrialConfiguration2D (x: Int, J: Int, trialConfiguration: [[Double]]) {
        let N = Double(Num)!
        let upperLimit = sqrt(N)
        let upperLimitInteger = Int(upperLimit)
        trialEnergy = 0.0
        
        let J = Double(J)
        let eValue = 2.7182818284590452353602874713
        // hbarc in eV*Angstroms
        let hbarc = 1973.269804
        // mass of electron in eVc^2
        let m = 510998.95000
        let g = Double(g)!
        let bohrMagneton = (eValue*hbarc)/(2.0*m)
        let B = Double(B)!
        
        if (x > 0) {
            for j in 1...upperLimitInteger {
                for i in 1...(upperLimitInteger - 1) {
                    let trialEnergyValue = -J*(trialConfiguration[j-1][i-1]*trialConfiguration[j-1][i]) - (B*bohrMagneton*trialConfiguration[j-1][i])
                    trialEnergy = trialEnergy + trialEnergyValue
                }
            }
        }
        print("Trial Energy:")
        print(trialEnergy)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
