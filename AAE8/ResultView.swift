//
//  ResultView.swift
//  AAE8
//
//  Created by 이지선 on 7/31/25.
//

import SwiftUI

struct ResultViewNew: View {
    let data: LabData
    
    let cCriteriaDict = CCriteriaStore.shared.all
    let rootCriteriaList = CCriteriaStore.shared.rootCriterias
    let cCRelationList = CCriteriaStore.shared.cCRelation
    let cMRelationList = CCriteriaStore.shared.cMRelation
    
    let meaningDict = MeaningStore.shared.all
    let mMRelationList = MeaningStore.shared.mMRelation
    let mDRelationList = MeaningStore.shared.mDRelation
    
    let diseaseDict = DiseaseStore.shared.all
    
    var headMIDDictByTailDID: [Int: [HeadTailRelation]] {
        Dictionary(grouping: mDRelationList, by: { $0.tailID })
    }
    var headMIDDictByTailMID: [Int: [HeadTailRelation]] {
        Dictionary(grouping: mMRelationList, by: { $0.tailID })
    }
    //하위 Meaning의 disease까지 다 포함하는 딕셔너리
    var meaningToDisease: [Meaning: [Disease]] {
        Dictionary(uniqueKeysWithValues:
                meaningDict.values.map { meaning in
                    (meaning, CMDUtils.meaningToDisease(
                        meaning: meaning,
                        meaningDict: meaningDict,
                        diseaesDict: diseaseDict
                    ))
                }
            )
    }
    //Disease의 route를 전부 저장하는 딕셔너리
    var diseaseRoute: [Disease: [[String]] ] {
        var result: [Disease: [[String]] ] = [:]

        let rootMeaning = meaningDict.values.filter { headMIDDictByTailMID[$0.id] == nil }.sorted {
            guard let i0 = Electrolyte.displayOrder.firstIndex(of: $0.electrolyte),
                      let i1 = Electrolyte.displayOrder.firstIndex(of: $1.electrolyte) else {
                    return false
                }
                if i0 != i1 {
                    return i0 < i1
                } else {
                    return $0.order < $1.order // order는 Meaning 안의 Double
                }
        }
        for meaning in rootMeaning {
            let routeDict = CMDUtils.diseaseToFullMeaningRoute(
                meaning: meaning,
                meaningDict: meaningDict,
                diseaesDict: diseaseDict
            )

            for (disease, routes) in routeDict {
                for route in routes{
                    var fullMeaningRouteKey: [String] = route.map { "M"+String($0.id)}
                    
                    // Disease head 넣기
                    let headIDs = disease.resultDID
                    if let leafM = route.last {
                        for headID in headIDs {
                            if leafM.diseaseID.contains(headID) {
                                fullMeaningRouteKey.append("D"+String(headID))
                            }
                        }
                    }
                    result[disease, default: []].append(fullMeaningRouteKey)
                }
            }
        }

        return result
    }
    
    typealias criteriaPath = [CCriteria]
    @State private var waitingCriteriaQueue: [(current: CCriteria, path: criteriaPath)] = []
    @State private var matchedcCriteria: [CCriteria] = []
    @State private var matchedcCriteriaPaths: [criteriaPath] = []
    typealias meaningPath = [meaningWithTailC]
    @State private var mStructures: [[meaningWithTailC]] = []

//    @State private var meaningPath: [meaningPath] = []
    
    var body: some View {
        NavigationStack {
            ScrollView{
                VStack(spacing: 20) {
                    selectedElectrolytesHeader
                    //labDataSection
                    interpretationSection
                    topCausesSection
                }
                .padding()
            }
            .onAppear {
                //waitingCriteriaQueue = []
                matchedcCriteria = []
                matchedcCriteriaPaths = []
                mStructures = []
                
//                meaningToDiseaseDict = Dictionary(uniqueKeysWithValues:
//                        meaningDict.values.map { meaning in
//                            (meaning, CMDUtils.meaningToDisease(
//                                meaning: meaning,
//                                meaningDict: meaningDict,
//                                diseaesDict: diseaseDict
//                            ))
//                        }
//                    )
                
                //initializeQueue()
                //matchingCCriteria()
                backtrackAllCCriteriaPaths()
                mStructures = makeMeaningPaths()
            }
            .navigationTitle("Analysis Result")
//            }
        }
    }
    
