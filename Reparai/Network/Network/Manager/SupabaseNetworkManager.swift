//
//  SupabaseNetworkManager.swift
//  NetworkCore
//
//  Created by Paulo Lazarini on 14/09/25.
//

import Foundation

public struct SupabaseNetworkManager: NetworkManagerProtocol {
    
    public init() {}
    
    // MARK: - Ordem de Serviço
    
    public func fetchOrdensDeServico() async -> Result<[OrdemDeServico], RequestError> {
        await requestModel(endpoint: ReparaiEndpoint.fetchOrdensDeServico)
    }
    
    public func fetchOrdemDeServico(id: String) async -> Result<OrdemDeServico, RequestError> {
        await requestSingle(endpoint: ReparaiEndpoint.fetchOrdemDeServico(id: id))
    }
    
    public func createOrdemDeServico(_ data: CreateOrdemDeServicoRequest) async -> Result<Void, RequestError> {
        await request(endpoint: ReparaiEndpoint.createOrdemDeServico(data: data))
    }
    
    public func updateOrdemDeServico(_ os: OrdemDeServico) async -> Result<Void, RequestError> {
        await request(endpoint: ReparaiEndpoint.updateOrdemDeServico(id: os.id, data: os))
    }
    
    public func deleteOrdemDeServico(id: String) async -> Result<Void, RequestError> {
        await request(endpoint: ReparaiEndpoint.deleteOrdemDeServico(id: id))
    }
    
    // MARK: - Cliente
    
    public func fetchAllClientes() async -> Result<[Cliente], RequestError> {
        await requestModel(endpoint: ReparaiEndpoint.fetchAllClientes)
    }
    
    public func fetchCliente(byId id: String) async -> Result<Cliente, RequestError> {
        await requestSingle(endpoint: ReparaiEndpoint.fetchCliente(byId: id))
    }
    
    public func searchClientes(query: String) async -> Result<[Cliente], RequestError> {
        await requestModel(endpoint: ReparaiEndpoint.searchClientes(query: query))
    }
    
    public func createCliente(_ data: CreateClienteRequest) async -> Result<Void, RequestError> {
        await request(endpoint: ReparaiEndpoint.createCliente(data: data))
    }
    
    public func updateCliente(_ cliente: Cliente) async -> Result<Void, RequestError> {
        await request(endpoint: ReparaiEndpoint.updateCliente(id: cliente.id, data: cliente))
    }
    
    public func deleteCliente(id: String) async -> Result<Void, RequestError> {
        await request(endpoint: ReparaiEndpoint.deleteCliente(id: id))
    }
    
    // MARK: - Peças de Estoque
    
    public func fetchPecasEstoque() async -> Result<[PecaEstoque], RequestError> {
        await requestModel(endpoint: ReparaiEndpoint.fetchPecasEstoque)
    }
    
    public func fetchPeca(byId id: String) async -> Result<PecaEstoque, RequestError> {
        await requestSingle(endpoint: ReparaiEndpoint.fetchPeca(byId: id))
    }
    
    public func searchPecas(query: String) async -> Result<[PecaEstoque], RequestError> {
        await requestModel(endpoint: ReparaiEndpoint.searchPecas(query: query))
    }
    
    public func createPeca(_ data: CreatePecaRequest) async -> Result<Void, RequestError> {
        await request(endpoint: ReparaiEndpoint.createPeca(data: data))
    }
    
    public func updatePeca(_ peca: PecaEstoque) async -> Result<Void, RequestError> {
        await request(endpoint: ReparaiEndpoint.updatePeca(id: peca.id, data: peca))
    }
    
    public func deletePeca(id: String) async -> Result<Void, RequestError> {
        await request(endpoint: ReparaiEndpoint.deletePeca(id: id))
    }
    
    // MARK: - Orçamento Itens
    
    public func fetchAllItens() async -> Result<[OrcamentoItem], RequestError> {
        await requestModel(endpoint: ReparaiEndpoint.fetchAllItens)
    }
    
    public func fetchItens(paraOrdemDeServicoId id: String) async -> Result<[OrcamentoItem], RequestError> {
        await requestModel(endpoint: ReparaiEndpoint.fetchItens(osId: id))
    }
    
    public func addItem(_ item: OrcamentoItem, paraOrdemDeServicoId id: String) async -> Result<Void, RequestError> {
        await request(endpoint: ReparaiEndpoint.addItem(data: item))
    }
    
    public func updateItem(_ item: OrcamentoItem) async -> Result<Void, RequestError> {
        await request(endpoint: ReparaiEndpoint.updateItem(id: item.id, data: item))
    }
    
    public func deleteItem(id: String) async -> Result<Void, RequestError> {
        await request(endpoint: ReparaiEndpoint.deleteItem(id: id))
    }
    
    // MARK: - Técnicos
    
    public func fetchAllTecnicos() async -> Result<[Tecnico], RequestError> {
        await requestModel(endpoint: ReparaiEndpoint.fetchAllTecnicos)
    }
    
    public func fetchTecnico(byId id: String) async -> Result<Tecnico, RequestError> {
        await requestSingle(endpoint: ReparaiEndpoint.fetchTecnico(byId: id))
    }
    
    public func createTecnico(_ data: CreateTecnicoRequest) async -> Result<Void, RequestError> {
        await request(endpoint: ReparaiEndpoint.createTecnico(data: data))
    }
    
    public func updateTecnico(_ tecnico: Tecnico) async -> Result<Void, RequestError> {
        await request(endpoint: ReparaiEndpoint.updateTecnico(id: tecnico.id, data: tecnico))
    }
    
    public func deleteTecnico(id: String) async -> Result<Void, RequestError> {
        await request(endpoint: ReparaiEndpoint.deleteTecnico(id: id))
    }
    
    // MARK: - Relatórios (Top)

    public func fetchTopPecas(limit: Int = 5) async -> Result<[TopPecaReport], RequestError> {
        await requestModel(endpoint: ReparaiEndpoint.fetchTopPecas(limit: limit))
    }

    public func fetchTopClientes(limit: Int = 5) async -> Result<[TopClienteReport], RequestError> {
        await requestModel(endpoint: ReparaiEndpoint.fetchTopClientes(limit: limit))
    }

    public func fetchTopTecnicos(limit: Int = 5) async -> Result<[TopTecnicoReport], RequestError> {
        await requestModel(endpoint: ReparaiEndpoint.fetchTopTecnicos(limit: limit))
    }
}
