//
//  ClientesViewModel.swift
//  Repar.ai
//
//  Created by Paulo Lazarini on 13/09/25.
//

import SwiftUI
import Combine
import NetworkCore

@MainActor
class ClientesViewModel: ObservableObject {
    
    @Published private var todosOsClientes: [Cliente] = []
    @Published var clientesFiltrados: [Cliente] = []    
    @Published var isLoading = false
    @Published var textoBusca: String = "" {
        didSet {
            filtrarClientes()
        }
    }
    
    private let networkManager: NetworkManagerProtocol
    private let navigationEvents: PassthroughSubject<NavigationEvents, Never>
    
    init(
        networkManager: NetworkManagerProtocol,
        navigationEvents: PassthroughSubject<NavigationEvents, Never>
    ) {
        self.networkManager = networkManager
        self.navigationEvents = navigationEvents
    }
    
    func navigate(to destination: NavigationEvents) {
        navigationEvents.send(destination)
    }
    
    func fetchClientes() async {
        isLoading = true
        let resultado = await networkManager.fetchAllClientes()
        isLoading = false
        
        switch resultado {
        case .success(let clientes):
            self.todosOsClientes = clientes.sorted { $0.nomeCompleto < $1.nomeCompleto }
            self.clientesFiltrados = self.todosOsClientes
        case .failure(let error):
            print("❌ Erro ao buscar Clientes: \(error.localizedDescription)")
        }
    }
    
    func deleteCliente(at offsets: IndexSet) {
        let clientesParaDeletar = offsets.map { clientesFiltrados[$0] }
        
        Task {
            for cliente in clientesParaDeletar {
                let resultado = await networkManager.deleteCliente(id: cliente.id)
                if case .success = resultado {
                    todosOsClientes.removeAll { $0.id == cliente.id }
                    filtrarClientes()
                }
            }
        }
    }
    
    private func filtrarClientes() {
        if textoBusca.isEmpty {
            clientesFiltrados = todosOsClientes
        } else {
            clientesFiltrados = todosOsClientes.filter { cliente in
                cliente.nomeCompleto.localizedCaseInsensitiveContains(textoBusca) ||
                cliente.telefone.localizedCaseInsensitiveContains(textoBusca)
            }
        }
    }
}
