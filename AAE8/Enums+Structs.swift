//
//  Enums+Structs.swift
//  AAE8
//
//  Created by 이지선 on 7/31/25.
//

import SwiftUI

enum Electrolyte: String, CaseIterable, Identifiable, Codable {
    case Na, K, pH //, Ca, P

    var id: String { self.rawValue }
    
    static let displayOrder: [Electrolyte] = [.Na, .K, .pH]

    var color: Color {
        switch self {
        case .Na: return .customYellow
        case .K: return .customRed
        case .pH: return .customOrange
//        case .Ca: return .blue
//        case .P: return .purple
        default: return .gray
        }
    }
}

enum VolumeStatusOption: String, CaseIterable, Identifiable {
    case hypervolemia = "Hypervolemia"
    case euvolemia = "Euvolemia"
    case hypovolemia = "Hypovolemia"

    var id: String { self.rawValue }

    var numericValue: Int {
        switch self {
        case .hypervolemia: return 1
        case .euvolemia: return 0
        case .hypovolemia: return -1
        }
    }
}

enum AcuteChronicOption: String, CaseIterable, Identifiable {
    case acute = "Acute"
    case chronic = "Chronic"

    var id: String { self.rawValue }
    
    var numericValue: Int {
        switch self {
        case .acute: return 1
        case .chronic: return 0
        }
    }
}