    // MARK: - Sections
    // 1. Electrolyte
    private var selectedElectrolytesHeader: some View { // 전해질 순서 첫 화면이랑 맞추기
        HStack(spacing: 6) {
            ForEach(Electrolyte.displayOrder.filter { data.selectedElectrolytes.contains($0)}, id: \.self) { electrolyte in
                    ElectrolyteCircleView(electrolyte: electrolyte)
            }
            Spacer()
            NavigationLink(destination: InterpretationMoreView(
                matchedcCriteria: matchedcCriteria,
                matchedcCriteriaPaths: matchedcCriteriaPaths,
                mStructures: mStructures,
                diseaseRoute: diseaseRoute)) {
                Text("More")
                    .font(.caption)
                    .bold()
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.customGray.opacity(0.3))
                    .foregroundColor(.customDarkBlue)
                    .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.customDarkBlue, lineWidth: 1) // ✅ 테두리 추가
                        )
                    .cornerRadius(5)
            }
        }
        .padding(.leading, 4)
    }
    
//    // 2. Lab data
//    private var labDataSection: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            Text("Lab Data").font(.title3).bold()
//
//
//            HStack(alignment: .top) {
//                VStack(alignment: .leading, spacing: 6) {
//                    labItemView(.pNa)
//                    labItemView(.pK)
//                }
//
//                Spacer(minLength: 16)
//
//                Rectangle()
//                    .fill(Color.gray.opacity(0.4))
//                    .frame(width: 1, height: 40)
//
//                Spacer(minLength: 16)
//
//                VStack(alignment: .leading, spacing: 6) {
//                    labItemView(.uNa)
//                    labItemView(.uK)
//                }
//                .padding(.trailing, 20)
//            }
//        }
//    }
    
    // 3. Interpretation
    @State private var expandedPathIndices: Set<Int> = []
    @State private var selectedMeaningPathIndices: Set<Int> = []
    private var interpretationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("Interpretation")

            ForEach(Array(mStructures.enumerated()), id: \.offset) { index, path in
                HStack(alignment: .center) {
                    Button(action: {
                        if expandedPathIndices.contains(index) {
                            expandedPathIndices.remove(index)
                        } else {
                            expandedPathIndices.insert(index)
                        }
                    }) {
                        Image(systemName: expandedPathIndices.contains(index) ? "chevron.down" : "chevron.right")
                            .foregroundColor(.customGray)
                            .padding(.trailing, 4)
                            .frame(width: 20, height: 44)
                            .padding(.top, 2)
                    }
                    .frame(maxHeight: .infinity)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        let rootMeaning = path.first?.m
                        let arrow = rootMeaning?.arrow
                        
                        if let leafNode = path.last {
                            InterpretationRow(
                                arrow: arrow,
                                leafNode: leafNode,
                                index: index,
                                selectedMeaningPathIndices: $selectedMeaningPathIndices,
                                expandedPathIndices: $expandedPathIndices
                            )
//                            .padding(.vertical, 12)
//                            .padding(.horizontal, 12)
//                            .frame(minHeight: 44)
//                            .frame(maxWidth: .infinity)
//                            .contentShape(Rectangle())

                        }
                        
                        if expandedPathIndices.contains(index) {
                            InterpretationDetail(path: path)
                                .padding(.horizontal, 12)
                                .padding(.bottom, 8)
                        }
                    }
                    .background(
                        ZStack {
                            if selectedMeaningPathIndices.contains(index) {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.customWhite.opacity(0.2)) // ✅ 내부 색상 추가
                            }
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selectedMeaningPathIndices.contains(index) ? Color.customGreen : Color.customGray, lineWidth: 1)
                        }
                    )
                }
            }
        }
    }
    
    
    
    // 4. Top causes
    @State private var expandedDiseases: Set<Int> = []
    private var topCausesSection: some View {
        
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("Possible Causes")
            let selectedPaths: [[Meaning]] = selectedMeaningPathIndices.map { index in
                mStructures[index].map({$0.m})
            }
            if selectedPaths.count >= 2 {
                let inferredDiseases = multiPathSelection(paths: selectedPaths).filter{$0.disease.typical == true}
                if inferredDiseases.isEmpty {
                    Text("No disease matched all selected meanings.")
                        .font(.caption)
                        .foregroundColor(.gray)
                } else {
                    ForEach(Array(inferredDiseases.enumerated()), id: \.offset) { index, card in
                        VStack(alignment: .leading, spacing: 4) {
                            TopCauseRow(card: card, index: index, expandedIndices: $expandedDiseases)
                            if expandedDiseases.contains(index) {
                                TopCauseDetailWithDots(card: card, diseaseRoute: diseaseRoute, meaningDict: meaningDict, diseaseDict: diseaseDict)
                            }
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 12).stroke())
                    }
                }
            } else if selectedPaths.count == 1{ // path를 전부 만족하는 항목들만 보여줌 (부분 만족은 more view에서 보도록)
                let path = selectedPaths.flatMap({$0})
                if let leafMeaning = path.last {
                    let rootNodes = meaningToCauseNode(meaning: leafMeaning, path: path).children
                    ForEach(rootNodes) { rootNode in
                        singlePathTreeView(node: rootNode, depth: 0, diseaseRoute: diseaseRoute)
                    }
                    
                }
                Text("💡 Tap 'More' to see possible causes and full reasoning.")
            }
        }
        
    }
    
    // MARK: - Helper Views
    private func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title).font(.title3).bold()
            Spacer()
        }
    }
    
    // MARK: - Data processing
