//
//  RandomGroup.swift
//  DNA Design
//
//  Created by Andreas on 2022/12/3.
//

import Foundation

// rand int in 0..<before
func randi(before: Int) -> Int{
    return Int.random(in: 0..<before)
}

// rand array for specfic count
func randIntSet(strandInOneGroup count: Int, numberOfStrand before: Int)->[Int]{
    var numberSet: Set<Int> = []
    while numberSet.count < count {
        numberSet.insert(randi(before: before))
    }
    return numberSet.sorted()
}

// groupCount*baseCountInOneStrand matrix
func randGroups(groupCount:Int, strandInOneGroup count: Int, numberOfStrand before: Int) -> Set<[Int]>{
    var groups = Set<[Int]>()
    while groups.count < groupCount{
        groups.insert(randIntSet(strandInOneGroup: count, numberOfStrand: before))
    }
    return groups
}

// from randGroups to DNA Sets and calculate Hm and Sm
func DNAHmAndSm(groups: Set<[Int]>, DNAs: [[DNABase]]) throws{
    let path = "/Users/andreas/Developer/DNA Design/DNA Design"
    var url = URL(filePath: path)
    url.append(component: "statics.txt")
    
    var text=""
    var HMS = [Int]()
    var SMS = [Int]()
    
    for numberInGroups in groups{
        var DNASequences = [[DNABase]]()
        for i in numberInGroups{
            DNASequences.append(DNAs[i])
        }
        let (hm,sm) = hmAndSm(DNAs: DNASequences)
        let Hm=hm.reduce(0,+)
        let Sm=sm.reduce(0,+)
        
        for s in 0..<DNASequences.count{
            for b in DNASequences[s]{
                text += b.code()
            }
            text += "\t"
            text += "\(continuity(sequence: DNASequences[s], CT: 2))\t"
            text += "\(hairpin(sequence: DNASequences[s], pMin: 6, rMin: 6))\t"
            text += "\(hm[s])\t"
            text += "\(sm[s])\n"
        }
        text += "------------------------------------\n"
        text += "\(Hm)\t\(Sm)\n"
        text += "------------------------------------\n"
        HMS.append(Hm)
        SMS.append(Sm)
    }
    text += "#####################################\n"
    for c in 0..<groups.count{
        text += "\(HMS[c])\t"
        text += "\(SMS[c])\n"
    }
    
    try text.write(to: url, atomically: true, encoding: .utf8)
}
