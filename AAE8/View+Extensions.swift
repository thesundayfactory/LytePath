//
//  View+Extensions.swift
//  AAE8
//
//  Created by 이지선 on 7/31/25.
//

import SwiftUI

extension View {
    // ✅ 키보드 숨김 함수
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
}

struct ElectrolyteCircleView: View {
    let electrolyte: Electrolyte

    var body: some View {
        Text(electrolyte.rawValue)
            .font(.caption2).bold()
            .foregroundColor(.customWhite)
            .frame(width: 24, height: 24)
            .background(
                Circle()
                    .fill(electrolyte.color)
                    //.opacity(0.2)
            )
    }
}

struct ArrowCircleView: View {
    let electrolyte: Electrolyte
    let arrow: String

    var body: some View {
        Text(arrow)
            .font(.caption2).bold()
            .foregroundColor(.customWhite)
            .frame(width: 24, height: 24)
            .background(
                Circle()
                    .fill(electrolyte.color)
                    //.opacity(0.2)
            )
    }
}

struct DotGroupView: View {
    let count: Int
    let color: Color

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<count, id: \.self) { _ in
                Circle()
                    .fill(color)
                    //.fill(color.opacity(0.3))
                    .frame(width: 8, height: 8)
            }
        }
    }
}

struct LabPickerCell<T: Hashable & CaseIterable & Identifiable & RawRepresentable>: View where T.RawValue == String {
    var type: String
    var label: String
    var selection: Binding<T>
    var isDisplay: Bool
//    var backgroundColor: Color = Color.gray.opacity(0.2)
    var fullName: String
    var explanation: String?
    
    @State private var showInfo = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(type)
                    .frame(width: 50)
                    .cornerRadius(10)
                    .font(.caption)
                    .foregroundColor(
                        {
                            var font: Color
                            switch type {
                            case "Plasma":
                                font = Color.customRed
                            case "Urine":
                                font = Color.customYellow
                            case "-":
                                font = Color.customWhite
                            default:
                                font = Color.gray
                            }
                            return font
                        }()
                    )
                    .background(
                        {
                            var base: Color
                            switch type {
                            case "Plasma":
                                base = Color.customRed.opacity(0.15)
                            case "Urine":
                                base = Color.customYellow.opacity(0.15)
                            case "-":
                                base = Color.customWhite.opacity(0.15)
                            default:
                                base = Color.gray.opacity(0.05)
                            }
                            return base
                        }()
                    )
                Spacer()
                Button(action: {
                    showInfo.toggle()
                }) {
                    Image(systemName: showInfo ? "chevron.up" : "chevron.down")
                        .foregroundColor(.customDarkGreen)
                }
            }
            HStack {
//                Text(label)
//                    .frame(width: 120)
//                Spacer()
                Picker(label, selection: selection) {
                    ForEach(Array(T.allCases)) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .tint(Color.customDarkGreen)
                .frame(width: 145)
                .cornerRadius(5)
                //.padding(.horizontal)
                .background(Color.customLightGreen.opacity(0.2))
                //Spacer()
            }
            if showInfo {
                LabInfoBoxPickerCell(fullName: fullName, explanation: explanation)
                    .padding(.top, 8)
            }
        }
        .padding()
        .background(Color.customWhite.opacity(0.2))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isDisplay ? Color.customGreen: Color.clear, lineWidth: 3)
        )
        //.padding(.horizontal)
    }
}

struct LabCell: View {
    var type: String
    var label: String
    var valueBinding: Binding<String>? = nil // for editable
    var placeholder: String? = nil
    var displayValue: String? = nil // for read-only
    var isDisplay: Bool
//    var backgroundColor: Color = Color.customLightGreen.opacity(0.2)
    var fullName: String
    var unit: String
    let normalRange: String?
    var formula: String? = nil //for read-only
//    var caption: String? = nil
//    var captionColor: Color = .gray
    var isEditable: Bool = true
//    var highlight: Bool = false
    var isInvalid: Bool = false
    
    @State private var showInfo = false
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(type)
                    .frame(width: 50)
                    .cornerRadius(30)
                    .font(.caption)
                    .bold()
                    .foregroundColor(
                        {
                            var font: Color
                            switch type {
                            case "Plasma":
                                font = Color.customRed
                            case "Urine":
                                font = Color.customYellow
                            case "-":
                                font = Color.customWhite
                            default:
                                font = Color.gray
                            }
                            return font
                        }()
                    )
                //.frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        {
                            var base: Color
                            switch type {
                            case "Plasma":
                                base = Color.customRed.opacity(0.15)
                            case "Urine":
                                base = Color.customYellow.opacity(0.15)
                            case "-":
                                base = Color.customWhite.opacity(0.15)
                            default:
                                base = Color.gray.opacity(0.05)
                            }
                            return base
                        }()
                    )
                if !isEditable {
                    Text("Auto")
                        .frame(width: 30)
                        .cornerRadius(30)
                        .font(.caption)
                        .background(Color.customGreen.opacity(0.3))
                        .foregroundColor(Color.customGreen)
                }
                Spacer()
