//
//  NovaOrdemDeServicoViewModel.swift
//  Repar.ai
//
//  Created by Paulo Lazarini on 13/09/25.
//

import SwiftUI
import Combine
import NetworkCore

@MainActor
class NovaOrdemDeServicoViewModel: ObservableObject {
    
    @Published var clienteSelecionado: Cliente?
    @Published var buscaClienteTexto: String = ""
    @Published var tipoEquipamento: TipoEquipamento = .celular
    @Published var marcaModelo: String = ""
    @Published var numeroSerie: String = ""
    @Published var problemaRelatado: String = ""
    
    @Published var resultadosBuscaCliente: [Cliente] = []
    @Published var isSaving = false
    @Published var podeSalvar = false
    
    private let networkManager: NetworkManagerProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
        setupBindings()
    }
    
    private func setupBindings() {
        $buscaClienteTexto
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .filter { !$0.isEmpty }
            .sink { [weak self] query in
                self?.buscarClientes(query: query)
            }
            .store(in: &cancellables)
        
        Publishers.CombineLatest3(
            $clienteSelecionado,
            $marcaModelo,
            $problemaRelatado
        )
        .map { cliente, marca, problema in
            return cliente != nil
            && !marca.trimmingCharacters(in: .whitespaces).isEmpty
            && !problema.trimmingCharacters(in: .whitespaces).isEmpty
        }
        .assign(to: &$podeSalvar)
    }
    
    private func buscarClientes(query: String) {
        Task {
            let resultado = await networkManager.searchClientes(query: query)
            if case .success(let clientes) = resultado {
                self.resultadosBuscaCliente = clientes
            }
        }
    }
    
    func selecionarCliente(_ cliente: Cliente) {
        self.clienteSelecionado = cliente
        self.buscaClienteTexto = cliente.nomeCompleto
        self.resultadosBuscaCliente = []
    }
    
    func salvarOrdemDeServico() async -> Bool {
        guard podeSalvar, let cliente = clienteSelecionado else { return false }
        
        isSaving = true
        
        let osRequest = CreateOrdemDeServicoRequest(
            clienteId: cliente.id,
            tecnicoId: nil,
            tipoEquipamento: self.tipoEquipamento.rawValue,
            marcaModelo: self.marcaModelo,
            numeroSerie: self.numeroSerie.isEmpty ? nil : self.numeroSerie,
            defeitoRelatado: self.problemaRelatado,
            status: .aguardandoAvaliacao,
            dataEntrada: Date()
        )
        
        let resultado = await networkManager.createOrdemDeServico(osRequest)
        isSaving = false
        
        switch resultado {
        case .success:
            return true
        case .failure(let error):
            print("❌ Falha ao salvar OS: \(error.localizedDescription)")
            return false
        }
    }
}
