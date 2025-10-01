//
//  OrdensDeServicoViewModel.swift
//  Repar.ai
//
//  Created by Paulo Lazarini on 13/09/25.
//

import SwiftUI
import Combine
import NetworkCore

@MainActor
class OrdensDeServicoViewModel: ObservableObject {
    
    @Published private var todasAsOrdens: [OrdemDeServico] = []
    @Published var ordensFiltradas: [OrdemDeServico] = []
    @Published var isLoading = false
    @Published var textoBusca: String = "" {
        didSet {
            filtrarOrdens()
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
    
    func fetchCliente(using id: String) async -> Cliente? {
        let result = await networkManager.fetchCliente(byId: id)
        
        switch result {
        case let .success(cliente):
            return cliente
        case let .failure(error):
            print("❌ Erro ao buscar Cliente: \(error.localizedDescription)")
            return nil
        }
    }
    
    func fetchOrdensDeServico() async {
        isLoading = true
        let resultado = await networkManager.fetchOrdensDeServico()
        isLoading = false
        
        switch resultado {
        case .success(let ordens):
            self.todasAsOrdens = ordens
            self.ordensFiltradas = ordens
        case .failure(let error):
            print("❌ Erro ao buscar Ordens de Serviço: \(error.localizedDescription)")
        }
    }
    
    func deleteOrdemDeServico(at offsets: IndexSet) {
        let ordensParaDeletar = offsets.map { ordensFiltradas[$0] }
        
        Task {
            for os in ordensParaDeletar {
                let resultado = await networkManager.deleteOrdemDeServico(id: os.id)
                if case .success = resultado {
                    todasAsOrdens.removeAll { $0.id == os.id }
                    filtrarOrdens()
                }
            }
        }
    }
    
    private func filtrarOrdens() {
        if textoBusca.isEmpty {
            ordensFiltradas = todasAsOrdens
        } else {
            ordensFiltradas = todasAsOrdens.filter { os in
                os.marcaModelo.localizedCaseInsensitiveContains(textoBusca) ||
                "\(os.id)".contains(textoBusca)
            }
        }
    }
}
