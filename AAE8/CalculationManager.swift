//
//  CalculationManager.swift
//  AAE8
//
//  Created by 이지선 on 7/31/25.
//

import SwiftUI

struct DisplayLabItem {
    static func processingDisplay (from labValues: [LabItem: Double], ref electroSelection: inout Set<Electrolyte>, to displayQueue: inout [LabItem]) {
        var addItems: [LabItem] = []
        if electroSelection.contains(.Na) { // Na가 select 되어 있고
            addItems.append(.pNa)
            if let pNa = labValues[.pNa] { //.pNa에 값이 있고
                if pNa < 135 {
                    addItems += [.pOsm, .uOsm, .volume, .uNa]
                } else if pNa > 145 {
                    addItems += [.volume, .uOsm,.urineOutput]
                }
            }
        }
        
        if electroSelection.contains(.K) {
            addItems.append(.pK)
            if let pK = labValues[.pK] {
                if pK < 3.5 {
                    addItems += [.uK, .uOsm, .pOsm, .volume]
                }
                else if pK > 5.5 {
                    addItems += [.uK, .uNa, .uOsm, .pOsm]
                }
            }
        }
        
        if electroSelection.contains(.pH) {
            addItems += [.pPH, .pHCO3, .pCO2, .pNa, .pCl, .acuteChronic]
            if let pPH = labValues[.pPH]{
                if pPH < 7.35 { //Acidosis
                    if let pAG = labValues[.pAG] {
                        if pAG > 12 { // High AG MAci
                            addItems += [.pOsm, .pNa, .glucose, .bun]
                        } else if pAG <= 12 { // Normal AG MAci
                            addItems += [.uNa, .uK, .uCl]
                        }
                    }
                } else if pPH > 7.45 { //Alkalosis
                    addItems += [.uCl, .volume]
                }
            }
        }
        
        displayQueue = Array(Set(addItems))
        
        //print(displayQueue)
    }
}

