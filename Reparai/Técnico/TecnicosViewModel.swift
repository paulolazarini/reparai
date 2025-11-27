//
//  TecnicosViewModel.swift
//  Repar.ai
//
//  Created by Paulo Lazarini on 14/09/25.
//

import SwiftUI
import Combine

@MainActor
final class TecnicosViewModel: ObservableObject {
    
    @Published private var todosOsTecnicos: [Tecnico] = []
    @Published var tecnicosFiltrados: [Tecnico] = []
    
    @Published var textoBusca: String = "" {
        didSet { filtrarTecnicos() }
    }
    @Published var isLoading = false
    
    let networkManager: NetworkManagerProtocol
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
    
    func fetchTecnicos() async {
        isLoading = true
        let resultado = await networkManager.fetchAllTecnicos()
        isLoading = false
        
        switch resultado {
        case .success(let tecnicos):
            self.todosOsTecnicos = tecnicos.sorted { $0.nomeCompleto < $1.nomeCompleto }
            self.tecnicosFiltrados = self.todosOsTecnicos
        case .failure(let error):
            print("❌ Erro ao buscar Técnicos: \(error.localizedDescription)")
        }
    }
    
    func deleteTecnico(at offsets: IndexSet) {
        let tecnicosParaDeletar = offsets.map { tecnicosFiltrados[$0] }
        Task {
            for tecnico in tecnicosParaDeletar {
                let resultado = await networkManager.deleteTecnico(id: tecnico.id)
                if case .success = resultado {
                    todosOsTecnicos.removeAll { $0.id == tecnico.id }
                    filtrarTecnicos()
                }
            }
        }
    }
    
    private func filtrarTecnicos() {
        if textoBusca.isEmpty {
            tecnicosFiltrados = todosOsTecnicos
        } else {
            tecnicosFiltrados = todosOsTecnicos.filter {
                $0.nomeCompleto.localizedCaseInsensitiveContains(textoBusca) ||
                ($0.especialidade ?? "").localizedCaseInsensitiveContains(textoBusca)
            }
        }
    }
}