//    // cStructures 만들기
//    func initializeQueue(){
//        // ContentView에서 선택한 전해질과 관련된 rootCriteria만
//        let relatedRootCriterias = rootCriteriaList.filter{data.selectedElectrolytes.contains($0.electrolyte)}
//        //print("Related root criterias: \(relatedRootCriterias)")
//        for rootCriteria in relatedRootCriterias { // relatedRootCriteria 중에서도 만족하는 것만 큐에 넣기
//            if cCriteriaCalculationManager.evaluatecCriteria(labValues: data.labValues, parameter: rootCriteria.para, threshold: rootCriteria.thres, direction: rootCriteria.direction) {
//                self.matchedcCriteria.append(rootCriteria)
//                self.waitingCriteriaQueue.append((current: rootCriteria, path: [rootCriteria]))
//            }
//        }
//        //print("🧩 Root CCriteria IDs: \(relatedRootCriterias)")
//    }
//    
//    func matchingCCriteria() { //waitingCriteriaQueue에는 이미 true가 입증된 것들만 들어있음
//        while !waitingCriteriaQueue.isEmpty {
//            let (currentCriteria, path) = waitingCriteriaQueue.removeFirst()
//            
//            var isLeaf = true
//            let nextIDs = currentCriteria.tailCID
//            let tailCriterias = nextIDs.compactMap { cCriteriaDict[$0] }
//            for tailCriteria in tailCriterias {
//                if cCriteriaCalculationManager.evaluatecCriteria(labValues: data.labValues, parameter: tailCriteria.para, threshold: tailCriteria.thres, direction: tailCriteria.direction) {
//                    matchedcCriteria.append(tailCriteria)
//                    waitingCriteriaQueue.append((current: tailCriteria, path: path + [tailCriteria]))
//                    isLeaf = false
//                }
//            }
//            
//            if isLeaf {
//                if currentCriteria.meaningID.count != 0{
//                    matchedcCriteriaPaths.append(path)
//                }
//            }
//        }
//        //print("🧩 matchedCriterias:: \(matchedcCriteria)")
//        print("🧩 matchedCriteriaPaths: \(matchedcCriteriaPaths)")
//        print("🧩 matchedCriteriaPaths: \(matchedcCriteriaPaths.count)")
//    }
    
    //cStructures 만들기 - 백트래킹
    func backtrackAllCCriteriaPaths() {
        matchedcCriteria = []
        matchedcCriteriaPaths = []

        let relatedRootCriterias = rootCriteriaList.filter { data.selectedElectrolytes.contains($0.electrolyte) }

        for root in relatedRootCriterias {
            if cCriteriaCalculationManager.evaluatecCriteria(labValues: data.labValues, parameter: root.para, threshold: root.thres, direction: root.direction){
                matchedcCriteria.append(root)
                if root.meaningID.isEmpty {
                    dfs(current: root, path: [], temp: [root])
                } else {
                    dfs(current: root, path: [root], temp: [])
                }
            }
        }

        print("🧩 DFS matchedCriteriaPaths: \(matchedcCriteriaPaths.count)")
    }

    func dfs(current: CCriteria, path: [CCriteria], temp: [CCriteria]) -> Bool{

        let tailCriterias = current.tailCID.compactMap { cCriteriaDict[$0] }

        var hasValidChild = false
        for next in tailCriterias {
            if cCriteriaCalculationManager.evaluatecCriteria(
                labValues: data.labValues,
                parameter: next.para,
                threshold: next.thres,
                direction: next.direction
            ) {
                matchedcCriteria.append(next)
                if next.meaningID.isEmpty {
                    hasValidChild = hasValidChild || dfs(current: next, path: path, temp: temp + [next])
                } else {
                    hasValidChild = true
                    dfs(current: next, path: path + temp + [next], temp: [])
                }
            }
        }

        // 끝에 meaningID가 있고, 더 이상 유효한 child가 없을 때만 저장
        if !hasValidChild && !current.meaningID.isEmpty {
            matchedcCriteriaPaths.append(path)
        }
        
        return hasValidChild
    }
    
    
    // mStructures 만들기
    func makeMeaningPaths() ->  [[meaningWithTailC]] {
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
                    cur += 1
                    continue
                }
                
                for mID in c.meaningID {
                    guard let m = meaningDict[mID] else {continue}
                    let mComplex = meaningWithTailC(m: m, tailC: tailCs)
                    
                    var isRoot = true
                    for existingPath in priorPaths {
                        guard let leafM = existingPath.last else {continue}
                        if leafM.m.tailMID.contains(mID) {
                            currentPaths.append(existingPath + [mComplex])
                            isRoot = false
                        } else {
                            currentPaths.append(existingPath)
                        }
                    }
                    if isRoot {
                        currentPaths.append([mComplex])
                    }
                }
                
                priorPaths = currentPaths
                currentPaths = []
                prev = cur
                cur += 1
            }
        totalmeaningPaths += priorPaths
        }
        print("🍃mStructures: \(totalmeaningPaths)")
    return totalmeaningPaths
    }
    
    
    // mStructures 기반으로 disease 추리고 나열
    func multiPathSelection(paths: [[Meaning]]) -> [causeCard] {
        
        // m 조합 순서 정하기
        var finalComplexes: [[Meaning]] = []
        var complexInProcess: [Meaning] = []
        func dfs(i: Int) {
            if i >= paths.count {
                finalComplexes.append(complexInProcess)
                return
            }
            var path = paths[i]
            while !path.isEmpty {
                let m = path.removeLast()
                complexInProcess.append(m)
                dfs(i: i+1)
                complexInProcess.removeLast()
            }
        }
        dfs(i: 0)
        print("🍃\(finalComplexes)")
        
        // 가장 작은 범위 조합부터 해당되는 diseases 들 배치
        var result: [Disease] = []
        var diseaseAndFinalComplex: [(Disease, [Meaning])] = []
        guard let mostBroadComplex = finalComplexes.last else {return []}
        var wholeDiseases = diseasesSatisfyingAllMeanings(meanings: mostBroadComplex)
        for finalComplex in finalComplexes {
            for d in diseasesSatisfyingAllMeanings(meanings: finalComplex).sorted(by: { $0.id < $1.id }) { //귀찮아. 순서가 유지만 되면 되니까 걍 id 순 나열.
                if wholeDiseases.contains(d) {
                    result.append(d)
                    diseaseAndFinalComplex.append((d, finalComplex))
                    wholeDiseases.removeAll { $0.id == d.id }
                }
            }
        }
        
        // finalComplex의 path화
        var causeCards: [causeCard] = []
        for (disease, meaningComplex) in diseaseAndFinalComplex {
            let diseasePaths = meaningCompexToMeaningPath(meaningComplex: meaningComplex, paths: paths)
            causeCards.append(causeCard(disease: disease, paths: diseasePaths))
        }
        
        //print("🍃\(result)")
        return causeCards
    }
    
    func diseasesSatisfyingAllMeanings(meanings: [Meaning]) -> [Disease] {
        guard !meanings.isEmpty else { return [] }

        // Convert each Meaning to a Set of Disease IDs
        let diseaseSets: [Set<Disease>] = meanings.map { Set(meaningToDisease[$0] ?? []) }

        // Find intersection of all sets (common diseases)
        let commonDiseases = diseaseSets.dropFirst().reduce(diseaseSets[0]) { $0.intersection($1) }

        // Return actual Disease objects
        return Array(commonDiseases)
    }
    
    func meaningCompexToMeaningPath(meaningComplex: [Meaning], paths: [[Meaning]]) -> [[Meaning]] {
        var result: [[Meaning]] = []
        
        let totalPathNumber = paths.count
        for i in 0...totalPathNumber-1{
            let path = paths[i]
            var pathProcessing:[Meaning] = []
            for m in path { // path 젤 앞에서부터 m 나올 때 끊기
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

struct meaningWithTailC: Hashable {
    let m: Meaning
    let tailC: [CCriteria]
}

struct causeCard: Identifiable {
    let disease: Disease
    let paths: [[Meaning]]
    
    var id: Int { disease.id }
}

// MARK: Interpretation section view
struct InterpretationRow: View {
    let arrow: String?
    let leafNode: meaningWithTailC
    let index: Int
    @Binding var selectedMeaningPathIndices: Set<Int>
    @Binding var expandedPathIndices: Set<Int>

    var body: some View {
        HStack(spacing: 8) {
//            Button(action: {
//                if expandedPathIndices.contains(index) {
//                    expandedPathIndices.remove(index)
//                } else {
//                    expandedPathIndices.insert(index)
//                }
//            }) {
//                Image(systemName: expandedPathIndices.contains(index) ? "chevron.down" : "chevron.right")
//                    .foregroundColor(.gray)
//                    .padding(.trailing, 4)
//                    .frame(width: 20)
//            }
            
            Button(action: {
                if selectedMeaningPathIndices.contains(index) {
                    selectedMeaningPathIndices.remove(index)
                } else {
                    selectedMeaningPathIndices.insert(index)
                }
            }) {
                HStack(spacing: 8) {
                    ArrowCircleView(electrolyte: leafNode.m.electrolyte, arrow: arrow ?? "?")
                    Text(leafNode.m.name)
                        .bold()
                        .foregroundColor(.black)
                    Spacer()
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 12)
                .frame(minHeight: 44)
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                //.padding()
//                .background(
//                    RoundedRectangle(cornerRadius: 12)
//                        .stroke(selectedMeaningPathIndices.contains(index) ? Color.blue : Color.gray)
//                )
            }
            .buttonStyle(PlainButtonStyle())

            //        .simultaneousGesture(TapGesture().onEnded {
            //            if expandedPathIndices.contains(index) {
            //                expandedPathIndices.remove(index)
            //            } else {
            //                expandedPathIndices.insert(index)
            //            }
            //        })
        }
    }
}

struct InterpretationDetail: View {
    let path: [meaningWithTailC]

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(Array(path.enumerated()), id: \.1.m.id) { index, node in
                let condition = CMDUtils.CCriteriaRouteToString(criteriaPath: node.tailC)

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 8) {
//                        ElectrolyteCircleView(electrolyte: node.m.electrolyte)
                        DotGroupView(count: index + 1, color: node.m.electrolyte.color)
                        Text(node.m.name).bold()
                    }
                    Text("• \(condition)")
                        .font(.caption2)
                        .foregroundColor(.customDarkGreen)
                }
            }
        }
    }
}



