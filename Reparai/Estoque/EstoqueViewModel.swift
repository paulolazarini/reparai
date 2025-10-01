//
//  EstoqueViewModel.swift
//  Repar.ai
//
//  Created by Paulo Lazarini on 13/09/25.
//

import SwiftUI
import Combine
import NetworkCore

@MainActor
class EstoqueViewModel: ObservableObject {
    
    @Published private var todasAsPecas: [PecaEstoque] = []
    @Published var pecasFiltradas: [PecaEstoque] = []
    @Published var isLoading = false
    @Published var textoBusca: String = "" {
        didSet {
            filtrarPecas()
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
    
    func fetchPecas() async {
        isLoading = true
        let resultado = await networkManager.fetchPecasEstoque()
        isLoading = false
        
        switch resultado {
        case .success(let pecas):
            self.todasAsPecas = pecas
            self.pecasFiltradas = pecas
        case .failure(let error):
            print("❌ Erro ao buscar Peças de Estoque: \(error.localizedDescription)")
        }
    }
    
    func deletePeca(at offsets: IndexSet) {
        let pecasParaDeletar = offsets.map { pecasFiltradas[$0] }
        
        Task {
            for peca in pecasParaDeletar {
                let resultado = await networkManager.deletePeca(id: peca.id)
                if case .success = resultado {
                    todasAsPecas.removeAll { $0.id == peca.id }
                    filtrarPecas()
                }
            }
        }
    }
    
    private func filtrarPecas() {
        if textoBusca.isEmpty {
            pecasFiltradas = todasAsPecas
        } else {
            pecasFiltradas = todasAsPecas.filter { peca in
                peca.nomePeca.localizedCaseInsensitiveContains(textoBusca) ||
                (peca.fabricante ?? "").localizedCaseInsensitiveContains(textoBusca)
            }
        }
    }
}
