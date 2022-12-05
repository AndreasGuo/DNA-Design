//
//  HSA.swift
//  DNA Design
//
//  Created by Andreas on 2022/12/4.
//

import Foundation

class HSA: BaseHA{
    // This algorithm for the second step of 流氓
    var DNAPool: [[DNABase]]
    var High: Int
    init(maxIteration: Int, popSize: Int, dimension: Int, DNAs: [[DNABase]]) {
        self.DNAPool = DNAs
        self.High = DNAs.count
        super.init(maxIteration: maxIteration, popSize: popSize, dimension: dimension)
    }
    
    func cost(group: [Int]) -> (Int, Int){
        var groups = [[DNABase]]()
        for g in group{
            groups.append(DNAPool[g])
        }
        let (hm, sm) = hmAndSm(DNAs: groups)
        return (hm.reduce(0, +), sm.reduce(0, +))
    }
    
    override func boot(){
        //let HMS = popSize // Harmony Size (Population Number)
        let bw = 0.2
        let HMCR = 0.95 // Harmony Memory Considering Rate
        let PAR = 0.3 // Pitch Adjustment Rate
        
        // Initialization
        let start = CFAbsoluteTimeGetCurrent()
        print("Initiating HSA...")
        for _ in 0..<self.popSize{
            var groups = [[DNABase]]()
            var individual = Individual()
            
            while individual.group.count<self.dimension{
                let strandNumber = Int(Double(High)*Double.random(in: 0..<1))
                if !individual.group.contains(strandNumber){
                    groups.append(DNAPool[strandNumber])
                    individual.group.append(strandNumber)
                }
            }
            
            let (hm, sm) = hmAndSm(DNAs: groups)
            individual.costs = []
            individual.costs.append(hm.reduce(0,+))
            individual.costs.append(sm.reduce(0,+))
            self.pops.append(individual)
        }
//        nsga2(individuals: &self.pops)
        var worstLoc = worstIndex()
        var bestLoc = bestIndex()
        let end = CFAbsoluteTimeGetCurrent()
        print("HSA initiated, time: \(end-start)s")
        
        // Iteration Loop
        for t in 0..<self.maxIteration{
            let start = CFAbsoluteTimeGetCurrent()
            
            var Harmony = [Int]()
            var d = 0
            while d < self.dimension{
                let HarmonyIndex = Int.random(in: 0..<self.popSize)
                if !Harmony.contains(pops[HarmonyIndex].group[d]){
                    Harmony.append(self.pops[HarmonyIndex].group[d])
                    d += 1
                }
            }
            
            var CMMask = [Bool]()
            var NHMask = [Bool]()
            var PAMask = [Bool]()
            for _ in 0..<self.dimension{
                if Double.random(in: 0..<1) < HMCR{
                    CMMask.append(true)
                    NHMask.append(false)
                    if Double.random(in: 0..<1) < PAR{
                        PAMask.append(true)
                        CMMask[CMMask.count-1] = false
                    }else{PAMask.append(false)}
                }else{
                    CMMask.append(false)
                    NHMask.append(true)
                    PAMask.append(false)
                }
            }
            
            var newHarmony = [Int]()
            for dim in 0..<self.dimension{
                let value = Double(Harmony[dim])
                var newValue: Double = 0
                newValue += CMMask[dim] ? value : 0
                newValue += PAMask[dim] ? value + bw*(Double.random(in: -1...1)) : 0
                newValue += NHMask[dim] ? Double.random(in: 0...Double(self.High-1)) : 0
                if outOfBoundary(value: newValue){
                    newValue = value
                }
                if !newHarmony.contains(Int(newValue)){
                    newHarmony.append(Int(newValue))
                }else{
                    while true{
                        newValue = Double.random(in: 0...Double(High-1))
                        if !newHarmony.contains(Int(newValue)){
                            newHarmony.append(Int(newValue))
                            break
                        }
                    }
                }
            }
            var worstLoc = worstIndex()
            var bestLoc = bestIndex()
            
            let (Hm, Sm) = cost(group: newHarmony)
            if Hm < self.pops[worstLoc].costs.first! && Sm < self.pops[worstLoc].costs.last!{
                self.pops[worstLoc].group = newHarmony
                self.pops[worstLoc].costs = [Hm, Sm]
            }
            
            if t==0 || pops[bestLoc].costs.isDominate(bestIndividual.costs){
                self.bestIndividual = pops[bestLoc]
            }
            
            let end = CFAbsoluteTimeGetCurrent()
            
            print("iteration: \(t+1), bestCost: \(bestIndividual.costs), time: \(end-start)s")
        } // end Iteration
        
        
        // result
        var DNAGroup = [[DNABase]]()
        for i in self.bestIndividual.group{
            DNAGroup.append(DNAPool[i])
        }
        
        let (hm, sm) = hmAndSm(DNAs: DNAGroup)
        
        for i in 0..<DNAGroup.count{
            for d in 0..<DNAGroup[0].count{
                print(DNAGroup[i][d].code(), terminator: "")
            }
            print("", terminator: "\t")
            print(continuity(sequence: DNAGroup[i], CT: 2), terminator: "\t")
            print(hairpin(sequence: DNAGroup[i], pMin: 6, rMin: 6), terminator: "\t")
            print("\(hm[i]) \t\(sm[i])")
        }
        print("Hm: \(hm.reduce(0,+)),\tSm: \(sm.reduce(0,+))")
        print(bestIndividual.group)
    } // end boot
    
    func outOfBoundary(value: Double) -> Bool{
        value < 0 || value > Double(self.High-1)
    }
    
    func worstIndex()->Int{
        var worstLoc = 0
        for i in 0..<self.popSize{
            if pops[i].costs.first! > pops[worstLoc].costs.first! && pops[i].costs.last! > pops[worstLoc].costs.last!{
                worstLoc = i
            }
        }
        return worstLoc
    }
    
    func bestIndex()->Int{
        var worstLoc = 0
        for i in 0..<self.popSize{
            if pops[i].costs.first! < pops[worstLoc].costs.first! && pops[i].costs.last! < pops[worstLoc].costs.last!{
                worstLoc = i
            }
        }
        return worstLoc
    }
    
}
