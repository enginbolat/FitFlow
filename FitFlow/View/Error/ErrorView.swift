//
//  ErrorView.swift
//  FitFlow
//
//  Created by Engin Bolat on 16.12.2025.
//

import SwiftUI

struct ErrorView: View {
    let error: Error
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: "exclamationmark.triangle.fill").font(.system(size: 50)).foregroundColor(.red)
            Text("Bağlantı Hatası").font(.title2)
            Text(error.localizedDescription).multilineTextAlignment(.center).foregroundColor(.secondary).padding(.horizontal)
            Button("Tekrar Dene", action: retryAction).buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview() {
    ErrorView(error: "asd" as! Error, retryAction: {})
}