struct LabValueCalculator {
    static func compute(from labValues: inout [LabItem: Double]) {// calculatedOnly 항목은 입력 항목들로만 계산
            // Uine osmole excretion rate = usom(mosm/kg) x urine output(ml/d) / 1000
            if let uosm = labValues[.uOsm], let urineOutput = labValues[.urineOutput] {
                labValues[.urineOsmoleExcretionRate] = uosm * urineOutput / 1000
            } else {
                labValues.removeValue(forKey: .urineOsmoleExcretionRate)
            }
            // TTKG = (UK/PK) / (UOsm/POsm)
            if let pK = labValues[.pK], let uK = labValues[.uK], let uOsm = labValues[.uOsm], let pOsm = labValues[.pOsm], pK != 0, uOsm != 0, pOsm != 0 {
                let ttkg = (uK/pK) / (uOsm / pOsm)
                labValues[.TTKG] = ttkg
            } else {
                labValues.removeValue(forKey: .TTKG)
            }

            // AG = Na - Cl - HCO3
            if let na = labValues[.pNa], let cl = labValues[.pCl], let hco3 = labValues[.pHCO3] {
                labValues[.pAG] = na - cl - hco3
            } else {
                labValues.removeValue(forKey: .pAG) // ❗️하나라도 없으면 계산값 제거
            }

            //pOG = pOsm - (2xPNa + Glocose/18 + BUN/2.8) (mmol/L)
            if let pOsm = labValues[.pOsm], let pNa = labValues[.pNa], let glucose = labValues[.glucose], let bun = labValues[.bun] {
                labValues[.pOG] = pOsm - (2*pNa + glucose/18 + bun/2.8)
            } else {
                labValues.removeValue(forKey: .pOG)
            }
            
            //pDeltaRatio = (AG-12)/(24-PHCO3)
            if let na = labValues[.pNa], let cl = labValues[.pCl], let hco3 = labValues[.pHCO3], hco3 != 24 {
                let pAG = na - cl - hco3
                let deltaRatio = (pAG-12)/(24-hco3)
                labValues[.pDeltaRatio] = deltaRatio
            } else {
                labValues.removeValue(forKey: .pDeltaRatio)
            }
            
            //uAG = UNa + UK - UCl
            if let uNa = labValues[.uNa], let uK = labValues[.uK], let uCl = labValues[.uCl] {
                labValues[.uAG] = uNa + uK - uCl
            } else {
                labValues.removeValue(forKey: .uAG)
            }
            
            //pred.pCO2
            if let hco3 = labValues[.pHCO3] {
                if hco3 <= 24 { // if PHCO3<24 => Pred.PCO2 = 40-1.25x(24-PHCO3)
                    labValues[.predPCO2] = 40 - 1.25*(24-hco3)
                } else { // if PHCO3>24 => Pred.PCO2 = 40 + 0.75(PHCO3-24)
                    labValues[.predPCO2] = 40 + 0.75*(hco3-24)
                }
            } else {
                labValues.removeValue(forKey: .predPCO2)
            }
            
            //diff.pCO2 = PCO2 - Pred.PCO2
            if let hco3 = labValues[.pHCO3], let pCO2 = labValues[.pCO2] {
                if hco3 <= 24 { // if PHCO3<24 => Pred.PCO2 = 40-1.25x(24-PHCO3)
                    labValues[.diffPCO2] = pCO2 - (40 - 1.25*(24-hco3))
                } else { // if PHCO3>24 => Pred.PCO2 = 40 + 0.75(PHCO3-24)
                    labValues[.diffPCO2] = pCO2 - (40 + 0.75*(hco3-24))
                }
            } else {
                labValues.removeValue(forKey: .diffPCO2)
            }
            
            //pred.pHCO3
            if let pCO2 = labValues[.pCO2], let acuteChronic = labValues[.acuteChronic] {
                if acuteChronic == 1 && pCO2 >= 40 { //if Acute & PCO2 >40 => Pred.PHCO3 = 24 + 0.1x(PCO2-40)
                    labValues[.predHCO3] = 24 + 0.1*(pCO2-40)
                } else if acuteChronic == 0 && pCO2 >= 40 { //if Chronic & PCO2 > 40 => Pred.PHCO3 = 24 + 0.4(PCO2-40)
                    labValues[.predHCO3] = 24 + 0.4*(pCO2-40)
                } else if acuteChronic == 1 && pCO2 < 40 { // if Acute & PCO2 < 40 => Pred.PHCO3 = 24 - 0.2(40-PCO2)
                    labValues[.predHCO3] = 24 - 0.2*(40-pCO2)
                } else if acuteChronic == 0 && pCO2 < 40 { //if Chronic & PCO2 < 40 => Pred.PHCO3 = 24 - 0.4(40-PCO2))
                    labValues[.predHCO3] = 24 - 0.4*(40-pCO2)
                }
            } else {
                labValues.removeValue(forKey: .predHCO3)
            }
            
            //diff.pHCO3
            if let pCO2 = labValues[.pCO2], let acuteChronic = labValues[.acuteChronic], let pHCO3 = labValues[.pHCO3] {
                if acuteChronic == 1 && pCO2 >= 40 { //if Acute & PCO2 >40 => Pred.PHCO3 = 24 + 0.1x(PCO2-40)
                    labValues[.diffHCO3] = pHCO3 - (24 + 0.1*(pCO2-40))
                } else if acuteChronic == 0 && pCO2 >= 40 { //if Chronic & PCO2 > 40 => Pred.PHCO3 = 24 + 0.4(PCO2-40)
                    labValues[.diffHCO3] = pHCO3 - (24 + 0.4*(pCO2-40))
                } else if acuteChronic == 1 && pCO2 < 40 { // if Acute & PCO2 < 40 => Pred.PHCO3 = 24 - 0.2(40-PCO2)
                    labValues[.diffHCO3] = pHCO3 - (24 - 0.2*(40-pCO2))
                } else if acuteChronic == 0 && pCO2 < 40 { //if Chronic & PCO2 < 40 => Pred.PHCO3 = 24 - 0.4(40-PCO2))
                    labValues[.diffHCO3] = pHCO3 - (24 - 0.4*(40-pCO2))
                }
            } else {
                labValues.removeValue(forKey: .diffHCO3)
            }
        }
}

struct cCriteriaCalculationManager {
    static func evaluatecCriteria(
        labValues: [LabItem:Double],
        parameter: LabItem,
        threshold: Double,
        direction: Direction
    ) -> Bool {
        guard let value = labValues[parameter] else { return false } // 값이 없으면 false
        
        switch direction {
        case .high :
            if value < threshold {return false} else {return true}
        case .low :
            if value >= threshold {return false} else {return true}
        }
    }
}

struct CMDUtils {
    static func cCriteriaLeafMeaning(
        criterias: [CCriteria],
        meaningDict: [Int: Meaning]
    ) -> [Meaning] {
        var meaningIDs: [Int] = []
        for criteria in criterias {
            meaningIDs += criteria.meaningID
            //print(criteria, meaningIDs)
        }
        let uniqueMeaningIDs = Set(meaningIDs)
        let uniqueMeanings = Array(uniqueMeaningIDs.compactMap{meaningDict[$0]})
        //print(uniqueMeanings)
        
        var leafMeanings: [Meaning] = []
        for m in uniqueMeanings {
            var isLeaf = true
            for tailID in m.tailMID {
                if uniqueMeaningIDs.contains(tailID) {
                    isLeaf = false
                    break
                } else {
                    continue
                }
            }
            if isLeaf {
                leafMeanings.append(m)
            }
        }
        return leafMeanings
    }
    
