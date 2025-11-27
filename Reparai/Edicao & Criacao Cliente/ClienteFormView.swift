//
//  ClienteFormView.swift
//  Repar.ai
//
//  Created by Paulo Lazarini on 13/09/25.
//

import SwiftUI

struct ClienteFormView: View {
    
    @ObservedObject var viewModel: ClienteFormViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Informações Pessoais") {
                    TextField("Nome Completo", text: $viewModel.nomeCompleto)
                    TextField("Telefone", text: $viewModel.telefone)
                        .keyboardType(.phonePad)
                }
                
                Section("Informações Adicionais (Opcional)") {
                    TextField("E-mail", text: $viewModel.email)
                        .keyboardType(.emailAddress)
                    TextField("CPF", text: $viewModel.cpf)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle(viewModel.navigationTitle)
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
                            if await viewModel.save() {
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