enum LabItem: String, CaseIterable, Hashable, Identifiable, Codable {
    case volume = "VolumeStatus"
    case pNa = "PNa"
    case uNa = "UNa"
    case pK = "PK"
    case uK = "UK"
    case pCl = "PCl"
    case uCl = "UCl"
    case pOsm = "POsm"
    case uOsm = "UOsm"
    case pPH = "PPH"
    case uPH = "UPH"
    case pCO2 = "PCO2"
    case pHCO3 = "PHCO3"
    case glucose = "Glucose"
    case bun = "BUN"
    case urineOutput = "UrineOutput"
    case TTKG = "TTKG"
    case urineOsmoleExcretionRate = "UER"
    case acuteChronic = "AcuteChronic"
    case predPCO2 = "Pred.PCO2"
    case diffPCO2 = "Diff.PCO2"
    case predHCO3 = "Pred.PHCO3"
    case diffHCO3 = "Diff.PHCO3"
    case pAG = "PAG"
    case pOG = "POG"
    case pDeltaRatio = "PDeltaRatio"
    case uAG = "UAG"

    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .volume: return "Volume"
        case .pNa: return "Na"
        case .uNa: return "Na"
        case .pK: return "K"
        case .uK: return "K"
        case .pCl: return "Cl"
        case .uCl: return "Cl"
        case .pOsm: return "Osm"
        case .uOsm: return "Osm"
        case .pPH: return "pH"
        case .uPH: return "pH"
        case .pCO2: return "PCO2"
        case .pHCO3: return "HCO3"
        case .glucose: return "BST"
        case .bun: return "BUN"
        case .urineOutput: return "U.O."
        case .TTKG: return "TTKG"
        case .urineOsmoleExcretionRate: return "UER"
        case .acuteChronic: return "Onset type"
        case .predPCO2: return "ePCO2"
        case .diffPCO2: return "▵PCO2"
        case .predHCO3: return "eHCO3"
        case .diffHCO3: return "▵HCO3"
        case .pAG: return "AG"
        case .pOG: return "OG"
        case .pDeltaRatio: return "▵Ratio"
        case .uAG: return "AG"
        }
    }
    
    var fullName: String {
        switch self {
        case .volume: return "Volume status"
        case .pNa: return "Serum Sodium"
        case .uNa: return "Urine Sodium"
        case .pK: return "Serum Potassium"
        case .uK: return "Urine Potassium"
        case .pCl: return "Serum Chloride"
        case .uCl: return "Urine Chloride"
        case .pOsm: return "Serum Osmolality"
        case .uOsm: return "Urine Osmolality"
        case .pPH: return "Serum pH"
        case .uPH: return "Urine pH"
        case .pCO2: return "Arterial partial pressure of CO2"
        case .pHCO3: return "Serum Bicarbonate"
        case .glucose: return "Serum Glucose"
        case .bun: return "Blood Urea Nitrogen"
        case .urineOutput: return "Urine output"
        case .TTKG: return "Transtubular Potassium Gradient"
        case .urineOsmoleExcretionRate: return "Urine osmole excretion rate"
        case .acuteChronic: return "Onset"
        case .predPCO2: return "Expected PaCO2"
        case .diffPCO2: return "PaCO2 Gap"
        case .predHCO3: return "Expected Serum Bicarbonate"
        case .diffHCO3: return "Bicarbonate Gap"
        case .pAG: return "Serum Anion gap"
        case .pOG: return "Serum Osmolar gap"
        case .pDeltaRatio: return "Delta ratio"
        case .uAG: return "Urine Anion gap"
        }
    }
    
    var type: String {
        switch self {
        case .volume, .pNa, .pK, .pCl, .pOsm, .pPH, .pCO2, .pHCO3, .glucose, .bun, .predPCO2, .diffPCO2, .predHCO3, .diffHCO3, .pAG, .pOG, .pDeltaRatio: return "Plasma"
        case .uNa, .uK, .uCl, .uOsm, .uPH, .urineOutput, .urineOsmoleExcretionRate, .uAG: return "Urine"
        case .TTKG, .acuteChronic: return "-"
        }
    }
    
    var unit: String {
        switch self {
        case .pNa, .uNa, .pK, .uK, .pCl, .uCl, .pHCO3, .predHCO3, .diffHCO3, .pAG, .uAG: return "mEq/L"
        case .pOsm, .uOsm, .pOG: return "mOsm/kg"
        case .glucose, .bun: return "mg/dL"
        case .pCO2, .predPCO2, .diffPCO2: return "mmHg"
        case .urineOutput: return "mL/day"
        case .urineOsmoleExcretionRate: return "mOsm/day"
        case .volume, .pPH, .uPH, .TTKG, .pDeltaRatio, .acuteChronic: return ""
            }
    }
    
    var normalRange: String? {
            switch self {
            case .urineOutput: return """
                500-2000
                (0.5-1.5 ml/kg/hr)
                """
            case .pNa: return "135–145"
            case .uNa: return "20-40"
            case .pK: return "3.5–5.5"
            case .uK: return "25–125"
            case .pCl: return "96-106"
            case .uCl: return "25–250"
            case .pOsm: return "275–295"
            case .uOsm: return "300-900"
            case .TTKG: return """
                if hypokalemia → <2
                if hyperkalemia → >8
                """
            case .urineOsmoleExcretionRate: return "500–1200"
            case .pHCO3: return "22–26"
            case .pCO2: return "35–45"
            case .diffHCO3: return """
                if Acute → -2-2
                if Chronic → -4-4
                """
            case .diffPCO2: return "-5-5"
            case .pAG : return "<12"
            case .pDeltaRatio: return "<2"
            case .bun: return "10-20"
            case .glucose: return "70–110"
            case .pPH: return "7.35-7.45"
            case .uPH: return "4.5-8.0"
            case .pOG: return "<10"
            case .uAG: return "if metabolic acidosis → <0"
            default: return nil
            }
    }
    
    var centerPlaceholder: String? {
        switch self {
        case .urineOutput: return "1500"
        case .pNa: return "140"
        case .uNa: return "30"
        case .pK: return "4.0"
        case .uK: return "30"
        case .pCl: return "100"
        case .uCl: return "15"
        case .pOsm: return "285"
        case .uOsm: return "700"
        case .pHCO3: return "24"
        case .pCO2: return "40"
        case .bun: return "10"
        case .glucose: return "100"
        case .pPH: return "7.4"
        case .uPH: return "6.0"
        default: return nil
        }
//            return normalRange?.components(separatedBy: "–").map { $0.trimmingCharacters(in: .whitespaces) }.middle() ?? ""
    }
    
    var isCalculatedOnly: Bool {
        switch self {
        case .predHCO3, .diffHCO3, .pAG, .pOG, .uAG, .TTKG, .predPCO2, .diffPCO2, .urineOsmoleExcretionRate, .pDeltaRatio: return true
        case .pNa, .uNa, .pK, .uK, .pCl, .uCl, .pHCO3, .pOsm, .uOsm, .glucose, .bun, .pCO2, .urineOutput, .volume, .pPH, .uPH, .acuteChronic: return false
        }
    }
    
    var formula: String? {
        switch self {
        case .urineOsmoleExcretionRate: return "Uosm x UrineOutput/1000"
        case .TTKG: return "(UK/PK) / (Uosm/Posm)"
        case .pAG: return "PNa - PCl - PHCO3"
        case .pOG: return "Posm - (2xPNa + Glocose/18 + BUN/2.8)"
        case .pDeltaRatio: return "(PAG-12)/(24-PHCO3)"
        case .uAG: return "UNa + UK - UCl"
        case .predPCO2:
            return """
            • HCO3<24 
            → 40-1.25(24-HCO3)
            • HCO3>24 
            → 40+0.75(HCO3-24)
            """
        case .diffPCO2: return "PaCO2 - expexted PaCO2"
        case .predHCO3:
            return """
                • Acute & PaCO2 >40 
                → 24 + 0.1(PaCO2-40)
                • Chronic & PaCO2 > 40 
                → 24 + 0.4(PaCO2-40)
                • Acute & PaCO2 < 40 
                → 24 - 0.2(40-PaCO2)
                • Chronic & PaCO2 < 40 
                → 24 - 0.4(40-PaCO2))
                """
        case .diffHCO3: return "serum HCO3 - expexted serum HCO3"
        default: return nil
        }
    }
    
    var explanation: String? {
        switch self {
        case .volume: return "ECF volume"
        case .acuteChronic: return "Respiratory disorder"
        default: return nil
        }
    }
}

