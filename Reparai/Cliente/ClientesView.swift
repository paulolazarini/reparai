//
//  ClientesView.swift
//  Repar.ai
//
//  Created by Paulo Lazarini on 13/09/25.
//


import SwiftUI
import NetworkCore

struct ClientesView: View {
    
    @ObservedObject var viewModel: ClientesViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    List {
                        ForEach(viewModel.clientesFiltrados) { cliente in
                            ClienteRowView(cliente: cliente)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    viewModel.navigate(to: .editarCliente(cliente))
                                }
                        }
                        .onDelete(perform: viewModel.deleteCliente)
                    }
                    .listStyle(.plain)
                }
            }
            .searchable(text: $viewModel.textoBusca, prompt: "Buscar cliente por nome ou telefone")
            .navigationTitle("Clientes")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.navigate(to: .novoCliente)
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
                await viewModel.fetchClientes()
            }
        }
    }
}

struct ClienteRowView: View {
    let cliente: Cliente
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(cliente.nomeCompleto)
                    .font(.headline)
                Text(cliente.telefone)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                if let email = cliente.email {
                    Text(email)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray.opacity(0.5))
        }
        .padding(.vertical, 8)
    }
}
