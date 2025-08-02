//
//  DataImport.swift
//  AAE8
//
//  Created by 이지선 on 7/31/25.
//

import SwiftUI


func loadCCriteria(fromCSV fileName: String) -> [CCriteria] {
    guard let path = Bundle.main.path(forResource: fileName, ofType: "csv") else {
        print("❌ LabCriteria File not found.")
        return []
    }

    do {
        let data = try String(contentsOfFile: path, encoding: .utf8)
        let rows = data.components(separatedBy: .newlines).filter { !$0.isEmpty }
        guard rows.count > 1 else { return [] }

        let body = rows.dropFirst()
        var result: [CCriteria] = []

        for row in body {
            let columns = row.components(separatedBy: ",")
            guard columns.count >= 6 else { continue } // Ensure all fields exist

            guard
                let id = Int(columns[0]),
                let electrolyte = Electrolyte(rawValue: columns[1]),
                let para = LabItem(rawValue: columns[2]),
                let thres = Double(columns[3]),
                let direction = Direction(rawValue: columns[4]),
                let order = Int(columns[7])
            else {
                print("❌ Failed to parse row: \(row)")
                continue
            }
            
            let tailCID = columns[5].split(separator: ";").compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
            let meaningID = columns[6].split(separator: ";").compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
            let point = Double(columns[8]) ?? 0

            let c = CCriteria(
                id: id,
                electrolyte: electrolyte,
                para: para,
                thres: thres,
                direction: direction,
                tailCID: tailCID,
                meaningID: meaningID,
                order: order,
                point: point
            )
            result.append(c)
        }
        print("✅ \(result.count) CCriteria loaded.")
        return result

    } catch {
        print("❌ Failed to read LabCriteria file: \(error)")
        return []
    }
}

func loadMeaning(fromCSV fileName: String) -> [Meaning] {
    guard let path = Bundle.main.path(forResource: fileName, ofType: "csv") else {
        print("❌ Meaning File not found.")
        return []
    }

    do {
        let data = try String(contentsOfFile: path, encoding: .utf8)
        let rows = data.components(separatedBy: .newlines).filter { !$0.isEmpty }
        guard rows.count > 1 else { return [] }

        let body = rows.dropFirst()
        var result: [Meaning] = []

        for row in body {
            let columns = row.components(separatedBy: ",")
            guard columns.count >= 6 else { continue } // Ensure all fields exist

            guard
                let id = Int(columns[0]),
                let electrolyte = Electrolyte(rawValue: columns[1]),
                let category = MCategory(rawValue: columns[2]),
                let order = Double(columns[6])
            else {
                print("❌ Failed to parse row: \(row)")
                continue
            }
            let name = columns[3]

            let tailMID = columns[4].split(separator: ";").compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
            let diseaseID = columns[5].split(separator: ";").compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
            
            let arrow = columns.count > 7 ? columns[7] : nil

            let m = Meaning(
                id: id,
                electrolyte: electrolyte,
                category: category,
                name: name,
                tailMID: tailMID,
                diseaseID: diseaseID,
                order: order,
                arrow: arrow
            )
            result.append(m)
        }
        print("✅ \(result.count) Meaning loaded.")
        return result

    } catch {
        print("❌ Failed to read Meaning file: \(error)")
        return []
    }
}

func loadDisease(fromCSV fileName: String) -> [Disease] {
    guard let path = Bundle.main.path(forResource: fileName, ofType: "csv") else {
        print("❌ Disease File not found.")
        return []
    }

    do {
        let data = try String(contentsOfFile: path, encoding: .utf8)
        let rows = data.components(separatedBy: .newlines).filter { !$0.isEmpty }
        guard rows.count > 1 else { return [] }

        let body = rows.dropFirst()
        var result: [Disease] = []

        for row in body {
            let columns = row.components(separatedBy: ",")
            guard columns.count >= 6 else { continue } // Ensure all fields exist

            guard
                let id = Int(columns[0]),
                let type = DType(rawValue: columns[1])
            else {
                print("❌ Failed to parse row: \(row)")
                continue
            }
            let typical = Bool(columns[2]=="Yes")
            let name = columns[3]

            let resultDID = columns[4].split(separator: ";").compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
            let causeDID = columns[5].split(separator: ";").compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
            let relatedDID = columns[6].split(separator: ";").compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
            let description = columns[7]

            let d = Disease(
                id: id,
                type: type,
                typical: typical,
                name: name,
                resultDID: resultDID,
                causeDID: causeDID,
                relatedDID: relatedDID,
                description: description
            )
            result.append(d)
        }
        print("✅ \(result.count) Disease loaded.")
        return result

    } catch {
        print("❌ Failed to read Disease file: \(error)")
        return []
    }
}


