//
//  NovaPecaView.swift
//  Repar.ai
//
//  Created by Paulo Lazarini on 13/09/25.
//

import SwiftUI

struct NovaPecaView: View {
    
    @ObservedObject var viewModel: NovaPecaViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Informações Principais") {
                    TextField("Nome da Peça", text: $viewModel.nomePeca)
                    TextField("Fabricante (Opcional)", text: $viewModel.fabricante)
                    TextField("Quantidade Inicial", text: $viewModel.quantidadeInicial)
                        .keyboardType(.numberPad)
                }
                
                Section("Valores") {
                    TextField("Preço de Custo (ex: 150.75)", text: $viewModel.precoCusto)
                        .keyboardType(.decimalPad)
                    TextField("Preço de Venda (ex: 299.90)", text: $viewModel.precoVenda)
                        .keyboardType(.decimalPad)
                }
                
                Section("Descrição (Opcional)") {
                    TextEditor(text: $viewModel.descricao)
                        .frame(height: 120)
                }
            }
            .navigationTitle("Nova Peça")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") {
                        Task {
                            if await viewModel.salvarPeca() {
                                dismiss()
                            }
                        }
                    }
                    .disabled(!viewModel.podeSalvar || viewModel.isSaving)
                }
            }
        }
    }
}

#Preview("Criação de Nova Peça") {
    NovaPecaView(
        viewModel: NovaPecaViewModel(networkManager: MockNetworkManager())
    )
}
