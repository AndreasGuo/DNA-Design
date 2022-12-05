//
//  Individual.swift
//  DNA Design Refracted
//
//  Created by Andreas on 2022/11/23.
//

import Foundation
struct Individual{
    var sequence = [DNABase]()
    var group = Array<Int>()
    var costs = [Int]()
    var rank: Int = 0
    var crowdingDistance: Double = 0
    var dominitedCount = 0
    var dominitionSet = [Int]()
    
    mutating func minusDominitedCount(){
        self.dominitedCount -= 1
    }
    
    func toString() -> String{
        var s = ""
        for b in sequence{
            s.append(b.code())
        }
        return s
    }
}

enum DNABase:Int{
    case C = 0
    case T = 1
    case A = 2
    case G = 3
    case N = 5 // represent blank
    
    func double() -> Double{
        Double(self.rawValue)
    }
    
    static func + (lhs: DNABase, rhs: DNABase) -> Int{
        lhs.rawValue + rhs.rawValue
    }
    
    func code() -> String{
        switch self{
        case .C: return  "C"
        case .T: return "T"
        case .A: return "A"
        case .G: return "G"
        case .N: return "-"
        }
    }
    
    func eq(_ another: DNABase) -> Bool{
        self == another
    }
    
    func bp(_ another: DNABase) -> Bool{
        self + another == 3
    }
}
