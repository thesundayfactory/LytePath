//
//  ContentView.swift
//  AAE8
//
//  Created by 이지선 on 7/31/25.
//

import SwiftUI

struct ContentView: View {
    @FocusState private var isInputActive: Bool
    @State private var selectedElectrolytes: Set<Electrolyte> = []
    
    @State private var labItemDisplayQueue: [LabItem] = []
    
    @State private var selectedVolumeStatus: VolumeStatusOption = .euvolemia
    @State private var selectedAcuteChronic: AcuteChronicOption = .acute
    
    @State private var labValues: [LabItem: Double] = [:]
    @State private var labData = LabData(selectedElectrolytes: [], labValues: [:])
    
    @State private var showResetAlert = false
    
    @State private var navigateToResult = false
    
    var containsInvalidValues: Bool {
        labValues.contains { (item, value) in
            item.isInvalid(value)
        }
    }

    init() {
        if let saved = LabData.load() {
            _selectedElectrolytes = State(initialValue: saved.selectedElectrolytes)
            _labValues = State(initialValue: saved.labValues)

            if let rawVolume = saved.labValues[.volume],
               let v = VolumeStatusOption.allCases.first(where: { $0.numericValue == Int(rawVolume) }) {
                _selectedVolumeStatus = State(initialValue: v)
            } else {
                _selectedVolumeStatus = State(initialValue: .euvolemia)
            }

            if let rawAcute = saved.labValues[.acuteChronic],
               let a = AcuteChronicOption.allCases.first(where: { $0.numericValue == Int(rawAcute) }) {
                _selectedAcuteChronic = State(initialValue: a)
            } else {
                _selectedAcuteChronic = State(initialValue: .acute)
            }
            
        } else {
            _selectedElectrolytes = State(initialValue: [])
            _labValues = State(initialValue: [:])
            _labItemDisplayQueue = State(initialValue: [])
            _selectedVolumeStatus = State(initialValue: .euvolemia)
            _selectedAcuteChronic = State(initialValue: .acute)
        }
    }
    

    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        hideKeyboard()
                    }
                VStack(spacing: 0) {
                    titleBar // 🧷 fixed top title + (?) button
                    topBar   // 🧷 fixed Reset + ElectrolyteSelector
                    //Divider()

                    ScrollView {
                        VStack(spacing: 16) {
                            electrolyteInputGrid
                        }
                        .padding()
                        .onTapGesture {
                            isInputActive = false
                        }
                    }
                    .simultaneousGesture(
                        TapGesture().onEnded {
                            hideKeyboard()
                        }
                    )

                    Spacer(minLength: 60) // space for Done button
                }

                VStack {
                    Spacer()
                    Button(action: {
                        hideKeyboard()
                        labValues[.volume] = Double(selectedVolumeStatus.numericValue)
                        labValues[.acuteChronic] = Double(selectedAcuteChronic.numericValue)
                        labData = LabData(
                            selectedElectrolytes: selectedElectrolytes,
                            labValues: labValues
                        )
                        labData.save() // ✅ Save current state
                        navigateToResult = true
                    }) {
                        Text("Done")
                            .font(.headline)
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(containsInvalidValues ? Color.customGreen.opacity(0.5) : Color.customGreen.opacity(0.9))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.horizontal)
                            .padding(.bottom, 10)
                    }
                    .disabled(containsInvalidValues)
                }
            }
            .onAppear {
                LabValueCalculator.compute(from: &labValues)
                DisplayLabItem.processingDisplay(from: labValues, ref: &selectedElectrolytes, to: &labItemDisplayQueue)
            }
            .navigationDestination(isPresented: $navigateToResult) {
                ResultViewNew(data: labData)
            }
        }
    }

    // MARK: 1. Title bar
    @State private var showHelp = false
    private var titleBar: some View {
        
        HStack {
            Image("LytePathLogo") // <- Add your image asset to Assets.xcassets
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                        
            Text("LytePath")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.customVeryDarkBlueGreen)
            Spacer()
            Button(action: {
                showHelp = true
            }) {
                Image(systemName: "questionmark.circle")
                    .resizable()
                    .frame(width: 25, height: 25)
                    .padding(8)
                    .contentShape(Rectangle())
                    .foregroundColor(.customDarkGreen)
            }
            .navigationDestination(isPresented: $showHelp) {
                HelpView()
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 20)         // ✅ 기존보다 여유 있게
        .padding(.bottom, 16)       // ✅ 아래 여백도 살짝
    }
    
    // MARK: 2. Top bar
    private var topBar: some View {
//        VStack(spacing: 6) {
            HStack {
                electrolyteSelector
                Spacer()
                Button("Reset") {
                    showResetAlert = true
                }
//                .font(.caption)
                .bold()
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.customGreen.opacity(0.9))
                .foregroundColor(.white)
                .cornerRadius(5)
                .alert("Reset all data?", isPresented: $showResetAlert) {
                    Button("Reset", role: .destructive) {
                        performReset() // 👉 아래에서 정의할 함수
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("All entered values and selections will be cleared.")
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
            
//        }
    }
    
    // Reset 함수
    func performReset() {
        selectedElectrolytes = []
        labValues = [:]
        selectedVolumeStatus = .euvolemia
        selectedAcuteChronic = .acute
        labItemDisplayQueue = []

        labValues[.volume] = Double(selectedVolumeStatus.numericValue)
        labValues[.acuteChronic] = Double(selectedAcuteChronic.numericValue)
        LabValueCalculator.compute(from: &labValues)
        
        LabData.clear()
    }
    
    // 전해질 선택 뷰
    private var electrolyteSelector: some View {
        HStack(spacing: 12) {
            ForEach(Electrolyte.allCases, id: \.self) { item in
                Button(action: {
                    toggleElectrolyte(item)
                }) {
                    Text(item.rawValue)
                        .foregroundColor(selectedElectrolytes.contains(item) ? .customWhite : .customDarkGreen)
                        .font(.caption).bold()
                        .frame(width: 35, height: 35)
                        .background(Circle()
                            .fill(item.color).opacity(selectedElectrolytes.contains(item) ? 1 : 0.3))
                }
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func toggleElectrolyte(_ item: Electrolyte) {
        if selectedElectrolytes.contains(item) {
            selectedElectrolytes.remove(item)
            switch item {
            case .Na:
                labItemDisplayQueue.removeAll { $0 == .pNa }
            case .K:
                labItemDisplayQueue.removeAll { $0 == .pK }
            case .pH:
                labItemDisplayQueue.removeAll { $0 == .pPH}
            }
            DisplayLabItem.processingDisplay(from: labValues,ref: &selectedElectrolytes, to: &labItemDisplayQueue)
        } else {
            selectedElectrolytes.insert(item)
            switch item {
            case .Na:
                labItemDisplayQueue.append(.pNa)
            case .K:
                labItemDisplayQueue.append(.pK)
            case .pH:
                labItemDisplayQueue.append(.pPH)
            }
            DisplayLabItem.processingDisplay(from: labValues, ref: &selectedElectrolytes, to: &labItemDisplayQueue)
        }
    }
    
    // MARK: 3. Lab input 뷰
    private var electrolyteInputGrid: some View {
        Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 16) {
            GridRow{
                makeLabCell(for: .volume)
                makeLabCell(for: .urineOutput)
            }
            GridRow{
                makeLabCell(for: .pNa)
                makeLabCell(for: .uNa)
            }
            GridRow{
                makeLabCell(for: .pK)
                makeLabCell(for: .uK)
            }
            GridRow{
                makeLabCell(for: .pCl)
                makeLabCell(for: .uCl)
            }
            GridRow{
                makeLabCell(for: .pOsm)
                makeLabCell(for: .uOsm)
            }
            GridRow{
                makeLabCell(for: .TTKG)
                makeLabCell(for: .urineOsmoleExcretionRate)
            }
            GridRow{
                makeLabCell(for: .pPH)
                makeLabCell(for: .acuteChronic)
            }
            GridRow {
                makeLabCell(for: .pHCO3)
                makeLabCell(for: .pCO2)
            }
            GridRow {
                makeLabCell(for: .predHCO3)
                makeLabCell(for: .predPCO2)
            }
            GridRow {
                makeLabCell(for: .diffHCO3)
                makeLabCell(for: .diffPCO2)
            }
            GridRow {
                makeLabCell(for: .pAG)
                makeLabCell(for: .pDeltaRatio)
            }
            GridRow {
                makeLabCell(for: .bun)
                makeLabCell(for: .glucose)
            }
            GridRow{
                makeLabCell(for: .pOG)
                makeLabCell(for: .uAG)
            }
        }
    }
    
    func makeLabCell(for item: LabItem) -> some View {
        let isDisplay = labItemDisplayQueue.contains(item)
        
        switch item {
        case .volume:
            return AnyView(
                LabPickerCell(type: item.type, label: item.displayName, selection: $selectedVolumeStatus, isDisplay: isDisplay, fullName: item.fullName, explanation: item.explanation)
                    .onChange(of: selectedVolumeStatus) {
                        labValues[.volume] = Double(selectedVolumeStatus.numericValue)
                        LabValueCalculator.compute(from: &labValues)
                    }
            )
        case .acuteChronic:
            return AnyView(
                LabPickerCell(type: item.type, label: item.displayName, selection: $selectedAcuteChronic, isDisplay: isDisplay, fullName: item.fullName, explanation: item.explanation)
                    .onChange(of: selectedAcuteChronic) {
                        labValues[.acuteChronic] = Double(selectedAcuteChronic.numericValue)
                        LabValueCalculator.compute(from: &labValues)
                    }
            )
        default:
            if item.isCalculatedOnly == false{
                return AnyView(
                    LabCell(
                        type: item.type,
                        label: item.displayName,
                        valueBinding: Binding(
                            get: {
                                // Double → String 변환
                                if let value = labValues[item] {
                                    return String(value)
                                } else {
                                    return ""
                                }
                            },
                            set: { newValue in
                                // String → Double 변환
                                let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                                if let parsed = Double(trimmed) {
                                    labValues[item] = parsed
                                    LabValueCalculator.compute(from: &labValues)
                                    DisplayLabItem.processingDisplay(from: labValues, ref: &selectedElectrolytes, to: &labItemDisplayQueue)
                                } else {
                                    labValues.removeValue(forKey: item)
                                    LabValueCalculator.compute(from: &labValues)
                                    DisplayLabItem.processingDisplay(from: labValues, ref: &selectedElectrolytes, to: &labItemDisplayQueue)
                                }
                            }
                        ),
                        placeholder: item.centerPlaceholder,
                        isDisplay: isDisplay,
                        fullName: item.fullName,
                        unit: item.unit,
                        //caption: item.normalRange.map { "(Normal: \($0))" } ?? " ",
                        normalRange: item.normalRange,
                        isEditable: !(item.isCalculatedOnly),
                        isInvalid: labValues[item].map { item.isInvalid($0) } ?? false
                    )
                    .focused($isInputActive)
                )
            } else {
                return AnyView(
                    LabCell(
                        type: item.type,
                        label: item.displayName,
                        placeholder: item.centerPlaceholder,
                        displayValue: labValues[item].map { String(format: "%.1f", $0) } ?? "",
                        isDisplay: isDisplay,
                        fullName: item.fullName,
                        unit: item.unit,
                        //caption: item.normalRange.map { "(Normal: \($0))" } ?? " ",
                        normalRange: item.normalRange,
                        formula: item.formula,
                        isEditable: !(item.isCalculatedOnly)
                    )
                    .focused($isInputActive)
                )
            }
        }
    }
    
}

#Preview {
    ContentView()
}
