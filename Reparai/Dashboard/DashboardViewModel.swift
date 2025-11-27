//
//  DashboardViewModel.swift
//  Repar.ai
//
//  Created by Paulo Lazarini on 12/09/25.
//

import SwiftUI
import Combine

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var totalOSMes: Int = 0
    @Published var aguardandoAprovacaoCount: Int = 0
    @Published var emAndamentoCount: Int = 0
    @Published var faturamentoMensal: Decimal = 0
    @Published var atividadesRecentes: [OrdemDeServico] = []
    @Published var topPecas: [TopPecaReport] = []
    @Published var topClientes: [TopClienteReport] = []
    @Published var topTecnicos: [TopTecnicoReport] = []
    @Published var isLoading = false
    
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
    
    func fetchData() async {
        isLoading = true
        
        async let ordensResult = networkManager.fetchOrdensDeServico()
        async let topPecasResult = networkManager.fetchTopPecas(limit: 5)
        async let topClientesResult = networkManager.fetchTopClientes(limit: 5)
        async let topTecnicosResult = networkManager.fetchTopTecnicos(limit: 5)
        
        let (ordens, topPecasResp, topClientesResp, topTecnicosResp) = await (ordensResult, topPecasResult, topClientesResult, topTecnicosResult)
        
        isLoading = false
        
        switch ordens {
        case .success(let ordensList):
            totalOSMes = ordensList.count
            
            aguardandoAprovacaoCount = ordensList.filter {
                $0.status == .aguardandoAprovacao
            }.count
            
            emAndamentoCount = ordensList.filter {
                $0.status == .emConserto || $0.status == .aprovado
            }.count
            
            faturamentoMensal = ordensList
                .filter { ($0.status == .finalizado || $0.status == .entregue) && $0.valorTotal != nil }
                .reduce(0) { $0 + $1.valorTotal! }
            
            atividadesRecentes = Array(ordensList.sorted(by: { $0.dataEntrada > $1.dataEntrada }).prefix(3))
            
        case .failure(let error):
            print("❌ Erro ao buscar ordens: \(error.localizedDescription)")
        }
        
        // Top Peças
        if case .success(let pecas) = topPecasResp {
            self.topPecas = pecas
        }
        
        // Top Clientes
        if case .success(let clientes) = topClientesResp {
            self.topClientes = clientes
        }
        
        // Top Técnicos
        if case .success(let tecnicos) = topTecnicosResp {
            self.topTecnicos = tecnicos
        }
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
}

