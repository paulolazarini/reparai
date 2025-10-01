//
//  DashboardViewModel.swift
//  Repar.ai
//
//  Created by Paulo Lazarini on 12/09/25.
//

import SwiftUI
import Combine
import NetworkCore

struct TopPecaData: Identifiable {
    let id = UUID()
    let nome: String
    let quantidade: Int
}

import SwiftUI
import Combine
import NetworkCore

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var totalOSMes: Int = 0
    @Published var aguardandoAprovacaoCount: Int = 0
    @Published var emAndamentoCount: Int = 0
    @Published var faturamentoMensal: Decimal = 0
    @Published var atividadesRecentes: [OrdemDeServico] = []
    @Published var topPecas: [TopPecaData] = []
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
        async let itensResult = networkManager.fetchAllItens()
        async let pecasResult = networkManager.fetchPecasEstoque()
        
        let (ordens, itens, pecas) = await (ordensResult, itensResult, pecasResult)
        
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
            
            if case .success(let todosOsItens) = itens, case .success(let todasAsPecas) = pecas {
                calcularTopPecas(itens: todosOsItens, pecas: todasAsPecas)
            }
            
        case .failure(let error):
            print("❌ Erro ao buscar dados do dashboard (ordens): \(error.localizedDescription)")
        }
        
        if case .success(let todosOsItens) = itens, case .success(let todasAsPecas) = pecas {
            calcularTopPecas(itens: todosOsItens, pecas: todasAsPecas)
        }
    }
    
    private func calcularTopPecas(itens: [OrcamentoItem], pecas: [PecaEstoque]) {
        var contagem: [String: Int] = [:]
        
        for item in itens {
            if let pecaId = item.pecaId {
                contagem[pecaId, default: 0] += item.quantidade
            }
        }
        
        let top5Ids = contagem.sorted { $0.value > $1.value }.prefix(5)
        
        self.topPecas = top5Ids.compactMap { pecaId, quantidade in
            guard let pecaInfo = pecas.first(where: { $0.id == pecaId }) else {
                return nil
            }
            return TopPecaData(nome: pecaInfo.nomePeca, quantidade: quantidade)
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