extension Array where Element == String {
    func middle() -> String {
        guard self.count == 2 else { return "" }
        if let low = Double(self[0]), let high = Double(self[1]) {
            return String(format: "%.1f", (low + high) / 2)
        }
        return ""
    }
}

extension LabItem {
    var validRange: ClosedRange<Double>? { // 미완성
        switch self {
        case .urineOutput: return 50...10000
        case .pNa: return 70...200
        case .uNa: return 0...200
        case .pK: return 1.5...10
        case .uK: return 0...200
        case .pCl: return 70...130
        case .uCl: return 0...300
        case .pOsm: return 200...400
        case .uOsm: return 50...1500
        case .pPH: return 6.5...7.8
        case .pHCO3: return 5...45
        case .pCO2: return 10...100
        case .bun: return 1...100
        case .glucose: return 10...1000
        default: return nil
        }
    }

    func isInvalid(_ value: Double) -> Bool {
        guard let range = validRange else { return false }
        return !range.contains(value)
    }
}

struct LabData: Codable {
    var selectedElectrolytes: Set<Electrolyte>
    var labValues: [LabItem: Double]
}

struct HeadTailRelation {
    let headID: Int
    let tailID: Int
}

struct CCriteria: Identifiable, Codable, Hashable {
    let id: Int
    let electrolyte: Electrolyte
    let para: LabItem
    let thres: Double
    let direction: Direction
    let tailCID: [Int]
    let meaningID: [Int]
    let order: Int
    let point: Double
}

enum Direction: String, CaseIterable, Identifiable, Codable, Hashable {
    case high = "High"
    case low = "Low"
//    case variable = "Variable"
    
    var id: String { self.rawValue }
}

struct Meaning: Identifiable, Codable, Hashable {
    let id: Int
    let electrolyte: Electrolyte
    let category: MCategory
    let name: String
    let tailMID: [Int]
    let diseaseID: [Int]
    let order: Double
    let arrow: String?
}

enum MCategory: String, CaseIterable, Identifiable, Codable, Hashable {
    case cCriteria = "CCriteria"
    case mechanism = "Mechanism"
    case divider = "Divider"
    
    var id: String {self.rawValue}
}

struct Disease: Identifiable, Codable, Hashable {
    let id: Int
    let type: DType
    let typical: Bool
    let name: String
    let resultDID: [Int]
    let causeDID: [Int]
    let relatedDID: [Int]
    let description: String?
    
}

enum DType: String, CaseIterable, Identifiable, Codable, Hashable {
    case diagnosis = "Diagnosis"
    case finding = "Finding"
    
    var id: String {self.rawValue}
}
