//
//  NovaOrdemDeServicoView.swift
//  Repar.ai
//
//  Created by Paulo Lazarini on 13/09/25.
//

import SwiftUI
import Combine

enum TipoEquipamento: String, CaseIterable, Identifiable {
    case celular = "Celular"
    case notebook = "Notebook"
    case tablet = "Tablet"
    case desktop = "Desktop"
    case impressora = "Impressora"
    case outro = "Outro"
    
    var id: String { self.rawValue }
}

struct NovaOrdemDeServicoView: View {
    @ObservedObject var viewModel: NovaOrdemDeServicoViewModel
    @FocusState var isFocused
    @Environment(\.dismiss) var dismiss
    var onSave: () -> Void
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Form {
                    Section(
                        header: Text(
                            "Informações do Cliente"
                        )
                        .font(.title3).bold()
                    ) {
                        clienteSearchView
                        
                        TextField(
                            "(XX) XXXXX-XXXX",
                            text: .constant(
                                viewModel.clienteSelecionado?.telefone ?? ""
                            )
                        )
                        .disabled(true)
                        
                        TextField(
                            "cliente@email.com",
                            text: .constant(
                                viewModel.clienteSelecionado?.email ?? ""
                            )
                        )
                        .disabled(true)
                    }
                    
                    Section(
                        header: Text(
                            "Detalhes do Equipamento"
                        )
                        .font(.title3).bold()
                    ) {
                        Picker(
                            "Selecione o tipo",
                            selection: $viewModel.tipoEquipamento
                        ) {
                            ForEach(TipoEquipamento.allCases) { tipo in
                                Text(tipo.rawValue)
                                    .tag(tipo)
                            }
                        }
                        
                        TextField(
                            "Ex: Samsung Galaxy S21",
                            text: $viewModel.marcaModelo
                        )
                        
                        TextField(
                            "Digite o número de série",
                            text: $viewModel.numeroSerie
                        )
                    }
                    
                    Section(
                        header: Text(
                            "Problema Relatado"
                        )
                        .font(.title3)
                        .bold()
                    ) {
                        TextEditor(
                            text: $viewModel.problemaRelatado
                        )
                        .frame(height: 150)
                    }
                }
                .scrollDismissesKeyboard(.automatic)
                
                Button {
                    Task {
                        if await viewModel.salvarOrdemDeServico() {
                            onSave()
                        }
                    }
                } label: {
                    HStack {
                        if viewModel.isSaving {
                            ProgressView()
                                .tint(.white)
                        }
                        Text(
                            viewModel.isSaving 
                            ? "Salvando..."
                            : "Salvar Ordem de Serviço"
                        )
                    }
                    .font(.headline.bold())
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(viewModel.podeSalvar ? Color.blue : Color.gray)
                    .cornerRadius(15)
                    .shadow(radius: 5)
                }
                .disabled(!viewModel.podeSalvar || viewModel.isSaving)
                .padding()
            }
            .navigationTitle("Nova Ordem de Serviço")
            .toolbar { toolbar }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .foregroundStyle(.gray)
                    .padding(8)
            }
        }
    }
    
    var isShowingClienteList: Bool {
        !viewModel.resultadosBuscaCliente.isEmpty
        && viewModel.buscaClienteTexto != ""
        && isFocused
    }
    
    private var clienteSearchView: some View {
        VStack(spacing: 16) {
            HStack {
                TextField("Buscar cliente...", text: $viewModel.buscaClienteTexto)
                    .focused($isFocused)
                
                if viewModel.buscaClienteTexto != "" {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .onTapGesture {
                            viewModel.buscaClienteTexto = ""
                            viewModel.clienteSelecionado = nil
                        }
                }
            }

            if isShowingClienteList {
                List(viewModel.resultadosBuscaCliente) { cliente in
                    Button {
                        viewModel.selecionarCliente(cliente)
                        isFocused = false
                    } label: {
                        Text(cliente.nomeCompleto)
                    }
                }
                .listStyle(.plain)
                .frame(maxHeight: 150)
                .background(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3))
                )
                .transition(.opacity)
            }
        }
        .frame(height: isShowingClienteList ? 166 : 0)
        .animation(.bouncy, value: isShowingClienteList)
    }
}

#Preview {
    NovaOrdemDeServicoView(
        viewModel:
            NovaOrdemDeServicoViewModel(networkManager: MockNetworkManager())
    ) {
        print("OS Salva! O Coordinator deveria fechar esta tela agora.")
    }
}
