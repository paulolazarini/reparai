//
//  OrdensDeServicoView.swift
//  Repar.ai
//
//  Created by Paulo Lazarini on 13/09/25.
//

import SwiftUI
import Combine
import NetworkCore

struct OrdensDeServicoView: View {
    @ObservedObject var viewModel: OrdensDeServicoViewModel
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                List {
                    ForEach(viewModel.ordensFiltradas) { os in
                        OrdemDeServicoRowView(
                            ordemDeServico: os,
                            fetchCliente: viewModel.fetchCliente
                        )
                        .onTapGesture {
                            viewModel.navigate(
                                to: .detalhesOrdemDeServico(os.id)
                            )
                        }
                    }
                    .onDelete(perform: viewModel.deleteOrdemDeServico)
                }
                .listStyle(.plain)
            }
            .searchable(
                text: $viewModel.textoBusca,
                prompt: "Buscar Ordem de Serviço"
            )
            .navigationTitle("Ordens de Serviço")
            .onAppear {
                Task {
                    await viewModel.fetchOrdensDeServico()
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.navigate(to: .novaOrdemDeServico)
                    } label: {
                        Image(systemName: "plus.circle")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundStyle(.gray)
                            .bold()
                    }
                }
            }
            .opacity(viewModel.isLoading ? 0 : 1)
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                }
            }
        }
    }
}

struct OrdemDeServicoRowView: View {
    @State private var cliente: Cliente?
    
    let ordemDeServico: OrdemDeServico
    
    @MainActor let fetchCliente: (String) async -> Cliente?

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("OS #\(ordemDeServico.id.prefix(8))")
                    .font(.headline).bold()
                
                if let cliente {
                    Text("Cliente: \(cliente.nomeCompleto)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } else {
                    ProgressView()
                }
                
                Text("Dispositivo: \(ordemDeServico.marcaModelo)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("Data de Entrada: \(ordemDeServico.dataEntrada.formatted(date: .numeric, time: .omitted))")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            StatusTagView(status: ordemDeServico.status)
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray.opacity(0.5))
        }
        .task {
            cliente = await fetchCliente(ordemDeServico.clienteId)
        }
        .padding(.horizontal)
    }
}

struct StatusTagView: View {
    let status: StatusOrdemDeServico
    
    var body: some View {
        Text(status.rawValue)
            .font(.caption.bold())
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .foregroundColor(status.cor)
            .background(status.cor.opacity(0.2))
            .clipShape(.rect(cornerRadius: 16))
    }
}

#Preview {
    NavigationStack {
        OrdensDeServicoView(
            viewModel: OrdensDeServicoViewModel(
                networkManager: MockNetworkManager(),
                navigationEvents: PassthroughSubject<NavigationEvents, Never>()
            )
        )
    }
}
