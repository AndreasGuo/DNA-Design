//
//  constraints.swift
//  DNA Design Refracted
//
//  Created by Andreas on 2022/11/23.
//

import Foundation

// constants
fileprivate let CT = 2
fileprivate let pMin = 6
fileprivate let rMin = 6
fileprivate let CS=6
fileprivate let CH=6
fileprivate let DH=0.17
fileprivate let DS=0.17

typealias DNA = [DNABase]

/// <#Description#>
/// - Parameters:
///   - sequence: a DNA strand, represented by [Int]
///   - CT: continuity threshold
/// - Returns: sum of power of each continuity bases
func continuity(sequence: DNA, CT: Int) -> Int{
    let l = sequence.count
    var i = 0
    var count = 0
    while i<l {
        let subContinuity = ceq(x: sequence, at: i)
        i += subContinuity;
        if subContinuity > CT {
            count += subContinuity * subContinuity
        }
    }
    return count
}

func hairpin(sequence: DNA, pMin: Int, rMin: Int) -> Int{
    let l = sequence.count
    let PINLEN = 3
    var value = 0
    for p in pMin..<(l-rMin)/2+1{
        for r in rMin..<(l-2*p)+1{
            for i in 0..<l-2*p-r+1{
                var sigmaBp = 0
                let pl = pinlen(p: p, r: r, i: i, l: l)
                for j in 0..<pl{
                    sigmaBp += sequence[p+i-j-1].bp(sequence[p+i+r+j]) ? 1 : 0
                }
                value += sigmaBp > pl/PINLEN ? sigmaBp : 0
            }
        }
    }
    return value
}

func hmAndSmOneStrand(DNAs: [DNA], DS: Double, CS: Double, CH: Int, DH: Int) -> (Int, Int){
    let m = DNAs.count
    let l = DNAs[0].count
    let GAP = 0 // round 1/4
    let p = m-1
    var H = (0..<m).map{_ in 0}
    var S = (0..<m).map{_ in 0}
    let sequence = DNAs[p]
    let reversedSequence = Array<DNABase>(sequence.reversed())
    for j in 0..<m{
        for g in 0..<GAP+1{
            let gVector = (0..<g).map{_ in DNABase.N}
            var extendedSeqY = DNAs[j]
            extendedSeqY.append(contentsOf: gVector)
            extendedSeqY.append(contentsOf: DNAs[j])
            for i in -l+1 ..< l{
                let shiftedSeqY = shift(sequence: extendedSeqY, i: i)
                let currentHm = hDis(x: reversedSequence, y: shiftedSeqY, DH: DH) + hCont(x: reversedSequence, y: shiftedSeqY, CH: CH)
                H[j] = max(H[j], currentHm)
                if p != j {
                    let currentSm = sHis(x: sequence, y: shiftedSeqY, DS: DS) + sCont(x: sequence, y: shiftedSeqY, CS: CS)
                    S[j] = max(S[j], currentSm)
                }
            }
        }
    }
    
    let hm = H.reduce(0, +)
    let sm = S.reduce(0, +)
    return (hm, sm)
}

func hmAndSm(DNAs: [DNA], DS: Double, CS: Double, DH: Int) -> ([Int], [Int]){
    let m = DNAs.count
    let l = DNAs[0].count
    let GAP = 0 // round 1/4
    var H = (0..<m).map{_ in 0}
    var S = (0..<m).map{_ in 0}
    var hm = [Int]()
    var sm = [Int]()
    for p in 0..<m{
        let sequence = DNAs[p]
        let reversedSequence = Array<DNABase>(sequence.reversed())
        for j in 0..<m{
            for g in 0..<GAP+1{
                let gVector = (0..<g).map{_ in DNABase.N}
                var extendedSeqY = DNAs[j]
                extendedSeqY.append(contentsOf: gVector)
                extendedSeqY.append(contentsOf: DNAs[j])
                for i in -l+1 ..< l{
                    let shiftedSeqY = shift(sequence: extendedSeqY, i: i)
                    let currentHm = hDis(x: reversedSequence, y: shiftedSeqY, DH: DH) + hCont(x: reversedSequence, y: shiftedSeqY, CH: CH)
                    H[j] = max(H[j], currentHm)
                    if p != j {
                        let currentSm = sHis(x: sequence, y: shiftedSeqY, DS: DS) + sCont(x: sequence, y: shiftedSeqY, CS: CS)
                        S[j] = max(S[j], currentSm)
                    }
                }
            }
        }
        hm.append(H.reduce(0, +))
        sm.append(S.reduce(0, +))
    }
    
    return (hm, sm)
}

fileprivate func ceq(x: DNA, at : Int)->Int{
    var i = at
    let l = x.count
    var count = 1
    while i<l-1 && x[i] == x[i+1]{
        count+=1
        i+=1
    }
    return count
}

fileprivate func ceq(x: DNA, y: DNA, at : Int)->Int{
    var i = at
    let l = x.count
    var count = 0
    while i<l && x[i] == y[i]{
        count+=1
        i+=1
    }
    return count
}

fileprivate func cbp(x: DNA, y: DNA, at: Int)->Int{
    let l = min(x.count, y.count)
    var i = at
    var count = 0
    while i<l && x[i] + y[i] == 3{
        i += 1
        count += 1
    }
    return count
}

fileprivate func pinlen(p: Int, r: Int, i: Int, l:Int)->Int{
    min(p+i, l-p-i-r)
}

fileprivate func shift(sequence: DNA, i: Int) -> DNA{
    if i==0 {return sequence}
    var temp = [DNABase]()
    
    temp.append(contentsOf: (0..<abs(i)).map{_ in DNABase.N})
    
    let l = sequence.count
    if i>0 && i<l{
        temp.append(contentsOf: sequence)
        return temp
    }
    if i < 0 && i > -l{
        var r = Array<DNABase>(sequence[abs(i) ..< l-abs(i)])
        r.append(contentsOf: temp)
        return r
    }
    
    temp = (0..<l).map{_ in DNABase.N}
    return temp
}

fileprivate func sCont(x: DNA, y: DNA, CS: Double)->Int{
    var sigmaEq = 0
    var i = 0
    let l = min(x.count, y.count)
    while i<l {
        let e = ceq(x: x, y: y, at: i)
        sigmaEq += Double(e)>CS*Double(l) ? e : 0
        i += 1
    }
    return sigmaEq
}

fileprivate func hCont(x: DNA, y: DNA, CH: Int) -> Int {
    var h = 0
    let l = min(x.count, y.count)
    for i in 0..<l {
        let c = cbp(x: x, y: y, at: i)
        h += c>CH ? c : 0
    }
    return h
}

fileprivate func hDis(x: DNA, y: DNA, DH: Int) -> Int{
    var sigmaBp = 0
    let l = min(x.count, y.count)
    for i in 0..<l {
        sigmaBp += x[i]+y[i]==3 ? 1 : 0
    }
    return sigmaBp>DH ? sigmaBp : 0
}

fileprivate func sHis(x: DNA, y: DNA, DS: Double) -> Int{
    var sigmaBp = 0
    let l = min(x.count, y.count)
    for i in 0..<l{
        sigmaBp += x[i].eq(y[i]) ? 1 : 0
    }
    return Double(sigmaBp) > DS*Double(l) ? sigmaBp : 0
}
