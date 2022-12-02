//
//  NSGA-II.swift
//  DNA Design Refracted
//
//  Created by Andreas on 2022/11/23.
//

import Foundation

func nsga2(individuals: inout [Individual]){
    var paretoSets = pareto(individuals: &individuals)
    for r in 0..<paretoSets.count{
        crowdingDistance(individuals: &paretoSets[r])
    }
    individuals = individuals.sorted { individual1, individual2 in
        individual1.rank < individual2.rank && individual1.crowdingDistance > individual2.crowdingDistance
    }
}

fileprivate func sort_indexs(cost: [Int])->[Int]{
    var idx = [Int]()
    for i in 0..<cost.count{
        idx.append(i)
    }
    idx = idx.sorted { i1, i2 in
        cost[i1] < cost[i2]
    }
    return idx
}

fileprivate func crowdingDistance(individuals: inout [Individual]){
    let costCount = individuals.first?.costs.count ?? 0
    for j in 0..<costCount{
        var cost = Array<Int>()
        for i in individuals{
            cost.append(i.costs[j])
        }
        let argIdx = sort_indexs(cost: cost)
        individuals[argIdx.first ?? 0].crowdingDistance = Double.infinity
        if individuals.count > 2 {
            for k in 1 ..< cost.count-1 {
                individuals[argIdx[k]].crowdingDistance +=
                Double(cost[argIdx[k+1]] - cost[argIdx[k-1]]) / Double(cost[argIdx.last ?? 0] - cost[argIdx.first ?? 0])
            }
        }
        individuals[argIdx.last ?? 0].crowdingDistance = Double.infinity
    }
}

fileprivate func pareto(individuals: inout Array<Individual>) -> Array<Array<Individual>>{
    var pareto_sets = [[Individual]]()
    let individualCount = individuals.count
    
    // first rank , 0
    var rank1_set = [Individual]()
    for i in 0..<individualCount{
        for j in i+1 ..< individualCount{
            if individuals[i].costs.isDominate(individuals[j].costs) {
                individuals[i].dominitionSet.append(individuals[j])
                individuals[j].dominitedCount += 1
            }else if individuals[j].costs.isDominate(individuals[i].costs){
                individuals[j].dominitionSet.append(individuals[i])
                individuals[i].dominitedCount += 1
            }
        }
        if individuals[i].dominitedCount == 0 {
            individuals[i].rank = 0
            rank1_set.append(individuals[i])
        }
    }
    pareto_sets.append(rank1_set)
    
    // rank 1,2,...
    var k=0
    while true {
        var rank_set = [Individual]()
        for i in 0..<pareto_sets[k].count{
            for j in 0..<pareto_sets[k][i].dominitionSet.count{
                pareto_sets[k][i].dominitionSet[j].dominitedCount -= 1
                if pareto_sets[k][i].dominitionSet[j].dominitedCount == 0{
                    rank_set.append(pareto_sets[k][i].dominitionSet[j])
                    pareto_sets[k][i].dominitionSet[j].rank = k+1
                }
            }
        }
//        for i in pareto_sets[k]{
//            for j in 0..<i.dominitionSet{
//                j.dominitedCount -= 1
//                if j.dominitedCount == 0{
//                    rank_set.append(j)
//                    j.rank = k+1
//                }
//            }
//        }
        if rank_set.isEmpty {break}
        pareto_sets.append(rank_set)
        k += 1
    }
    return pareto_sets
}

extension Array where Element == Int{
    func isDominate(_ y:Array<Int>)->Bool{
        var all_leq = true
        var one_le = false
        for i in 0..<self.count{
            if self[i] > y[i] {all_leq=false}
            if self[i] < y[i] {one_le=true}
        }
        return all_leq && one_le
    }
}