//                if let caption = caption {
//                    Text(caption)
//                        .font(.caption)
//                        .foregroundColor(captionColor)
//                        //.frame(maxWidth: .infinity, alignment: .leading)
//                }
                Button(action: {
                    showInfo.toggle()
                }) {
                    Image(systemName: showInfo ? "chevron.up" : "chevron.down")
                        .foregroundColor(.customDarkGreen)
                }
            }
            HStack {
                Text(label)
                    .frame(width: 62)
                    .foregroundColor(.customDarkGreen)
                //Spacer()
                if isEditable, let binding = valueBinding {
                    ZStack(alignment: .leading) {
                        if let placeholder = placeholder, binding.wrappedValue.isEmpty {
                            Text(placeholder)
                                .foregroundColor(.customDarkGreen)
                                .opacity(0.5)
                                .frame(width: 64, height: 24)
                                .multilineTextAlignment(.center)
                                .padding(5) // ✅ Match TextField padding
                                .zIndex(1)  // ✅ Bring placeholder above background
                        }
                        TextField("", text: binding)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.center)
                            .frame(width: 64, height: 24)
                            .padding(5)
                            .bold()
                            .background(Color.customLightGreen.opacity(0.2))
                            .foregroundColor(.customDarkGreen)
                            .overlay( // ✅ 테두리 추가
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(isInvalid ? Color.customRed : Color.clear, lineWidth: 3)
                            )
                        //                        .overlay(
                        //                            RoundedRectangle(cornerRadius: 5)
                        //                                .stroke(highlight ? Color.fontDeepBlue : Color.clear, lineWidth: 5)
                        //                        )
                            .cornerRadius(5)
                            .zIndex(0)  // ⬅️ This ensures placeholder stays visible when empty
                    }
                } else if let display = displayValue {
                    Text(display)
                        .frame(width: 64, height: 24, alignment: .center)
                        .multilineTextAlignment(.center)
                        .padding(5)
                        .bold()
                        .background(Color.customLightGreen.opacity(0.2))
                        .foregroundColor(.customDarkGreen)
                        .cornerRadius(5)
                }
                //Text(unit)
                    //.font(.caption)
            }

//            if let caption = caption {
//                Text(caption)
//                    .font(.caption)
//                    .foregroundColor(captionColor)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//            }
            if isInvalid {
                Text("Value out of range")
                    .font(.caption)
                    .foregroundColor(.customRed)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            if showInfo {
                LabInfoBox(fullName: fullName, unit: unit, normalRange: normalRange, formula: formula)
                    .padding(.top, 8)
            }
            
        }
        .padding()
        .background(Color.customWhite.opacity(0.2))
        .cornerRadius(10)
        //.padding(.horizontal)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isDisplay ? Color.customGreen: Color.clear, lineWidth: 3)
        )
        .onTapGesture {
            if showInfo {
                showInfo = false
            }
        }
    }
}

struct LabInfoBox: View {
    let fullName: String
    let unit: String
    let normalRange: String?
    let formula: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(fullName)")
                .bold()
            if !unit.isEmpty {
                Text("Unit: \(unit)")
            }
            if let range = normalRange {
                Text("Normal: \(range)")
            }
            if let formula = formula {
                Text("Formula: \n\(formula)")
            }
        }
        .font(.caption2)
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.clear)
        .foregroundColor(.customDarkGreen)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.customGreen, lineWidth: 1)
            )
    }
}

struct LabInfoBoxPickerCell: View {
    let fullName: String
    let explanation: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(fullName)")
                .bold()
            if let explanation = explanation {
                Text("\(explanation)")
            }
        }
        .font(.caption2)
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.clear)
        .foregroundColor(.customDarkGreen)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.customGreen, lineWidth: 1)
        )
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let r, g, b, a: UInt64
        switch hex.count {
        case 6: // RGB (no alpha)
            (r, g, b, a) = (int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF, 255)
        case 8: // RGBA
            (r, g, b, a) = (int >> 24 & 0xFF, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b, a) = (255, 0, 0, 255) // fallback: red
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

extension Color {
    static let customRed = Color(hex: "9F3E19")
    static let customOrange = Color(hex: "DC6D15")
    static let customYellow = Color(hex: "E19741")
    static let customWhite = Color(hex: "FBE8D6")
    static let customGray = Color(hex: "828B88")
    static let customBlue = Color(hex: "2B7BAE")
    static let customDarkBlue = Color(hex: "334342")
    static let customLightGreen = Color(hex: "B9B864")
    static let customGreen = Color(hex: "7A7F2F")
    static let customDarkGreen = Color(hex: "414D26")
    static let customVeryDarkBlueGreen = Color(hex: "33503D")
}