class CCriteriaStore {
    static let shared = CCriteriaStore()
    
    private(set) var all: [Int: CCriteria] = [:]

    private init() {
        loadFile()
    }

    func loadFile() {
        // CSV 파일 이름 (확장자는 .csv 생략)
        let cCriteriaList = loadCCriteria(fromCSV: "LabCriteria_ver 4_new11_edited")
        for cCriteria in cCriteriaList {
            all[cCriteria.id] = cCriteria
        }
    }

    func get(by id: Int) -> CCriteria? {
        return all[id]
    }

    var allList: [CCriteria] {
        return Array(all.values)
    }
    
    var cCRelation: [HeadTailRelation] {
        var relation: [HeadTailRelation] = []
        for cCriteria in allList {
            let headCID = cCriteria.id
            for tailCID in cCriteria.tailCID {
                relation.append(HeadTailRelation(headID: headCID, tailID: tailCID))
            }
        }
        return relation
    }
    
    var rootCriterias: [CCriteria] {
        let allCIDs = Set(all.keys)
        let allTailIDs = Set(cCRelation.map { $0.tailID })
        let rootCIDs = allCIDs.subtracting(allTailIDs)
        let rootCriterias = rootCIDs.compactMap{all[$0]}
        print("✅ \(rootCriterias.count) rootCriteria loaded.")
        //print(rootCriterias)
        return rootCriterias
    }
    
    var cMRelation: [HeadTailRelation] {
        var relation: [HeadTailRelation] = []
        for cCriteria in allList {
            let headCID = cCriteria.id
            for tailMID in cCriteria.meaningID {
                relation.append(HeadTailRelation(headID: headCID, tailID: tailMID))
            }
        }
        return relation
    }
}

class MeaningStore {
    static let shared = MeaningStore()
    
    private(set) var all: [Int: Meaning] = [:]

    private init() {
        loadFile()
    }

    func loadFile() {
        // CSV 파일 이름 (확장자는 .csv 생략)
        let meaningList = loadMeaning(fromCSV: "Meaning_ver 4_new11_edited")
        for meaning in meaningList {
            all[meaning.id] = meaning
        }
    }

    func get(by id: Int) -> Meaning? {
        return all[id]
    }

    var allList: [Meaning] {
        return Array(all.values)
    }
    
    var mMRelation: [HeadTailRelation] {
        var relation: [HeadTailRelation] = []
        for meaning in allList {
            let headMID = meaning.id
            for tailMID in meaning.tailMID {
                relation.append(HeadTailRelation(headID: headMID, tailID: tailMID))
            }
        }
        print(relation.count)
        return relation
    }
    
    var rootMeanings: [Meaning] {
        let allMIDs = Set(all.keys)
        let allTailMIDs = Set(mMRelation.map{$0.tailID})
        let rootMIDs = allMIDs.subtracting(allTailMIDs)
        let rootMeanings = rootMIDs.compactMap{all[$0]}
        return rootMeanings
    }
    
    var mDRelation: [HeadTailRelation] {
        var relation: [HeadTailRelation] = []
        for meaning in allList {
            let headMID = meaning.id
            for tailDID in meaning.diseaseID {
                relation.append(HeadTailRelation(headID: headMID, tailID: tailDID))
            }
        }
        return relation
    }
}

class DiseaseStore {
    static let shared = DiseaseStore()
    
    private(set) var all: [Int: Disease] = [:]

    private init() {
        loadFile()
    }

    func loadFile() {
        // CSV 파일 이름 (확장자는 .csv 생략)
        let diseaseList = loadDisease(fromCSV: "Disease_ver 4_new11_edited")
        for disease in diseaseList {
            all[disease.id] = disease
        }
    }

    func get(by id: Int) -> Disease? {
        return all[id]
    }

    var allList: [Disease] {
        return Array(all.values)
    }
    
    var dDRelation_cause_result: [HeadTailRelation] {
        var relation: [HeadTailRelation] = []
        for disease in allList {
            let resultDID = disease.id
            for causeDID in disease.causeDID {
                relation.append(HeadTailRelation(headID: resultDID, tailID: causeDID))
            }
        }
        //print(relation.count)
        return relation
    }
}
