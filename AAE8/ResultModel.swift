//
//  ResultLogic.swift
//  AAE8
//
//  Created by 이지선 on 8/3/25.
//

import Foundation

struct meaningWithTailC: Hashable {
    let m: Meaning
    let tailC: [CCriteria]
}

struct causeCard: Identifiable {
    let disease: Disease
    let paths: [[Meaning]]
    
    var id: Int { disease.id }
}

struct ResultLogic {
    //MARK: cStructure 만들기
    //백트래킹 이용
    static func buildCStructures(
            data: LabData,
            rootCriteriaList: [CCriteria],
            cCriteriaDict: [Int: CCriteria]
    ) -> ([CCriteria], [[CCriteria]]) {
        var matchedcCriteria: [CCriteria] = []
            // [C1, C2, C3, C4, C5, C7]
        var matchedcCriteriaPaths: [[CCriteria]] = []
            // [C1-C2-C3-C4, C1-C2-C3-C5-C7]
        
        //선택한 전해질에 대해서만 계산 진행
        let relatedRootCriterias = rootCriteriaList.filter { data.selectedElectrolytes.contains($0.electrolyte) }
        
        for root in relatedRootCriterias {
            if cCriteriaCalculationManager.evaluatecCriteria(labValues: data.labValues, parameter: root.para, threshold: root.thres, direction: root.direction){ // 만족하는 root만
                matchedcCriteria.append(root)
                if root.meaningID.isEmpty { // Meaning이 없는 criteria는 보통 criteria 두 개 이상을 동시에 만족해야 의미가 있는 경우 (e.g., Normonatremia : pNa <145 & pNa > 135)
                    _ = dfs(current: root, path: [], temp: [root], data: data, matchedcCriteria: &matchedcCriteria, matchedcCriteriaPaths: &matchedcCriteriaPaths, cCriteriaDict: cCriteriaDict)
                } else { // Meaning이 있는 criteria는 그 자체로 유의미 (e.g., Hyponatremia : pNa<135)
                    _ = dfs(current: root, path: [root], temp: [], data: data, matchedcCriteria: &matchedcCriteria, matchedcCriteriaPaths: &matchedcCriteriaPaths, cCriteriaDict: cCriteriaDict)
                }
            }
        }
        
        return (matchedcCriteria, matchedcCriteriaPaths)
    }
    
    //current = 만족을 확인한 criteria
    private static func dfs(
            current: CCriteria,
            path: [CCriteria],
            temp: [CCriteria],
            data: LabData,
            matchedcCriteria: inout [CCriteria],
            matchedcCriteriaPaths: inout [[CCriteria]],
            cCriteriaDict: [Int: CCriteria]
    ) -> Bool {
        let tailCriterias = current.tailCID.compactMap { cCriteriaDict[$0] }
        var hasValidChild = false
        
        for next in tailCriterias { // 만족하는 'meaning있는 tailC(또는 tailC뭉치)'가 하나라도 있으면 current는 path의 꼬랑지가 아니다 (hasValidChild = true)
            if cCriteriaCalculationManager.evaluatecCriteria(
                labValues: data.labValues,
                parameter: next.para,
                threshold: next.thres,
                direction: next.direction
            ) {
                matchedcCriteria.append(next)
                if next.meaningID.isEmpty { // 만족하는 tailC가 meaning이 없다 = tailC 여러개가 뭉치로 의미를 갖는다 = 단계 더 들어가서 뭉치를 다 만족하는지 (meaning을 갖는 criteria까지 전부 만족하는지) 봐야 안다
                    hasValidChild = hasValidChild || dfs(current: next, path: path, temp: temp + [next], data: data, matchedcCriteria: &matchedcCriteria, matchedcCriteriaPaths: &matchedcCriteriaPaths, cCriteriaDict: cCriteriaDict)
                } else { // meaning이 있는 tailC가 있다 = current는 path의 꼬랑지는 아니다
                    hasValidChild = true // current는 path의 꼬랑지는 아니다
                    _ = dfs(current: next, path: path + temp + [next], temp: [], data: data, matchedcCriteria: &matchedcCriteria, matchedcCriteriaPaths: &matchedcCriteriaPaths, cCriteriaDict: cCriteriaDict)
                }
            }
        }
        
        // 끝에 meaningID가 있고, 더 이상 유효한 child가 없을 때(=current가 path의 꼬랑지다)만 path에 저장
        if !hasValidChild && !current.meaningID.isEmpty {
            matchedcCriteriaPaths.append(path)
        }
        // 끝에 meaningID가 없으면 path에 저장하지 않고 버린다.
        
        return hasValidChild
    }
    