    static func criteriaPathToMeaning(criteriaPaths:[[CCriteria]], meaningDict: [Int: Meaning]
    ) -> [Meaning: [[CCriteria]]] { // [1: [path1, path2, ...] ]
        var result: [Meaning: [[CCriteria]]] = [:]
        for path in criteriaPaths {
            for (i,c) in path.enumerated() {
                for m in c.meaningID.compactMap({meaningDict[$0]}){
                    result[m, default: []].append(Array(path[...i]))
                }
            }
        }
        return result
    }
    
    static func meaningToTailEndMeaning(meaning: Meaning, meaningDict: [Int: Meaning]) -> [Meaning] {
        var queue = [meaning]
        var result: [Meaning] = []
        
        while !queue.isEmpty{
            let meaning = queue.removeFirst()
            result.append(meaning)
            queue += meaning.tailMID.compactMap({meaningDict[$0]})
        }
        return result
    }
    
    static func meaningToDisease( // 하위 M의 disese 다 포함 + 중복없앰
        meaning: Meaning,
        meaningDict: [Int: Meaning],
        diseaesDict: [Int: Disease]
    ) -> [Disease] {
        var queue: [Meaning] = [meaning]
        var diseases: [Disease] = []
        
        while !queue.isEmpty {
            let meaning = queue.removeFirst()
            diseases += meaning.diseaseID.compactMap{diseaseDict[$0]}
            queue += meaning.tailMID.compactMap{meaningDict[$0]}
        }
        return Array(Set(diseases))
    }
    
//    // 가장 끄트머리의 cCriteria의 meaning 부터 ~ disease 직전 meaning까지
//    // M(cCriteria) -> M(mechanism) -> M(mechanism) ->  M(mechanism) -> ...
//    static func diseaseToMinimumMeaningRoute(
//        meaning: Meaning,
//        meaningDict: [Int: Meaning],
//        diseaesDict: [Int: Disease]
//    ) -> [Disease: [[Meaning]] ] {
//        var queue: [(current: Meaning, path: [Meaning])] = []
//        queue.append((current: meaning, path: [meaning]))
//        var diseaseRouteDict: [Disease: [[Meaning]] ] = [:]
//        
//        while !queue.isEmpty {
//            let (currentMeaning, path) = queue.removeFirst()
//            let diseases = currentMeaning.diseaseID.compactMap{diseaseDict[$0]}
//            for d in diseases {
//                diseaseRouteDict[d, default: []].append(path)
//            }
//            let tailMeanings = currentMeaning.tailMID.compactMap{meaningDict[$0]}
//            for m in tailMeanings {
//                if m.category == .cCriteria { // m 이 ccriteria 타입이면 새로 시작 (여태까지 path는 버리고)
//                    queue.append((current: m, path: [m]))
//                } else {
//                    queue.append((current: m, path: path + [m]))
//                }
//            }
//        }
//        
//        return diseaseRouteDict
//    }
    
    // "diseaseRoute": Disease의 route를 전부 저장하는 딕셔너리 만들기
    // Meaning에 root Meaning(headID가 없는)을 넣어서 각 Disease들 full meaning route 반환. BFS 사용.
    static func diseaseToFullMeaningRoute(
        meaning: Meaning,
        meaningDict: [Int: Meaning],
        diseaesDict: [Int: Disease]
    ) -> [Disease: [[Meaning]] ] {
        var queue: [(current: Meaning, path: [Meaning])] = []
        queue.append((current: meaning, path: [meaning]))
        var diseaseRouteDict: [Disease: [[Meaning]] ] = [:]
        
        while !queue.isEmpty {
            let (currentMeaning, path) = queue.removeFirst()
            let diseases = currentMeaning.diseaseID.compactMap{diseaseDict[$0]}
            for d in diseases {
                diseaseRouteDict[d, default: []].append(path)
            }
            let tailMeanings = currentMeaning.tailMID.compactMap{meaningDict[$0]}
            for m in tailMeanings {
                queue.append((current: m, path: path + [m]))
            }
        }
        
        return diseaseRouteDict
    }
    
//    enum RouteID: Hashable, CustomStringConvertible {
//        case meaning(Int)
//        case disease(Int)
//        
//        var description: String {
//            switch self {
//            case .meaning(let id): return "M\(id)"
//            case .disease(let id): return "D\(id)"
//            }
//        }
//    }
    
