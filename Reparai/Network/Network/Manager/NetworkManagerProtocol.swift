//
//  NetworkManagerProtocol.swift
//  NetworkCore
//
//  Created by Paulo Lazarini on 12/09/25.
//

import Foundation

public protocol NetworkManagerProtocol: HTTPClient {
    func fetchOrdensDeServico() async -> Result<[OrdemDeServico], RequestError>
    func fetchOrdemDeServico(id: String) async -> Result<OrdemDeServico, RequestError>
    func createOrdemDeServico(_ data: CreateOrdemDeServicoRequest) async -> Result<Void, RequestError>
    func updateOrdemDeServico(_ os: OrdemDeServico) async -> Result<Void, RequestError>
    func deleteOrdemDeServico(id: String) async -> Result<Void, RequestError>
    
    func fetchAllClientes() async -> Result<[Cliente], RequestError>
    func fetchCliente(byId id: String) async -> Result<Cliente, RequestError>
    func searchClientes(query: String) async -> Result<[Cliente], RequestError>
    func createCliente(_ data: CreateClienteRequest) async -> Result<Void, RequestError>
    func updateCliente(_ cliente: Cliente) async -> Result<Void, RequestError>
    func deleteCliente(id: String) async -> Result<Void, RequestError>

    func fetchPecasEstoque() async -> Result<[PecaEstoque], RequestError>
    func fetchPeca(byId id: String) async -> Result<PecaEstoque, RequestError>
    func searchPecas(query: String) async -> Result<[PecaEstoque], RequestError>
    func createPeca(_ data: CreatePecaRequest) async -> Result<Void, RequestError>
    func updatePeca(_ peca: PecaEstoque) async -> Result<Void, RequestError>
    func deletePeca(id: String) async -> Result<Void, RequestError>
    
    func fetchItens(paraOrdemDeServicoId id: String) async -> Result<[OrcamentoItem], RequestError>
    func fetchAllItens() async -> Result<[OrcamentoItem], RequestError>
    func addItem(_ item: OrcamentoItem, paraOrdemDeServicoId id: String) async -> Result<Void, RequestError>
    func updateItem(_ item: OrcamentoItem) async -> Result<Void, RequestError>
    func deleteItem(id: String) async -> Result<Void, RequestError>
    
    func fetchAllTecnicos() async -> Result<[Tecnico], RequestError>
    func fetchTecnico(byId id: String) async -> Result<Tecnico, RequestError>
    func createTecnico(_ data: CreateTecnicoRequest) async -> Result<Void, RequestError>
    func updateTecnico(_ tecnico: Tecnico) async -> Result<Void, RequestError>
    func deleteTecnico(id: String) async -> Result<Void, RequestError>
    
    func fetchTopPecas(limit: Int) async -> Result<[TopPecaReport], RequestError>
    func fetchTopClientes(limit: Int) async -> Result<[TopClienteReport], RequestError>
    func fetchTopTecnicos(limit: Int) async -> Result<[TopTecnicoReport], RequestError>
}

import Foundation

public class MockNetworkManager: NetworkManagerProtocol {
    var mockClientes: [Cliente] = [
        Cliente(id: UUID().uuidString, nomeCompleto: "Ana Beatriz Costa", telefone: "(47) 99123-4567", email: "ana.costa@email.com", cpf: "111.222.333-44"),
        Cliente(id: UUID().uuidString, nomeCompleto: "Carlos de Andrade", telefone: "(47) 99876-5432", email: "carlos.a@email.com", cpf: "222.333.444-55"),
    ]
    
    var mockTecnicos: [Tecnico] = [
        Tecnico(id: UUID().uuidString, nomeCompleto: "Ricardo Souza", especialidade: "Smartphones Apple", dataAdmissao: Date(), ativo: true),
    ]
    
    var mockPecas: [PecaEstoque] = [
        PecaEstoque(id: UUID().uuidString, nomePeca: "Tela Super Retina XDR", fabricante: "Apple Inc.", quantidadeDisponivel: 12, precoCusto: 1200.00, precoVenda: 1850.00),
    ]
    
