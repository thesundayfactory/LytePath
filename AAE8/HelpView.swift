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
                Text("How to Use LytePath")
                    .font(.title2)
                    .bold()

                Group {
                    Text("Step 1: Select Electrolytes")
                        .font(.headline)
                    Text("Tap the circles at the top (Na, K, pH) to select the electrolytes you want to analyze.")

                    Text("Step 2: Enter Lab Values")
                        .font(.headline)
                    Text("Fill in the lab values. You can tap each cell to view the full name, units, and normal range.")

                    Text("Step 3: Understand the Logic")
                        .font(.headline)
                    Text("The app automatically analyzes the input values using clinical logic trees and shows possible causes.")

                    Text("Step 4: Review the Result")
                        .font(.headline)
                    Text("You can tap **More** to view all reasoning and tap causes to see the full path and explanation.")
                }

                Divider()

                Group {
                    Text("Tips")
                        .font(.headline)
                    Text("""
                        This app is intended for educational or clinical support use by healthcare professionals only.
                        It is not intended for patient diagnosis, treatment, or self-assessment.
                        The app does not provide medical advice and should not replace clinical judgment.
                        """)
                }
                
                Divider()
                
                Group {
                    Text("Disclaimer")
                        .font(.headline)
                    Text("• Auto-calculated values are labeled as 'Auto' and cannot be edited.")
                    Text("• If a value is out of valid range, a red border will appear.")
                    Text("• Tap a cell's ▼ to view explanation or formula.")
                    Text("• You can reset all data by tapping the **Reset** button.")
                }

                Spacer()
            }
            .padding()
            .foregroundColor(.customVeryDarkBlueGreen)
        }
        .navigationTitle("Help")
        .navigationBarTitleDisplayMode(.inline)
    }
}