    //Disease의 route를 전부 저장하는 딕셔너리
    static func buildDiseaseRoute(
            meaningDict: [Int: Meaning],
            diseaseDict: [Int: Disease]
    ) -> [Disease: [[String]]] {
        var result: [Disease: [[String]] ] = [:]
        let rootMeanings = MeaningStore.shared.rootMeanings
        let routeDict = rootMeanings
            .map { CMDUtils.diseaseToFullMeaningRoute(meaning: $0, meaningDict: meaningDict, diseaesDict: diseaseDict) }
            .reduce(into: [Disease: [[Meaning]]]() ) { result, dict in
                for (disease, routes) in dict {
                    result[disease, default: []] += routes
                }
            }
        for (disease, routes) in routeDict {
            for route in routes{
                var routeIDs: [String] = route.map { "M"+String($0.id) }
                
                // Disease head 넣기. D계층은 최대 한 층이어야 함. ... > M > D > D 이어야 함 (D > D > D X)
                if let leafM = route.last {
                    for headID in disease.resultDID {
                        if leafM.diseaseID.contains(headID) {
                            routeIDs.append("D"+String(headID))
                        }
                    }
                }
                result[disease, default: []].append(routeIDs)
            }
        }
        return result
    }
    
    
    static func CCriteriaRouteToString (criteriaPath: [CCriteria]) -> String {
        var criteriaStrs: [String] = []
        for c in criteriaPath {
            if c.para == .volume {
                var satisfyingValues: [VolumeStatusOption] = []
                for option in VolumeStatusOption.allCases {
                    if cCriteriaCalculationManager.evaluatecCriteria(labValues: [.volume:Double(option.numericValue)], parameter: c.para, threshold: c.thres, direction: c.direction) {
                        satisfyingValues.append(option)
                    }
                }
                let resultStr = satisfyingValues.compactMap({$0.rawValue}).joined(separator: ", ")
                criteriaStrs.append(resultStr)
                
            } else if c.para == .acuteChronic {
                var satisfyingValues: [AcuteChronicOption] = []
                for option in AcuteChronicOption.allCases {
                    if cCriteriaCalculationManager.evaluatecCriteria(labValues: [.acuteChronic:Double(option.numericValue)], parameter: c.para, threshold: c.thres, direction: c.direction) {
                        satisfyingValues.append(option)
                    }
                }
                let resultStr = satisfyingValues.compactMap({$0.rawValue}).joined(separator: ", ")
                criteriaStrs.append(resultStr)
                
            } else {
                let type = c.para.type
                let prefix = (type == "Plasma") ? "p" :
                             (type == "Urine") ? "u" : ""
                let para = c.para.displayName
                let thres = String(format: "%.2f", c.thres)
                let dir = c.direction == .high ? "↑" : "↓"
                criteriaStrs.append("\(prefix)\(para) \(thres) \(dir)")
            }
        }
        return criteriaStrs.joined(separator: " & ")
    }
    
//    static func findRouteWithinDiseasesForAMeaning(
//        meaning:Meaning, diseaesDict: [Int: Disease]
//    ) ->  [(Int, [Int])]{
//        let candidateDIDs = meaning.diseaseID
//        var result: [(Int, [Int])] = []
//
//        func addHeads(current: Int, path:[Int]) {
//            guard let heads = diseaseDict[current]?.resultDID else {
//                result.append((current, path))
//                return
//            }
//
//            for head in heads {
//                if candidateDIDs.contains(head) {
//                    addHeads(current: head, path: [head]+path)
//                } else {
//                    result.append((current, path))
//                    return
//                }
//            }
//        }
//
//        for dID in candidateDIDs {
//            addHeads(current: dID, path: [dID])
//        }
//
//        return result
//    }
    
//    static func findRouteWithinDiseases(
//        meaning:Meaning, disease: Disease, diseaesDict: [Int: Disease]
//    ) -> [[String]] {
//        let candidateDIDs = meaning.diseaseID
//        var result: [[String]] = []
//
//
//        func findingHead(current: Disease, path: [String]) {
//            if current.resultDID.count == 0{
//                result.append(path)
//            } else {
//                for headID in current.resultDID {
//                    if candidateDIDs.contains(headID) {
//                        let head = diseaseDict[headID]
//                        findingHead(current: head!, path: [head!.name] + path)
//                    } else {
//                        result.append(path)
//                    }
//                }
//            }
//
//        }
//
//        findingHead(current: disease, path: [])
//
//        return result
//    }
    
}
