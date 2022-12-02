//
//  TSA.swift
//  DNA Design
//
//  Created by Andreas on 2022/12/2.
//

import Foundation
class TSA: BaseHA{
    override init(maxIteration: Int, popSize: Int, dimension: Int) {
        super.init(maxIteration: maxIteration, popSize: popSize, dimension: dimension)
    }
    
    override func boot() {
        <#code#>
    }
    
    let x_min:Double = 1
    let x_max:Double = 4
    override func strand() {
        for t in 0..<maxIteration{
            fit()
            nsga2(individuals: &self.pops)
            if pops[0].costs.isDominate(bestIndividual.costs) || t==0{
                bestIndividual = pops[0]
            }
            let xr: Double = x_min+Double.random(in: 0..<1)*(x_max-x_min)
            var d_pos: Double = 0
            for i in 0..<popSize{
                for d in 0..<dimension{
                    let A1 = (Double.random(in: 0..<1) - Double.random(in: 0..<1))/xr
                    let c2 = Double.random(in: 0..<1)
                    
                    if i==0 {
                        let c3:Double = Double.random(in: 0..<1)
                        // in matlab, rand function return 0-1, so c3 anticipatory greater than 0;
                        // so the code in condition c3<0 will never be executed.
                        // need to read the paper
                        d_pos = abs(Double(bestIndividual.sequence[d].rawValue)-c2*Double(pops[i].sequence[d].rawValue))
                        if c3>=0.5 {
                            pops[i].sequence[d]=rectify(
                                Double(bestIndividual.sequence[d].rawValue)+A1*d_pos
                            )
                        }else{
                            pops[i].sequence[d]=rectify(
                                Double(bestIndividual.sequence[d].rawValue)-A1*d_pos
                            )
                        }
                    }else{
                        let c3 = Double.random(in: 0..<1)
                        var temp: Double = 0
                        if c3>=0.5{
                            d_pos = abs(Double(bestIndividual.sequence[d].rawValue)-c2*Double(pops[i].sequence[d].rawValue))
                            temp = Double(bestIndividual.sequence[d].rawValue) - A1*d_pos
                        }else{
                            temp = Double(bestIndividual.sequence[d].rawValue) + A1*d_pos
                        }
                        pops[i].sequence[d] = rectify(
                            (temp + Double(pops[i-1].sequence[d].rawValue))/2
                        )
                    }
                }
            }
            fixGC()
        }
    }
    
    override func fit() {
        for i in 0..<popSize{
            let c = continuity(sequence: pops[i].sequence, CT: 2)
            let h = hairpin(sequence: pops[i].sequence, pMin: 6, rMin: 6)
            pops[i].costs.append(c)
            pops[i].costs.append(h)
        }
    }
    
    override func fitOfAllDNAs() {
        
    }
    
    
}
