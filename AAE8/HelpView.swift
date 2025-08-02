//
//  HelpView.swift
//  AAE8
//
//  Created by 이지선 on 7/31/25.
//

import SwiftUI

struct HelpView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("App Overview")
                    .font(.title2)
                    .bold()

                Group {
                    Text("LytePath is an educational tool designed for medical students, residents, and healthcare professionals.")
                    Text("It helps users analyze electrolyte abnormalities using structured algorithms and suggests possible underlying diseases.")
                    Text("The logic is based on Harrison’s Internal Medicine and other clinical textbooks.")
                    Text("This app is intended for educational support and does not replace clinical judgment.")

                }

                Divider()
                
                Text("How to Use")
                    .font(.title2)
                    .bold()
                
                Group {
                    Text("1. Input Section")
                        .font(.headline)
                    Text("• Select Electrolytes")
                    Text("Tap the circles at the top (Na, K, pH) to choose which electrolyte(s) to analyze.")
                    Text("• Enter Lab Values")
                    Text("Based on your selections and existing inputs, relevant lab fields will automatically appear.")
                    Text("This is a general guide — you may leave some fields empty, and the app will analyze using available data.")
                    Text("Also, you can input values even in fields that aren't auto-suggested if you think they're clinically relevant.")
                    Text("• Info Button (▾)")
                    Text("Tap the down arrow next to any field to view its full name, unit, normal range, and formula if applicable.")
                    Text("• Auto-Calculated Fields")
                    Text("Some values (marked Auto) are computed automatically once needed values are provided. These fields cannot be edited.")
                    Text("• Invalid Values")
                    Text("If a value is physiologically implausible (e.g., pNa = 10), a red border will appear and the 'Done' button will be disabled.")
                    Text("• Submit (Done) / Reset")
                    Text("Once inputs are complete, tap Done to proceed. Your inputs will be saved automatically.")
                    Text("Tap Reset to clear all values and start a new case.")
                    
                    Text("2. Analysis Result Section")
                        .font(.headline)
                    Text("• Electrolyte Display")
                    Text("Only selected electrolytes are analyzed. Their colored circles appear at the top and guide color coding throughout.")
                    Text("• Interpretation")
                    Text("This section shows possible mechanisms explaining the abnormal value.")
                    Text("Tap the chevron (>) to expand and view the path (logic chain) that led to this mechanism.")
                    Text("    - Each dot represents a matched logic step.")
                    Text("    - A light gray explanation shows the condition(s) met at that level.")
                    Text("• Possible Causes")
                    Text("Tap an interpretation box to view matching diseases.")
                    Text("    - Single box selected → shows diseases that satisfy all steps of that path.")
                    Text("    - Multiple boxes selected → shows diseases satisfying at least one step in each selected path.")
                    Text("        ↳ Dot indicators above diseases show how many steps they match in each selected interpretation.")
                    Text("        ↳ Diseases matching more logic steps are prioritized higher.")
                    Text("    - Tap the (+) icon to view detailed explanation and related conditions.")
                    Text("        ↳ Gray Routes : These indicate alternate known pathways for each disease that weren’t matched in this case.")
                    Text("• More Button")
                    Text("Tap More to explore a complete tree view of logic paths and all potential mechanisms and causes.")
                    
                    Text("3. Analysis Details Section")
                        .font(.headline)
                    Text("• Displays a full tree of meanings and diseases.")
                    Text("• Matched paths (for your case) show small colored dots above them.")
                    Text("• Each matched step includes a brief explanation of which lab values were met.")
                    Text("• Tap Logic to view the full algorithm tree including unmatched logic branches.")
                    
                    Text("4. Logic Details Section")
                        .font(.headline)
                    Text("• View all possible logic paths built into the app’s algorithm, regardless of current input.")
                    Text("• All combinations of criteria are shown, linked to corresponding mechanisms.")
                    
                    
                }
                
                Divider()
                
                Text("Limitations & Disclaimer")
                    .font(.title2)
                    .bold()
                
                Group {
                    Text("This app is intended for educational and clinical support use only by healthcare professionals.")
                    Text("It is not a diagnostic device, and it does not replace clinical experience, reasoning, or judgment.")
                    Text("Use of this app should always be accompanied by appropriate clinical context.")
                }
                
                Divider()
                
                Text("Privacy")
                    .font(.title2)
                    .bold()
                
                Group {
                    Text("All data entered stays on your device.")
                    Text("No patient-identifying information is stored or transmitted.")
                    Text("The app does not collect, share, or analyze personal data of any kind.")
                }
                
                Divider()
                
                Text("App Info")
                    .font(.title2)
                    .bold()
                
                Group {
                    Text("Version: 1.0.0")
                    Text("GitHub: https://github.com/thesundayfactory/LytePath")
                    Text("Contact: thesundayfactory01@gmail.com")
                }
            }
            .padding()
        }
        .navigationTitle("Help")
        .navigationBarTitleDisplayMode(.inline)
    }
}
