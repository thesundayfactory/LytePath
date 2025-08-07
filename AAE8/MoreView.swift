//
//  MoreView.swift
//  AAE8
//
//  Created by 이지선 on 7/31/25.
//

import SwiftUI

let cCriteriaDict = CCriteriaStore.shared.all
let rootCriteriaList = CCriteriaStore.shared.rootCriterias
let cCRelationList = CCriteriaStore.shared.cCRelation
let cMRelationList = CCriteriaStore.shared.cMRelation

let meaningDict = MeaningStore.shared.all
let rootMeaningList = MeaningStore.shared.rootMeanings
let mMRelationList = MeaningStore.shared.mMRelation
let mDRelationList = MeaningStore.shared.mDRelation

let diseaseDict = DiseaseStore.shared.all

let headCIDDictByTailCID: [Int: [HeadTailRelation]] = Dictionary(grouping: cCRelationList, by: { $0.tailID })
let criteriaIDDictByMeaningID: [Int: [HeadTailRelation]] = Dictionary(grouping: cMRelationList, by: { $0.tailID })
//[
//  22: [HeadTailRelation(headID: 5, tailID: 22),
//       HeadTailRelation(headID: 12, tailID: 22)],
//  ...
//]



struct InterpretationMoreView: View {
    let matchedcCriteria: [CCriteria]
    //cStructures
    let matchedcCriteriaPaths: [[CCriteria]]
    //mStructures
    let mStructures: [[meaningWithTailC]]
    let diseaseRoute: [Disease: [[String]] ]
    @State private var caseMeanings: [Meaning] = []
    @State private var caseLeafMeanings: [Meaning] = []
    @State private var meaningPaths: [Meaning: [[CCriteria]]] = [:]
    
    @State private var showFullLogic = false
    
    @State private var navigateToLogic = false
    