//MARK: Top causes view
struct TopCauseRow: View {
    let card: causeCard
    let index: Int
    //@Binding var expandedChildrenIndices: Set<Int>
    @Binding var expandedIndices: Set<Int>

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack{
                ForEach(card.paths, id: \.self) { path in
                    if let color = path.first?.electrolyte.color {
                        DotGroupView(count: path.count, color: color)
                    } else {
                        DotGroupView(count: path.count, color: .customGray)
                    }
                }
            }
            
            HStack{
                let rootNodes = card.paths.compactMap { $0.first }
                ForEach(rootNodes, id: \.id) { node in
                    ArrowCircleView(electrolyte: node.electrolyte, arrow: node.arrow ?? "?")
                }
                VStack(alignment: .leading) {
                    Text(card.disease.name)
                        .bold()
                    if !card.disease.relatedDID.isEmpty {
                        let relatedNames = card.disease.relatedDID.compactMap { diseaseDict[$0]?.name }
                        Text("Related: \(relatedNames.joined(separator: ", "))")
                            .font(.caption2)
                            .foregroundColor(.customGray)
                    }
                }
                Spacer()
                Button(action: {
                    withAnimation {
                        if expandedIndices.contains(index) {
                            expandedIndices.remove(index)
                        } else {
                            expandedIndices.insert(index)
                        }
                    }
                }) {
                    Image(systemName: expandedIndices.contains(index) ? "minus.circle" : "plus.circle")
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

//struct TopCauseDetail: View {
//    let card: causeCard
//    let diseaseRoute: [Disease: [[String]]]
//    let meaningDict: [Int: Meaning]
//    let diseaseDict: [Int: Disease]
//
//    var body: some View {
//        let routes = diseaseRoute[card.disease] ?? []
//        VStack(alignment: .leading, spacing: 2) {
//            ForEach(routes, id: \.self) { route in
//                let pathSet = Set(card.paths.flatMap { $0 }.map { "M\($0.id)" })
//                let routeText = route.compactMap { idString -> Text? in
//                    if idString.starts(with: "M"), let id = Int(idString.dropFirst()), let meaning = meaningDict[id] {
//                        let text = Text(meaning.name)
//                        return pathSet.contains("M\(id)") ? text.bold() : text
//                    } else if idString.starts(with: "D"), let id = Int(idString.dropFirst()), let disease = diseaseDict[id] {
//                        return Text(disease.name)
//                    } else {
//                        return nil
//                    }
//                }
//                routeText.reduce(Text(""), { $0 + Text(" > ") + $1 })
//                    .font(.caption2)
//                    .foregroundColor(.gray)
//            }
//        }
//    }
//}

struct TopCauseDetailWithDots: View {
    let card: causeCard
    let diseaseRoute: [Disease: [[String]]]
    let meaningDict: [Int: Meaning]
    let diseaseDict: [Int: Disease]

    var body: some View {
        let routes = diseaseRoute[card.disease] ?? []
        // Flatten path IDs
        let pathIDsList = card.paths.map { path in path.map { "M\($0.id)" } }

        // Compute matched and unmatched routes OUTSIDE the view
        let matchedRoutesList = routes.filter { route in
            pathIDsList.contains { pathIDs in
                pathIDs.allSatisfy { route.contains($0) }
            }
        }

        let unmatchedRoutes = routes.filter { !matchedRoutesList.contains($0) }
        VStack(alignment: .leading, spacing: 2) {
            ForEach(card.paths, id:\.self) { path in
                let pathIDs = path.map{ "M\($0.id)" }
                let matchedRoutes = routes.filter{ route in
                    pathIDs.allSatisfy{route.contains($0)}
                }

                ForEach(matchedRoutes, id:\.self) { route in
//                    VStack{
                        let routeText = route.compactMap { idString -> Text? in
                            if idString.starts(with: "M"), let id = Int(idString.dropFirst()), let meaning = meaningDict[id] {
                                let text = Text(meaning.name)
                                return pathIDs.contains("M\(id)") ? text.bold() : text
                            } else if idString.starts(with: "D"), let id = Int(idString.dropFirst()), let disease = diseaseDict[id] {
                                return Text(disease.name)
                            } else {
                                return nil
                            }
                        }
                    
                        if let color = path.first?.electrolyte.color {
                            DotGroupView(count: 1, color: color.opacity(0.7))
                            //DotGroupView(count: path.count, color: color.opacity(0.7))
                        } else {
                            DotGroupView(count: 1, color: .customGray.opacity(0.7))
                            //DotGroupView(count: path.count, color: .customGray.opacity(0.7))
                        }
                        routeText.reduce(Text(""), { $0 + Text(" > ") + $1 })
                            .font(.caption2)
                            .foregroundColor(.customDarkGreen)
//                    }
                }
            }
            ForEach(unmatchedRoutes, id: \.self) { route in
                if !matchedRoutesList.contains(route) {
                    let routeText = route.compactMap { idString -> Text? in
                        if idString.starts(with: "M"), let id = Int(idString.dropFirst()), let meaning = meaningDict[id] {
                            return Text(meaning.name)
                        } else if idString.starts(with: "D"), let id = Int(idString.dropFirst()), let disease = diseaseDict[id] {
                            return Text(disease.name)
                        } else {
                            return nil
                        }
                    }
                    if let root = route.first, root.starts(with: "M"), let id = Int(root.dropFirst()), let meaning = meaningDict[id] {
                        let color = meaning.electrolyte.color
                        DotGroupView(count: 1, color: color.opacity(0.3))
                    }
                    
                    routeText.reduce(Text(""), { $0 + Text(" > ") + $1 })
                        .font(.caption2)
                        .foregroundColor(.customGray)
                }
            }
            if !card.disease.causeDID.isEmpty {
                let causeNames = card.disease.causeDID.compactMap { diseaseDict[$0]?.name }
                Divider()
                Text("Possible Causes: \n \(causeNames.joined(separator: ", "))")
                    .font(.caption2)
                    .foregroundColor(.customDarkGreen)
                    .multilineTextAlignment(.leading)
            }
            if let description = card.disease.description {
                if description != ""{
                    Divider()
                    Text("Description: \n \(description)")
                        .font(.caption2)
                        .foregroundColor(.customDarkGreen)
                        .multilineTextAlignment(.leading)
                }
            }
        }
    }
}

//MARK: Single path selected
struct causeNodeSinglePath: Identifiable {
    let id = UUID()
    let type: NodeType
    let path: [Meaning]
    let meaning: Meaning? // for Meaning
    let disease: Disease? // for Disease
    let children: [causeNodeSinglePath]
}

enum NodeType: String, CaseIterable, Identifiable, Codable, Hashable {
    case Meaning = "Meaning"
    case Disease = "Disease"
    
    var id: String {self.rawValue}
}

func meaningToCauseNode(
    meaning: Meaning,
    path: [Meaning]
) -> causeNodeSinglePath {
    var childrenList: [causeNodeSinglePath] = []
    
    let childrenCandidates = meaning.diseaseID.compactMap({diseaseDict[$0]}).sorted(by: {$0.id < $1.id}) // 순서가 항상 일정하도록 id 순 나열
    for d in childrenCandidates.filter( { d in
        !childrenCandidates.contains(where: { $0.causeDID.contains(d.id) })
    }) {
        childrenList.append(diseaseToCauseNode(disease: d, childrenCandidates: childrenCandidates, path: path))
    }
    
    let sortedTailMeanings = meaning.tailMID.compactMap({meaningDict[$0]})
        .sorted { $0.order < $1.order}
    for m in sortedTailMeanings {
        childrenList.append(meaningToCauseNode(meaning: m, path: path))
    }
    
    return causeNodeSinglePath(type: .Meaning, path: path, meaning: meaning, disease: nil, children: childrenList)
}

func diseaseToCauseNode(
    disease: Disease,
    childrenCandidates: [Disease],
    path: [Meaning]
) -> causeNodeSinglePath {
    var childrenList: [causeNodeSinglePath] = []
    
    for d in disease.causeDID.compactMap({diseaseDict[$0]}).sorted(by: {$0.id < $1.id}) { // 순서가 항상 일정하도록 id 순 나열
        if childrenCandidates.contains(d){ // 상위 M 에 해당하는 D만 추가
            childrenList.append(causeNodeSinglePath(type: .Disease, path: path, meaning: nil, disease: d, children: d.causeDID.compactMap{diseaseDict[$0]}.compactMap{diseaseToCauseNode(disease: $0, childrenCandidates: childrenCandidates, path: path)}))
        }
    }
    
    return causeNodeSinglePath(type: .Disease, path: path, meaning: nil, disease: disease, children: childrenList)
}

struct singlePathTreeView: View {
    let node: causeNodeSinglePath
    let depth: Int
    let diseaseRoute: [Disease: [[String]]]
    
    @State private var isExpanded: Bool = false
    @State private var isExpandedDetail: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack{
                Button(action: {
                    if !node.children.isEmpty {
                        withAnimation(.easeInOut) {
                            isExpanded.toggle()
                        }
                    }
                }) {
                    Image(systemName: node.children.isEmpty ? "" : (isExpanded ? "chevron.down" : "chevron.right"))
                        .foregroundColor(.gray)
                        .frame(width: 12)
                }
                .disabled(node.children.isEmpty) // no interaction for leaf nodes
                
                VStack(alignment: .leading, spacing: 4) {
                    if let color = node.path.first?.electrolyte.color {
                        DotGroupView(count: node.path.count, color: color)
                    } else {
                        DotGroupView(count: node.path.count, color: .gray)
                    }
                    HStack{
                        if node.type == .Disease {
                            if let rootNode = node.path.first {
                                ArrowCircleView(electrolyte: rootNode.electrolyte, arrow: rootNode.arrow ?? "?")
                            }
                        }
                        if let title = node.type == .Meaning ? node.meaning?.name : node.disease?.name {
                            Text(title)
                        }
                        Spacer()
                    if node.type == .Disease{
                            Button(action: {
                                isExpandedDetail.toggle()
                            }) {
                                Image(systemName: isExpandedDetail ? "minus.circle" : "plus.circle")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    if isExpandedDetail{
                        if node.type == .Disease{
                            if let disease = node.disease {
                                let card = causeCard(disease: disease, paths: [node.path])
                                TopCauseDetailWithDots(card: card, diseaseRoute: diseaseRoute, meaningDict: meaningDict, diseaseDict: diseaseDict)
                            }
                        }
                    }
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.black.opacity(0.05))
                    )

                
            }
            .padding(.leading, CGFloat(depth) * 12)
            
            if isExpanded{
//                if node.type=="Disease"{
//                    if let disease = node.disease {
//                        let card = causeCard(disease: disease, paths: [node.path])
//                        TopCauseDetailWithDots(card: card, diseaseRoute: diseaseRoute, meaningDict: meaningDict, diseaseDict: diseaseDict)
//                    }
//                }
                ForEach(node.children) { child in
                    singlePathTreeView(node: child, depth: depth + 1, diseaseRoute: diseaseRoute)
                }
            }
        }
    }
}
