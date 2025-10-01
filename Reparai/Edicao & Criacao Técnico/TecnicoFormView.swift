//
//  TecnicoFormView.swift
//  Repar.ai
//
//  Created by Paulo Lazarini on 14/09/25.
//

import SwiftUI
import NetworkCore

struct TecnicoFormView: View {
    
    @ObservedObject var viewModel: TecnicoFormViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Informações Pessoais") {
                    TextField("Nome Completo", text: $viewModel.nomeCompleto)
                    TextField("Especialidade (Opcional)", text: $viewModel.especialidade)
                }
                
                Section("Detalhes Contratuais") {
                    DatePicker("Data de Admissão", selection: $viewModel.dataAdmissao, displayedComponents: .date)
                    Toggle("Funcionário Ativo", isOn: $viewModel.ativo)
                }
            }
            .navigationTitle(viewModel.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
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
