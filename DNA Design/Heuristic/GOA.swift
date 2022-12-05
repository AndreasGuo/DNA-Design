//
//  GOA.swift
//  DNA Design
//
//  Created by Andreas on 2022/12/4.
//

import Foundation

class GOA{
    let maxIteration = 500
    var High: Int
    let Low = 0
    var DNAs: [[DNABase]]
    let dimension = 7
    let popSize = 300
    var pop = [Individual]()
    let cMax:Double = 1
    let cMin=0.00004
    var flag: Int
    var bestIndividual = Individual()
    
    init(DNAs: [[DNABase]]) {
        self.DNAs = DNAs
        self.High = DNAs.count-1
        self.flag = dimension%2
    }
    
    func resolveRepeat(){
        for i in 0..<popSize{
            for k in 0..<dimension-1{
                let v = pop[i].group[k]
                for j in k+1 ..< dimension{
                    if pop[i].group[j] == v{
                        while true{
                            let randInt = Int.random(in: Low...High)
                            if !pop[i].group.contains(randInt){
                                pop[i].group[j] = randInt
                                break
                            }
                        }
                    }
                }
            }
        }
    }
    
    func initPop(){
        for _ in 0..<popSize{
            var individual = Individual()
            for _ in 0..<dimension{
                while true{
                    let randInt = Int.random(in: Low...High)
                    if !individual.group.contains(randInt){
                        individual.group.append(randInt)
                        break
                    }
                }
            }
            pop.append(individual)
        }
    }
    
    func fitness(){
        for i in 0..<popSize{
            var DNAGroup = [[DNABase]]()
            for j in 0..<dimension{
                DNAGroup.append(DNAs[pop[i].group[j]])
            }
            let (hm, sm) = hmAndSm(DNAs: DNAGroup)
            pop[i].costs = []
            pop[i].costs.append(hm.reduce(0, +))
            pop[i].costs.append(sm.reduce(0, +))
        }
    }
    
    func distance(a: [Int], b:[Int]) -> Double{
        sqrt(pow(Double(a[0]-b[0]), 2)+pow(Double(a[1]-b[1]),2))
    }
    
    func s_func(r: Double) -> Double{
        let f=0.5
        let l=1.5
        return f*exp(-r/l)-exp(-r)
    }
    
    func bound(){
        for i in 0..<popSize{
            for k in 0..<dimension{
                if pop[i].group[k] > High{ pop[i].group[k] = High}
                if pop[i].group[k] < Low{ pop[i].group[k] = Low}
            }
        }
    }
    
    func goa(){
        print("GOA initiating...")
        var start = CFAbsoluteTimeGetCurrent()
        initPop()
        fitness()
        nsga2(individuals: &pop)
        bestIndividual = pop[0]
        var end = CFAbsoluteTimeGetCurrent()
        print("GOA initiated, time: \(String(format: "%.3f", end-start))s")
        
        for t in 1...maxIteration{
            start = CFAbsoluteTimeGetCurrent()
            let c = cMax-Double(t)*((cMax-cMin)/Double(maxIteration))
            
            var tempPop = pop
            
            for i in 0..<popSize{
                var k = 0
                var S_i_total = [Double]()
                while k<dimension{
                    var S_i :[Double] = [0,0]
                    for j in 0..<popSize{
                        if i != j{
                            let a = [pop[i].group[k], k+1<dimension ? pop[i].group[k+1] : 0]
                            let b = [pop[j].group[k], k+1<dimension ? pop[j].group[k+1] : 0]
                                
                            let dist = distance(a:a, b:b)
                            let r_ij_vec = [Double(a[0]-b[0])/(dist+1), Double(a[1]-b[1])/(dist+1)]
                            
                            let intDist = Int(dist)
                            let xj_xi = 2 + Double(intDist%2) + (dist-Double(intDist))
                            
                            var s_ij = [Double]()
                            s_ij.append(Double(High - Low)*c/2*s_func(r: xj_xi)*r_ij_vec[0])
                            s_ij.append(Double(High - Low)*c/2*s_func(r: xj_xi)*r_ij_vec[1])
                            
                            S_i[0]+=s_ij[0]
                            S_i[1]+=s_ij[1]
                        }
                    } // end j in popSize
                    S_i_total.append(contentsOf: S_i)
                    
                    k+=2
                } // end k in dimension
                var X_new = [Int]()
                for k in 0..<dimension{
                    let x = Int(c*S_i_total[k])+bestIndividual.group[k]
                    X_new.append(x)
                }
                tempPop[i].group = X_new
            } // end i in popSize
            pop = tempPop
            
            resolveRepeat()
            bound()
            fitness()
            
            // update best
            for i in 0..<popSize{
                if pop[i].costs.isDominate(bestIndividual.costs){
                    bestIndividual = pop[i]
                }
            }
            
            end = CFAbsoluteTimeGetCurrent()
            print("iteration \(t), best fitness: \(bestIndividual.costs), time: \(String(format: "%.2f", end-start))")
        } // end maxIteration
        
        var DNAGroup = [[DNABase]]()
        for i in bestIndividual.group{
            DNAGroup.append(DNAs[i])
        }
        let (hm, sm) = hmAndSm(DNAs: DNAGroup)
        
        for i in 0..<DNAGroup.count{
            for BASE in DNAGroup[i]{
                print(BASE.code(), terminator: "")
            }
            print("\t\(continuity(sequence: DNAGroup[i], CT: 2))", terminator: "")
            print("\t\(hairpin(sequence: DNAGroup[i], pMin: 6, rMin: 6))", terminator: "")
            print("\t\(hm[i])", terminator: "")
            print("\t\(sm[i])")
        }
        print("------------------------------------")
        print("HM: \(hm.reduce(0,+)), SM: \(sm.reduce(0,+))")
        print("------------------------------------")
        print("best group: \(bestIndividual.group)")
    }
    
}
