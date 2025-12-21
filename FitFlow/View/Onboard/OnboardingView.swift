//
//  OnboardingView.swift
//  FitFlow
//
//  Created by Engin Bolat on 16.12.2025.
//

import SwiftUI


struct OnboardingView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @Binding var username: String
    @State private var tempName: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "figure.walk")
                .resizable()
                .frame(width: 80, height: 90)
                .foregroundColor(.primaryBrand)
            
            Text("FitFlow'a Hoş Geldin")
                .font(.largeTitle)
                .bold()
            
            Text("Programını kişiselleştirmek için adını girelim.")
                .foregroundColor(.gray)
            
            TextField("Adın nedir?", text: $tempName)
                .textFieldStyle(.roundedBorder)
                .padding()
            
            Button(action: {
                withAnimation {
                    coordinator.replace(page: .Dasboard)
                }
            }) {
                Text("Giriş Yap")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(tempName.isEmpty ? .gray : Color.primaryBrand)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .disabled(tempName.isEmpty)
        }
        .padding()
    }
}

#Preview {
    OnboardingView(username: .constant("Engin"))
}
