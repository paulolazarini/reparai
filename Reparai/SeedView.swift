//
//  SeedView.swift
//  Repar.ai
//
//  Created by Paulo Lazarini on 23/11/25.
//

import SwiftUI

struct SeedView: View {
    @State private var isLoading = false
    @State private var message = "Toque para popular o banco"
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Ferramentas de Desenvolvimento")
                .font(.headline)
            
            if isLoading {
                ProgressView()
            }
            
            Button(action: {
                runSeed()
            }) {
                Text("Popular Banco de Dados (Seed)")
                    .bold()
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(isLoading)
            
            Text(message)
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding()
        }
    }
    
    func runSeed() {
        isLoading = true
        message = "Rodando seed..."
        
        Task {
            do {
                let seeder = FirebaseSeeder()
                try await seeder.seedDatabase()
                
                DispatchQueue.main.async {
                    message = "Sucesso! Dados criados.\nReinicie o app para ver os dados."
                    isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    message = "Erro: \(error.localizedDescription)"
                    isLoading = false
                }
            }
        }
    }
}

#Preview {
    SeedView()
}
