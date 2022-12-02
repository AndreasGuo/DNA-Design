//
//  main.swift
//  DNA Design
//
//  Created by Andreas on 2022/12/2.
//

import Foundation

let tsa = TSA(maxIteration: 10, popSize: 200, dimension: 20)
tsa.boot()
printDNAs(tsa)

func printDNAs(_ ha: BaseHA){
    print("")
    for s in ha.DNAs{
        for b in s{
            print(b.code(), terminator: "")
        }
        print("\t", terminator: "")
        print(continuity(sequence: s, CT: 2), terminator: "\t")
        print(hairpin(sequence: s, pMin: 6, rMin: 6), terminator: "")
        print("")
    }
}