    //MARK: mStructures 만들기
    static func buildMStructures(
            matchedcCriteriaPaths: [[CCriteria]],
            meaningDict: [Int: Meaning]
    ) -> [[meaningWithTailC]] {
        // cStructures(=matchedcCriteriaPaths): [C1-C2-C3-C4, C1-C2-C3-C5-C7]
        // mStructures: [ M1(C1-C2)-M3(C3), M1(C1-C2)-M2(C3)-M3(C4), M1(C1-C2)-M2(C3)-M5(C5-C7) ]
        var totalmeaningPaths: [[meaningWithTailC]] = []
        
        for cStructure in matchedcCriteriaPaths {
            var priorPaths: [[meaningWithTailC]] = []
            var currentPaths: [[meaningWithTailC]] = []
            var prev: Int = -1
            var cur: Int = 0
            let endIndex = cStructure.count
            while cur < endIndex {
                let c = cStructure[cur]
                let tailCs = Array(cStructure[prev+1...cur])
                
                if c.meaningID.count == 0 {
                    cur += 1 // meaning을 갖는 tailC 뭉치(=tailCs)가 될 때까지 커서를 옮김
                    continue
                }
                
                //meaning을 갖는 tailC(또는 tailCs)가 되면
                for mID in c.meaningID {
                    guard let m = meaningDict[mID] else {continue}
                    let mComplex = meaningWithTailC(m: m, tailC: tailCs)
                    
                    var isRoot = true
                    for existingPath in priorPaths { // 현재까지 (m)path가 여러개라면 이번 m을 어디에 붙일지
                        guard let leafM = existingPath.last else {continue}
                        if leafM.m.tailMID.contains(mID) {
                            currentPaths.append(existingPath + [mComplex])
                            isRoot = false
                        } else {
                            currentPaths.append(existingPath)
                        }
                    }
                    if isRoot { // 붙일 (m)path가 없으면 자신을 root로 새 (m)path 만듦.
                        currentPaths.append([mComplex])
                    }
                }
                
                priorPaths = currentPaths
                currentPaths = []
                prev = cur // tailCs 만들기 새로 시작
                cur += 1
            }
        totalmeaningPaths += priorPaths
        }
        
        return totalmeaningPaths
    }
    
    //MARK: MultiPathsSelection - Disease 추리기
    // mStructures 기반으로 disease 추리고 나열
    static func multiPathSelection(
        paths: [[Meaning]],
        meaningToDisease: [Meaning: [Disease]]
    ) -> [causeCard] {
        
        // 1. path들 간 겹치는 Meaning들은 빼기 - (e.g., Metabolic acidosis, Respiratory acidosis => Acidosis로 겹치는 경우는 의미가 없음)
        //Meaning 등장 횟수 계산
        var meaningCount: [Meaning: Int] = [:]
        for path in paths {
            for m in path {
                meaningCount[m, default: 0] += 1
            }
        }
        // 등장 횟수가 1인 Meaning만 남기기
        let filteredPaths = paths.map { path in
            path.filter { meaningCount[$0] == 1 }
        }
        
        // 2. Meaning 조합 순서 정하기
        var finalMComplexes: [[Meaning]] = []
        var mComplexInProcess: [Meaning] = []
        func dfs(i: Int) {
            if i >= filteredPaths.count {
                finalMComplexes.append(mComplexInProcess)
                return
            }
            var path = filteredPaths[i]
            while !path.isEmpty {
                let m = path.removeLast()
                mComplexInProcess.append(m)
                dfs(i: i+1)
                mComplexInProcess.removeLast()
            }
        }
        dfs(i: 0)
        //print("🍃\(finalComplexes)")
        
        // 3. 가장 작은 범위 조합부터 해당되는 diseases들부터 배치
        var result: [Disease] = []
        var diseaseAndFinalMComplex: [(Disease, [Meaning])] = []
        guard let mostBroadComplex = finalMComplexes.last else {return []}
        var wholeDiseases = diseasesSatisfyingAllMeanings(meanings: mostBroadComplex, meaningToDisease: meaningToDisease)
        for finalMComplex in finalMComplexes {
            for d in diseasesSatisfyingAllMeanings(meanings: finalMComplex, meaningToDisease: meaningToDisease).sorted(by: { $0.id < $1.id }) { //귀찮아. 순서가 유지만 되면 되니까 걍 id 순 나열.
                if wholeDiseases.contains(d) {
                    result.append(d)
                    diseaseAndFinalMComplex.append((d, finalMComplex))
                    wholeDiseases.removeAll { $0.id == d.id }
                }
            }
        }
        
        // 4. finalComplex의 path화
        var causeCards: [causeCard] = []
        for (disease, meaningComplex) in diseaseAndFinalMComplex {
            let diseasePaths = meaningComplexToMeaningPath(meaningComplex: meaningComplex, paths: paths)
            causeCards.append(causeCard(disease: disease, paths: diseasePaths))
        }
        
        return causeCards
    }
    
    private static func diseasesSatisfyingAllMeanings(meanings: [Meaning], meaningToDisease: [Meaning: [Disease]]) -> [Disease] {
        guard !meanings.isEmpty else { return [] }

        // Convert each Meaning to a Set of Disease IDs
        let diseaseSets: [Set<Disease>] = meanings.map { Set(meaningToDisease[$0] ?? []) }

        // Find intersection of all sets (common diseases)
        let commonDiseases = diseaseSets.dropFirst().reduce(diseaseSets[0]) { $0.intersection($1) }

        // Return actual Disease objects
        return Array(commonDiseases)
    }
    
    private static func meaningComplexToMeaningPath(meaningComplex: [Meaning], paths: [[Meaning]]) -> [[Meaning]] {
        var result: [[Meaning]] = []
        
        let totalPathNumber = paths.count
        for i in 0...totalPathNumber-1{
            let path = paths[i]
            var pathProcessing:[Meaning] = []
            for m in path { // path 젤 앞에서부터 meaning 나올 때 끊기
                pathProcessing.append(m)
                if m == meaningComplex[i] {
                    break
                }
            }
            result.append(pathProcessing)
        }
        
        return result
    }
    
}