    lazy var mockOrdensDeServico: [OrdemDeServico] = [
        OrdemDeServico(id: "202501", clienteId: mockClientes[0].id, tecnicoId: mockTecnicos[0].id, tipoEquipamento: "Celular", marcaModelo: "Apple iPhone 15 Pro", numeroSerie: "G6TF345QWERT", defeitoRelatado: "Tela trincada", diagnosticoTecnico: "Troca de display", status: .emConserto, dataEntrada: Date(), valorTotal: 1980.00),
    ]
    
    lazy var mockOrcamentoItens: [OrcamentoItem] = [
        OrcamentoItem(id: UUID().uuidString, ordemServicoId: "202501", pecaId: mockPecas[0].id, descricaoServico: "Troca de Tela", quantidade: 1, valorUnitario: 1850.00)
    ]
    
    public init() {}
    
    private func simularLatencia(segundos: Double = 0.5) async {
        try? await Task.sleep(for: .seconds(segundos))
    }
    
    public func fetchOrdensDeServico() async -> Result<[OrdemDeServico], RequestError> {
        await simularLatencia()
        return .success(mockOrdensDeServico)
    }
    
    public func fetchOrdemDeServico(id: String) async -> Result<OrdemDeServico, RequestError> {
        await simularLatencia()
        if let os = mockOrdensDeServico.first(where: { $0.id == id }) {
            return .success(os)
        }
        return .failure(.unknown)
    }
    
    public func createOrdemDeServico(_ data: CreateOrdemDeServicoRequest) async -> Result<Void, RequestError> {
        await simularLatencia()
        let novaOS = OrdemDeServico(
            id: String(Int.random(in: 1000...9999)),
            clienteId: data.clienteId,
            tecnicoId: data.tecnicoId,
            tipoEquipamento: data.tipoEquipamento,
            marcaModelo: data.marcaModelo,
            numeroSerie: data.numeroSerie,
            defeitoRelatado: data.defeitoRelatado,
            diagnosticoTecnico: nil,
            status: data.status,
            dataEntrada: data.dataEntrada,
            dataPrevisaoEntrega: nil,
            dataEntrega: nil,
            valorTotal: nil
        )
        mockOrdensDeServico.append(novaOS)
        return .success(())
    }
    
    public func updateOrdemDeServico(_ os: OrdemDeServico) async -> Result<Void, RequestError> {
        await simularLatencia()
        return .success(())
    }
    
    public func deleteOrdemDeServico(id: String) async -> Result<Void, RequestError> {
        await simularLatencia()
        mockOrdensDeServico.removeAll { $0.id == id }
        return .success(())
    }
    
    public func fetchAllClientes() async -> Result<[Cliente], RequestError> {
        await simularLatencia()
        return .success(mockClientes)
    }
    
    public func fetchCliente(byId id: String) async -> Result<Cliente, RequestError> {
        await simularLatencia()
        if let cliente = mockClientes.first(where: { $0.id == id }) {
            return .success(cliente)
        }
        return .failure(.unknown)
    }
    
    public func searchClientes(query: String) async -> Result<[Cliente], RequestError> {
        await simularLatencia()
        if query.isEmpty { return .success(mockClientes) }
        return .success(mockClientes.filter { $0.nomeCompleto.localizedCaseInsensitiveContains(query) })
    }
    
    public func createCliente(_ data: CreateClienteRequest) async -> Result<Void, RequestError> {
        await simularLatencia()
        let novoCliente = Cliente(
            id: UUID().uuidString,
            nomeCompleto: data.nomeCompleto,
            telefone: data.telefone
        )
        mockClientes.append(novoCliente)
        return .success(())
    }
    
    public func updateCliente(_ cliente: Cliente) async -> Result<Void, RequestError> {
        await simularLatencia()
        return .success(())
    }
    
    public func deleteCliente(id: String) async -> Result<Void, RequestError> {
        await simularLatencia()
        mockClientes.removeAll { $0.id == id }
        return .success(())
    }
    
    public func fetchPecasEstoque() async -> Result<[PecaEstoque], RequestError> {
        await simularLatencia()
        return .success(mockPecas)
    }
    
