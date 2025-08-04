//
//  LabLogics.swift
//  AAE8
//
//  Created by 이지선 on 8/1/25.
//

import SwiftUI

struct LogicNode : Identifiable {
    let id = UUID()
    let criterias: [CCriteria]
    let meaning: [Meaning]
    let children: [LogicNode]
}

struct LogicView: View {
    let meaningDict = MeaningStore.shared.all
    
    //@State private var criteriaPaths: [[CCriteria]] = []
    
    var body: some View {
        ScrollView{
            VStack(alignment: .leading) {
                let rootNodes = makeRoots()
                ForEach(rootNodes) { rootNode in
                    LogicTree(node: rootNode, depth: 0)
                }
            }
            .padding()
        }
        .navigationTitle("Logic Details")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func makeRoots() -> [LogicNode] {
        let sortedRootCriterias = rootCriteriaList
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
        
        var rootNodes: [LogicNode] = []
        for root in sortedRootCriterias {
            rootNodes += makeLogicNode(current: root, temp: [])
        }
        return rootNodes
    }
    
    func makeLogicNode(current: CCriteria, temp: [CCriteria]) -> [LogicNode] {
        var children: [LogicNode] = []
        let tailCriterias = current.tailCID.compactMap { cCriteriaDict[$0] }.sorted { $0.order < $1.order }
        
        if !current.meaningID.isEmpty { // meaningID가 있을 때
            let meanings = current.meaningID.compactMap({meaningDict[$0]})
            for next in tailCriterias {
                children += makeLogicNode(current: next, temp: [])
            }
            return [LogicNode(criterias: temp + [current], meaning: meanings, children: children)]
        } else { // meaningID가 없을 때
            var nodes: [LogicNode] = []
            for next in tailCriterias {
                nodes += makeLogicNode(current: next, temp: temp + [current])
            }
            return nodes
        }
    }
}

struct LogicTree: View {
    let node: LogicNode
    let depth: Int
    
    @State private var isExpanded: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4){
            HStack{
                //chevron
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
                
                //Content Box
                VStack(alignment: .leading, spacing: 4) {
                    let meaningStr = node.meaning.compactMap({$0.name}).joined(separator: " + ")
                    Text(meaningStr)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.customVeryDarkBlueGreen)
                    
                    let criteriaStr = CMDUtils.CCriteriaRouteToString(criteriaPath: node.criterias)
                    Text(criteriaStr)
                        .font(.caption2)
                        .foregroundColor(.customDarkGreen)
                        .multilineTextAlignment(.leading)
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
                LogicTree(node: child, depth: depth + 1)
            }
        }
    }
}