    var body: some View {
        VStack{
//            HStack(spacing: 6){
//                Spacer()
//                Toggle("", isOn: $showFullLogic)
//                    .labelsHidden()
//                Text(showFullLogic ? "Hide Full Logic" : "View All Logic")
//                    .font(.caption)
//                    .foregroundColor(.blue)
//                    .padding(.horizontal, 10)
//                    .padding(.vertical, 4)
//            }
            HStack {
                Spacer()
                NavigationLink(destination: LogicView(), isActive: $navigateToLogic) {
                    Button(action: {
                        navigateToLogic = true
                    }) {
                        Image(systemName: "list.bullet.rectangle")
                            .foregroundColor(.customDarkGreen)
                        Text("Logic")
                            .font(.caption)
                            .bold()
                            .foregroundColor(.customDarkGreen)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.customGreen.opacity(0.2))
                    .cornerRadius(8)
                }
            }
            .padding(.trailing, 16)
            .padding(.top, 10)
            
            
            ScrollView{
                VStack(alignment: .leading) {
                    
                    
                    let rootNodes = makeRootNodes()
                    ForEach(rootNodes) {rootNode in
                        InterpretationTreeView(node: rootNode, depth: 0, caseMeanings: caseMeanings, diseaseRoute: diseaseRoute, showFullLogic: showFullLogic )
                    }
                }
                .padding()
            }
        }
        .onAppear{
            caseMeanings = Array(
                Set(
                    matchedcCriteria.flatMap({$0.meaningID}).compactMap({meaningDict[$0]})
                    )
                )
            caseLeafMeanings = CMDUtils.cCriteriaLeafMeaning(criterias: matchedcCriteria, meaningDict: meaningDict).flatMap({CMDUtils.meaningToTailEndMeaning(meaning: $0, meaningDict: meaningDict)})
            //print("🍃caseLeafMeaning: \(caseLeafMeanings)")
            meaningPaths = CMDUtils.criteriaPathToMeaning(criteriaPaths: matchedcCriteriaPaths, meaningDict: meaningDict)
            //print("🍃MeaningPaths: \(meaningPaths)")
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func makeRootNodes() -> [InterpretationNode]{
        return rootMeaningList
            .sorted {
                guard let i0 = Electrolyte.displayOrder.firstIndex(of: $0.electrolyte),
                      let i1 = Electrolyte.displayOrder.firstIndex(of: $1.electrolyte) else {
                    return false
                }
                if i0 != i1 {
                    return i0 < i1
                } else {
                    return $0.order < $1.order
                }
            }
            .compactMap({meaningToInterpretationNode(meaning: $0, path: [$0], caseM: caseMeanings, caseLeafM: caseLeafMeanings, casePath: meaningPaths)})
    }
    
}

struct InterpretationNode: Identifiable {
    let id = UUID()
    let type: NodeType
    let path: [Meaning]
    let meaning: Meaning? // for Meaning
    let disease: Disease? // for Disease
    //let title: String
    let children: [InterpretationNode]
    let isCase: Bool
    var criteriaPath: String?
    //var otherCriteriaPath: String = ""
    //var description: String?
}

func meaningToInterpretationNode(
    meaning: Meaning,
    path: [Meaning],
    caseM: [Meaning], caseLeafM: [Meaning],
    casePath: [Meaning: [[CCriteria]]]
) -> InterpretationNode {
    //let title = meaning.name
    let isCase = caseM.contains(meaning) || caseLeafM.contains(meaning)

    // 1. CasePath (Lab logic)
    var criteriaPaths:[String] = []
    if let paths = casePath[meaning] {
        for path in paths {
            let pathStr = CMDUtils.CCriteriaRouteToString(criteriaPath: path)
            criteriaPaths.append(pathStr)
        }
    }
    let criteriaPathsStr = criteriaPaths
        .map { "• " + $0 }
        .joined(separator: "\n")
    
    
//    // 2. OtherPath (Lab logic)
//    var criteriaOtherPaths:[[CCriteria]] = []
//    if let rootCIDs = criteriaIDDictByMeaningID[meaning.id]?.compactMap({$0.headID}){
//        for rootCID in rootCIDs {
//            let otherPaths = CMDUtils.criteriaAscendingPath(criteriaID: rootCID, headCIDDictByTailCID: headCIDDictByTailCID)
//                .map { path in
//                    path.compactMap { cCriteriaDict[$0] }
//                }
//            criteriaOtherPaths += otherPaths
//        }
//    }
//    // 정렬
//    let sortedOtherPaths = criteriaOtherPaths.sorted { path1, path2 in
//        for (c1, c2) in zip(path1, path2) {
//            if c1.order != c2.order {
//                return c1.order < c2.order
//            }
//        }
//        return path1.count < path2.count // 길이로 tie-break
//    }
//    
//    var criteriaOtherPathsStr: [String] = []
//    for otherPath in sortedOtherPaths {
//        let pathStr = CMDUtils.CCriteriaRouteToString(criteriaPath: otherPath)
////                    let pathStr = otherPath.compactMap { cCriteriaDict[$0] }.map { crit in
////                        let dir = crit.direction == .high ? "↑" : "↓"
////                        return "\(crit.para.displayName) \(String(format: "%.2f", crit.thres)) \(dir)"
////                    }.joined(separator: " & ")
//        if criteriaPaths.contains(pathStr) {continue}
//        criteriaOtherPathsStr.append(pathStr)
//                    //otherCriteriaPath += "\n" + "• " + pathStr
//    }
//
//    let otherCriteriaPathStr = criteriaOtherPathsStr
//        .map { "• " + $0 }
//        .joined(separator: "\n")
    
    
    // 2. childrenList 만들기
    var childrenList: [InterpretationNode] = []
    // 1) children 중 Disease 타입
    let isLeafMeaning = caseLeafM.contains(meaning)
    let childrenCandidates = meaning.diseaseID.compactMap({diseaseDict[$0]})
    for d in childrenCandidates.filter( { d in
        !childrenCandidates.contains(where: { $0.causeDID.contains(d.id) }) // 잘 뜯어보면 head가 candidates에 없는 애들만 추가하라는 뜻
    }).sorted(by: {$0.id < $1.id}) { // id 순 나열
        childrenList.append(diseaseToInterpretationNode(disease: d, path: path, childrenCandidates: childrenCandidates, isCase: isLeafMeaning))
    }
    
    // 2) children 중 Meaning 타입
    let sortedTailMeanings = meaning.tailMID.compactMap({meaningDict[$0]})
        .sorted {
            guard let i0 = Electrolyte.displayOrder.firstIndex(of: $0.electrolyte),
                  let i1 = Electrolyte.displayOrder.firstIndex(of: $1.electrolyte) else {
                return false
            }
            if i0 != i1 {
                return i0 < i1
            } else {
                return $0.order < $1.order
            }
        }
    for m in sortedTailMeanings { // 본인 path에는 본인까지 포함.
        childrenList.append(meaningToInterpretationNode(meaning: m,path: path + [m], caseM: caseM, caseLeafM: caseLeafM, casePath: casePath))
    }
    
    return InterpretationNode(type: .Meaning, path: path, meaning: meaning, disease: nil, children: childrenList, isCase: isCase, criteriaPath: criteriaPathsStr)
//    return InterpretationNode(title: title, children: childrenList, isCase: isCase, labCriteriaPath: labCriteriaPath)
}

func diseaseToInterpretationNode(disease: Disease, path: [Meaning], childrenCandidates: [Disease], isCase: Bool) -> InterpretationNode { // childrenCandidates는 M->D 래밸
    //let title = disease.name
    var childrenList: [InterpretationNode] = []
    for d in disease.causeDID.compactMap({diseaseDict[$0]}).sorted(by: {$0.id < $1.id}) { // 순서가 항상 일정하도록 id 순 나열
        if childrenCandidates.contains(d){ // 상위 M 에 해당하는 D만 추가
            childrenList.append(InterpretationNode(type: .Disease, path: path, meaning: nil, disease: d, children: d.causeDID.compactMap{diseaseDict[$0]}.compactMap{diseaseToInterpretationNode(disease: $0, path: path, childrenCandidates: childrenCandidates, isCase: isCase)}, isCase: isCase))
        }
    }
    return InterpretationNode(type: .Disease, path: path, meaning: nil, disease: disease, children: childrenList, isCase: isCase)
}

//let interpretationSample = InterpretationNode(
//    title: "Hyponatremia",
//    children: [
//        InterpretationNode(title: "True hyponatremia", children: [
//            InterpretationNode(title: "Extrarenal Na loss", children: []),
//            InterpretationNode(title: "Renal Na loss", children: [
//                InterpretationNode(title: "Diuretic excess", children: []),
//                InterpretationNode(title: "Mineralocorticoid deficiency", children: []),
//                InterpretationNode(title: "Salt-losing nephropathy", children: [
//                    InterpretationNode(title: "Reflux nephropathy", children: []),
//                    InterpretationNode(title: "Interstitial nephropathy", children: []),
//                    InterpretationNode(title: "Postobstructive nephropathy", children: [])
//                ]),
//                InterpretationNode(title: "Osmotic diuresis", children: [])
//            ])
//        ])
//    ]
//)

struct InterpretationTreeView: View {
    let node: InterpretationNode
    let depth: Int
    let caseMeanings: [Meaning]
    let diseaseRoute: [Disease: [[String]]]
    let showFullLogic: Bool
    
    @State private var isExpanded: Bool
    @State private var isExpandedDetail: Bool = false
    
    //Acidosis, Alkalosis만 한 단계 펼쳐져서 MAci, RAci, MAlk, Ralk 까지 보이는 게 디폴트 (MAci+Malk 같은 것 대비)
    init(node: InterpretationNode, depth: Int, caseMeanings incomingCaseMeanings: [Meaning], diseaseRoute: [Disease: [[String]]], showFullLogic: Bool) {
        self.node = node
        self.depth = depth
        self.caseMeanings = incomingCaseMeanings
        self.showFullLogic = showFullLogic
        self.diseaseRoute = diseaseRoute
        _isExpanded = State(initialValue: node.meaning?.name == "Acidosis" || node.meaning?.name == "Alkalosis")
//        _isExpanded = State(initialValue: depth < 1) // auto-collapse depth ≥2
    }

    var body: some View {
        // Chevron toggle and label
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
                    let pathSet = Set(node.path)
                    let caseMeaningSet = Set(caseMeanings)
                    let intersectionCount = caseMeaningSet.intersection(pathSet).count
                    if let rootNode = node.path.first {
                        if intersectionCount != 0 {
                            DotGroupView(count: intersectionCount, color: rootNode.electrolyte.color)
                        }
                    }
                    HStack{
                        if depth == 0{
                            if let rootNode = node.path.first{
                                ArrowCircleView(electrolyte: rootNode.electrolyte, arrow: rootNode.arrow ?? "?")
                            }
                        }
                        Text((node.type == .Meaning ? node.meaning?.name : node.disease?.name) ?? "")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.customVeryDarkBlueGreen)
                            //.foregroundColor(node.isCase ? .customVeryDarkBlueGreen : .customGray)
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
                    if let disease = node.disease {
                        if !disease.relatedDID.isEmpty{
                            let relatedDiseasesName = disease.relatedDID.compactMap({diseaseDict[$0]?.name})
                            Text("Mechanism overlap: \(relatedDiseasesName.joined(separator:", "))")
                                .font(.caption2)
                                .foregroundColor(.customGray)
                        }
                    }
                    if let p = node.criteriaPath {
                        Text(p)
                            .font(.caption2)
                            .foregroundColor(.customDarkGreen)
                            .multilineTextAlignment(.leading)
                    }
                    
//                    if showFullLogic {
//                        Text(node.otherCriteriaPath)
//                            .font(.caption2)
//                            .foregroundColor(.customGray)
//                            .multilineTextAlignment(.leading)
//                    }
                    
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
        }
        .padding(.leading, CGFloat(depth) * 12)
            
            if isExpanded{
                ForEach(node.children) { child in
                    InterpretationTreeView(node: child, depth: depth + 1, caseMeanings: caseMeanings, diseaseRoute: diseaseRoute, showFullLogic: showFullLogic)
                }
            }
        
    }
}