    public func fetchPeca(byId id: String) async -> Result<PecaEstoque, RequestError> {
        await simularLatencia()
        if let peca = mockPecas.first(where: { $0.id == id }) {
            return .success(peca)
        }
        return .failure(.unknown)
    }
    
    public func searchPecas(query: String) async -> Result<[PecaEstoque], RequestError> {
        await simularLatencia()
        if query.isEmpty { return .success(mockPecas) }
        return .success(mockPecas.filter { $0.nomePeca.localizedCaseInsensitiveContains(query) })
    }
    
    public func createPeca(_ data: CreatePecaRequest) async -> Result<Void, RequestError> {
        await simularLatencia()
        let novaPeca = PecaEstoque(
            id: UUID().uuidString,
            nomePeca: data.nomePeca,
            descricao: data.descricao,
            fabricante: data.fabricante,
            quantidadeDisponivel: data.quantidadeDisponivel,
            precoCusto: data.precoCusto,
            precoVenda: data.precoVenda
        )
        mockPecas.append(novaPeca)
        return .success(())
    }
    
    public func updatePeca(_ peca: PecaEstoque) async -> Result<Void, RequestError> {
        await simularLatencia()
        return .success(())
    }
    
    public func deletePeca(id: String) async -> Result<Void, RequestError> {
        await simularLatencia()
        mockPecas.removeAll { $0.id == id }
        return .success(())
    }
    
    public func fetchItens(paraOrdemDeServicoId id: String) async -> Result<[OrcamentoItem], RequestError> {
        await simularLatencia()
        return .success(mockOrcamentoItens.filter { $0.ordemServicoId == id })
    }
    
    public func fetchAllItens() async -> Result<[OrcamentoItem], RequestError> {
        await simularLatencia()
        return .success(mockOrcamentoItens)
    }
    
    public func addItem(_ item: OrcamentoItem, paraOrdemDeServicoId id: String) async -> Result<Void, RequestError> {
        await simularLatencia()
        mockOrcamentoItens.append(item)
        return .success(())
    }
    
    public func updateItem(_ item: OrcamentoItem) async -> Result<Void, RequestError> {
        await simularLatencia()
        return .success(())
    }
    
    public func deleteItem(id: String) async -> Result<Void, RequestError> {
        await simularLatencia()
        mockOrcamentoItens.removeAll { $0.id == id }
        return .success(())
    }
    
    public func fetchAllTecnicos() async -> Result<[Tecnico], RequestError> {
        await simularLatencia()
        return .success(mockTecnicos)
    }
    
    public func fetchTecnico(byId id: String) async -> Result<Tecnico, RequestError> {
        await simularLatencia()
        if let tecnico = mockTecnicos.first(where: { $0.id == id }) {
            return .success(tecnico)
        }
        return .failure(.unknown)
    }
    
    public func createTecnico(_ data: CreateTecnicoRequest) async -> Result<Void, RequestError> {
        await simularLatencia()
        let novoTecnico = Tecnico(
            id: UUID().uuidString,
            nomeCompleto: data.nomeCompleto,
            especialidade: data.especialidade,
            dataAdmissao: data.dataAdmissao,
            ativo: data.ativo
        )
        mockTecnicos.append(novoTecnico)
        return .success(())
    }
    
    public func updateTecnico(_ tecnico: Tecnico) async -> Result<Void, RequestError> {
        await simularLatencia()
        return .success(())
    }
    
    public func deleteTecnico(id: String) async -> Result<Void, RequestError> {
        await simularLatencia()
        mockTecnicos.removeAll { $0.id == id }
        return .success(())
    }
    
    public func fetchTopPecas(limit: Int) async -> Result<[TopPecaReport], RequestError> {
        .failure(.decode)
    }
    
    public func fetchTopClientes(limit: Int) async -> Result<[TopClienteReport], RequestError> {
        .failure(.decode)
    }
    
    public func fetchTopTecnicos(limit: Int) async -> Result<[TopTecnicoReport], RequestError> {
        .failure(.decode)
    }
}
