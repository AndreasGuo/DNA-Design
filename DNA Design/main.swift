//
//  main.swift
//  DNA Design
//
//  Created by Andreas on 2022/12/2.
//

import Foundation

// 流氓
let tsa = TSA(maxIteration: 7, popSize: 200, dimension: 20)
tsa.boot()
let DNAs = tsa.DNAs

let goa = GOA(DNAs: DNAs)
goa.goa()
//let hsa = HSA(maxIteration: 10000, popSize: 500, dimension: 7, DNAs: DNAs)
//hsa.boot()

// test nsga2
//var individuals = [Individual]()
//for i in 0..<100{
//    var individual = Individual()
//    individual.group = [i]
//    individual.costs = [Int.random(in: 0...10), Int.random(in: 0...10)]
//    individuals.append(individual)
//}
//nsga2(individuals: &individuals)
//print("")

// 数理统计 期末课程论文用
//let s = randGroups(groupCount: 200, strandInOneGroup: 7, numberOfStrand: tsa.DNAs.count)
//try DNAHmAndSm(groups: s, DNAs: tsa.DNAs)

func printDNAs(_ ha: BaseHA){
    print("")
    for s in ha.DNAs{
        for b in s{
            print(b.code(), terminator: "")
        }
        print("\t", terminator: "")
//        print(continuity(sequence: s, CT: 2), terminator: "\t")
//        print(hairpin(sequence: s, pMin: 6, rMin: 6), terminator: "")
        print("")
    }
}
