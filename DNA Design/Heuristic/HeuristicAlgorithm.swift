//
//  HeuristicAlgorithm.swift
//  DNA Design Refracted
//
//  Created by Andreas on 2022/11/23.
//

import Foundation

fileprivate protocol HeuristicAlgorithm{
    var maxIteration: Int {set get}
    var popSize: Int{set get}
    var dimension: Int{set get}
    var bestIndividual: Individual! {get set}
    var pops: [Individual]{get set}
    var DNAs: [[DNABase]]{get set}
    
    func boot()
    func strand()
    func fit()
    func fitOfAllDNAs()
}

class BaseHA: HeuristicAlgorithm{
    var maxIteration: Int
    
    var popSize: Int
    
    var dimension: Int
    
    var bestIndividual: Individual!
    
    var pops: [Individual] = []
    
    var DNAs: [[DNABase]] = []
    
    init(maxIteration: Int, popSize: Int, dimension: Int) {
        self.maxIteration = maxIteration
        self.popSize = popSize
        self.dimension = dimension
    }
    
    func boot() {
        
    }
    
    func strand() {
        
    }
    
    func fit() {
        
    }
    
    func fitOfAllDNAs() {
        
    }
}

// properties
extension BaseHA{
    var lower: Int{
        get{0}
    }
    var upper: Int{
        get{3}
    }
}

// functions
extension BaseHA{
    func initPop(){
        pops.removeAll(keepingCapacity: true)
        for _ in 0..<popSize{
            let sequence = (0..<dimension).map{_ in DNABase(rawValue: Int.random(in: 0...3))!}
            var individual = Individual()
            individual.sequence = sequence
            pops.append(individual)
        }
    }
    func GCCount(_ sequence: [DNABase])->Int{
        sequence.filter {
            $0 == .C || $0 == .G
        }.count
    }
    func fixGC(){
        for i in 0..<popSize{
            let l = pops[i].sequence.count
            let GC = GCCount(pops[i].sequence)
            // TODO: can be refacted to function
            if GC > l/2 {
                for _ in 0..<GC-l/2{
                    while true{
                        let r = Int.random(in: 0..<l)
                        if pops[i].sequence[r] == .C || pops[i].sequence[r] == .G{
                            pops[i].sequence[r] = DNABase(rawValue: Int.random(in: 1...2))!
                            break
                        }
                    }
                }
            }else if GC < l/2{
                for _ in 0..<l/2-GC{
                    while true{
                        let r = Int.random(in: 0..<l)
                        if pops[i].sequence[r] == .A || pops[i].sequence[r] == .T{
                            pops[i].sequence[r] = DNABase(rawValue: Int.random(in: 0...1)*3)!
                            break
                        }
                    }
                }
            }
        }
    }
    func rectify(_ lhs:Double) -> DNABase{
        DNABase(rawValue: Int(min(Double(upper), max(Double(lower), lhs))))!
    }
}


