//
//  EstoqueView.swift
//  Repar.ai
//
//  Created by Paulo Lazarini on 13/09/25.
//

import SwiftUI
import Combine

struct EstoqueView: View {
    
    @ObservedObject var viewModel: EstoqueViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    List {
                        ForEach(viewModel.pecasFiltradas) { peca in
                            PecaEstoqueRowView(peca: peca) {
                                viewModel.navigate(to: .editarPeca(peca))
                            }
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color(.systemGroupedBackground))
                        }
                        .onDelete(perform: viewModel.deletePeca)
                    }
                    .listStyle(.plain)
                    .background(Color(.systemGroupedBackground))
                }
            }
            .searchable(text: $viewModel.textoBusca, prompt: "Buscar peças")
            .navigationTitle("Estoque")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.navigate(to: .novaPeca)
                    } label: {
                        Image(systemName: "plus.circle")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundStyle(.gray)
                            .bold()
                    }
                }
            }
            .task {
                await viewModel.fetchPecas()
            }
        }
    }
}

struct PecaEstoqueRowView: View {
    let peca: PecaEstoque
    let onEdit: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(peca.nomePeca)
                        .font(.headline).bold()
                    Text("Fabricante: \(peca.fabricante ?? "N/A")")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(peca.precoVenda.formatted(.currency(code: "BRL")))
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Disponível")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(peca.quantidadeDisponivel)")
                        .font(.title.bold())
                        .foregroundColor(peca.quantidadeDisponivel < 10 ? .red : .primary)
                }
            }
            
            HStack {
                Spacer()
                Button {
                    onEdit()
                } label: {
                    Label("Editar", systemImage: "pencil")
                }
                .buttonStyle(.bordered)
                .tint(.gray)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

#Preview("Lista de Estoque") {
    EstoqueView(
        viewModel: EstoqueViewModel(
            networkManager: MockNetworkManager(),
            navigationEvents: PassthroughSubject<NavigationEvents,
            Never>()
        )
    )
}
