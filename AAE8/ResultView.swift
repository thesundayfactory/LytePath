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
    var diseaseRoute: [Disease: [[String]]] {
        CMDUtils.buildDiseaseRoute(meaningDict: meaningDict, diseaseDict: diseaseDict)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView{
                VStack(spacing: 20) {
                    
                    let (matchedcCriteria, matchedcCriteriaPaths) =
                        ResultLogic.buildCStructures(
                            data: data,
                            rootCriteriaList: rootCriteriaList,
                            cCriteriaDict: cCriteriaDict
                        )
                    
                    let mStructures =
                        ResultLogic.buildMStructures(
                            matchedcCriteriaPaths: matchedcCriteriaPaths,
                            meaningDict: meaningDict
                        )
                    
                    selectedElectrolytesHeader(
                        matchedcCriteria: matchedcCriteria,
                        matchedcCriteriaPaths: matchedcCriteriaPaths,
                        mStructures: mStructures
                    )
                    
                    interpretationSection(
                        mStructures: mStructures,
                        selectedMeaningPathIndices: $selectedMeaningPathIndices,
                        expandedPathIndices: $expandedPathIndices
                    )
                    topCausesSection(mStructures: mStructures, expandedDiseases: $expandedDiseases)
                }
                .padding()
            }
            .navigationTitle("Analysis Result")
        }
    }
    
    // MARK: - Sections
    // 1. Electrolyte
    private func selectedElectrolytesHeader(
        matchedcCriteria: [CCriteria],
        matchedcCriteriaPaths: [[CCriteria]],
        mStructures: [[meaningWithTailC]]
    ) -> some View { // 전해질 순서 첫 화면이랑 맞추기
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
                    .background(Color.customLightGreen.opacity(0.3))
                    .foregroundColor(.customGreen)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.customGreen, lineWidth: 1) // ✅ 테두리 추가
                    )
                    .cornerRadius(5)
            }
        }
        .padding(.leading, 4)
    }
    
    // 2. Interpretation
    @State private var expandedPathIndices: Set<Int> = []
    @State private var selectedMeaningPathIndices: Set<Int> = []
    private func interpretationSection(
        mStructures: [[meaningWithTailC]],
        selectedMeaningPathIndices: Binding<Set<Int>>,
        expandedPathIndices: Binding<Set<Int>>
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("Interpretation")

            ForEach(Array(mStructures.enumerated()), id: \.offset) { index, path in
                HStack(alignment: .center) {
                    Button(action: {
                        if expandedPathIndices.wrappedValue.contains(index) {
                            expandedPathIndices.wrappedValue.remove(index)
                        } else {
                            expandedPathIndices.wrappedValue.insert(index)
                        }
                    }) {
                        Image(systemName: expandedPathIndices.wrappedValue.contains(index) ? "chevron.down" : "chevron.right")
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

                        }
                        
                        if expandedPathIndices.wrappedValue.contains(index) {
                            InterpretationDetail(path: path)
                                .padding(.horizontal, 12)
                                .padding(.bottom, 8)
                        }
                    }
                    .background(
                        ZStack {
                            if selectedMeaningPathIndices.wrappedValue.contains(index) {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.customWhite.opacity(0.2)) // ✅ 내부 색상 추가
                            }
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selectedMeaningPathIndices.wrappedValue.contains(index) ? Color.customGreen : Color.customGray, lineWidth: 1)
                        }
                    )
                }
            }
        }
    }
    
    // 4. Top causes
    @State private var expandedDiseases: Set<Int> = []
    private func topCausesSection(
        mStructures: [[meaningWithTailC]],
        expandedDiseases: Binding<Set<Int>>
    ) -> some View {
        
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("Possible Causes")
            let selectedPaths: [[Meaning]] = selectedMeaningPathIndices.map { index in
                mStructures[index].map({$0.m})
            }
            if selectedPaths.count >= 2 {
                let inferredDiseases = ResultLogic.multiPathSelection(paths: selectedPaths, meaningToDisease: meaningToDisease).filter{$0.disease.typical == true}
                if inferredDiseases.isEmpty {
                    Text("No disease matched all selected meanings.")
                        .font(.caption)
                        .foregroundColor(.gray)
                } else {
                    ForEach(Array(inferredDiseases.enumerated()), id: \.offset) { index, card in
                        VStack(alignment: .leading, spacing: 4) {
                            TopCauseRow(card: card, index: index, expandedIndices: $expandedDiseases)
                            if expandedDiseases.wrappedValue.contains(index) {
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
                Text("💡 Tap 'More' to see other possible causes")
                    .foregroundColor(.customGray)
            }
        }
        
    }
    
    // MARK: - Header Views
    private func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title).font(.title3).bold()
            Spacer()
        }
    }
    
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
            }
            .buttonStyle(PlainButtonStyle())
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
                        Text("Mechanism overlap: \(relatedNames.joined(separator: ", "))")
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
                        VStack(alignment: .leading){
                            if let title = node.type == .Meaning ? node.meaning?.name : node.disease?.name {
                                Text(title)
                            }
                            if let disease = node.disease {
                                if !disease.relatedDID.isEmpty {
                                    let relatedNames = disease.relatedDID.compactMap({diseaseDict[$0]?.name})
                                    Text("Mechanism overlap: \(relatedNames.joined(separator: ", "))")
                                        .font(.caption2)
                                        .foregroundColor(.customGray)
                                }
                            }
                            
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
                ForEach(node.children) { child in
                    singlePathTreeView(node: child, depth: depth + 1, diseaseRoute: diseaseRoute)
                }
            }
        }
    }
}
