//
//  PhysicalInfoView.swift
//  FitFlow
//
//  Created by Engin Bolat on 23.12.2025.
//

import SwiftUI

struct PhysicalInfoView: View {
    @Binding var height: Double?
    @Binding var weight: Double?
    @Binding var age: Int?
    var isButtonDisabled: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            if height == nil || weight == nil || age == nil {
                VStack(spacing: 8) {
                    Text(localizable: .fillIntheMissingInformation)
                        .font(.title2)
                        .bold()
                    Text(localizable: .fillIntheMissingInformation)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.bottom, 10)
            }
            if height == nil {
                PersonalInfoTextField(
                    placeholder: LocalizableEnum.height.localizedWith(suffix: "(cm)"),
                    value: $height,
                    keyboardType: .decimalPad
                ).disabled(isButtonDisabled)
            }
            PersonalInfoTextField(
                placeholder: LocalizableEnum.weight.localizedWith(suffix: "(kg)"),
                value: $weight,
                keyboardType: .decimalPad
            )
            if age == nil {
                PersonalInfoTextField(
                    placeholder: LocalizableEnum.age.key,
                    value: Binding( get: { age.map(Double.init) }, set: { age = $0.map(Int.init) }),
                    keyboardType: .numberPad,
              )
                .disabled(isButtonDisabled)
            }
        }
    }
}

private struct PersonalInfoTextField: View {
    var placeholder: LocalizedStringKey
    @Binding var value: Double?
    var keyboardType: UIKeyboardType
    
    var body: some View {
        TextField(placeholder, value: $value, format: .number)
            .textFieldStyle(.plain)
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)
            .keyboardType(keyboardType)
    }
}

#Preview {
    PhysicalInfoView(
        height: .constant(nil),
        weight: .constant(nil),
        age: .constant(nil),
        isButtonDisabled: false
    )
    .padding()
}
