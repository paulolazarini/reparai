//
//  FirebaseNetworkManager.swift
//  NetworkCore
//
//  Created by Paulo Lazarini on 23/11/25.
//

import Foundation
import FirebaseCore
import FirebaseFirestore

public struct FirebaseNetworkManager: NetworkManagerProtocol {
    
    private let db = Firestore.firestore()
    
    public init() {}
    
    // MARK: - Helpers Privados
    
    private func mapError(_ error: Error) -> RequestError {
        print("🔴 ERRO FIREBASE DETALHADO: \(error)")
        print("🔴 DESCRIÇÃO: \(error.localizedDescription)")
        
        if let decodingError = error as? DecodingError {
            print("🔴 FALHA DE DECODIFICAÇÃO: \(decodingError)")
        }

        return .unknown
    }
    
    // MARK: - Ordem de Serviço
    
    public func fetchOrdensDeServico() async -> Result<[OrdemDeServico], RequestError> {
        do {
            let snapshot = try await db.collection("ordens_servico").getDocuments()
            let ordens = try snapshot.documents.compactMap { doc -> OrdemDeServico? in
                try doc.data(as: OrdemDeServico.self)
            }
            return .success(ordens)
        } catch {
            return .failure(mapError(error))
        }
    }
    
    public func fetchOrdemDeServico(id: String) async -> Result<OrdemDeServico, RequestError> {
        do {
            let doc = try await db.collection("ordens_servico").document(id).getDocument()
            let ordem = try doc.data(as: OrdemDeServico.self)
            return .success(ordem)
        } catch {
            return .failure(mapError(error))
        }
    }
    
    public func createOrdemDeServico(_ data: CreateOrdemDeServicoRequest) async -> Result<Void, RequestError> {
        do {
            let newId = UUID().uuidString
            var dict = try data.asDictionary()
            dict["id"] = newId
            
            try await db.collection("ordens_servico").document(newId).setData(dict)
            return .success(())
        } catch {
            return .failure(mapError(error))
        }
    }
    
    public func updateOrdemDeServico(_ os: OrdemDeServico) async -> Result<Void, RequestError> {
        do {
            try db.collection("ordens_servico").document(os.id).setData(from: os)
            return .success(())
        } catch {
            return .failure(mapError(error))
        }
    }
    
    public func deleteOrdemDeServico(id: String) async -> Result<Void, RequestError> {
        do {
            try await db.collection("ordens_servico").document(id).delete()
            return .success(())
        } catch {
            return .failure(mapError(error))
        }
    }
    
    // MARK: - Cliente
    
    public func fetchAllClientes() async -> Result<[Cliente], RequestError> {
        do {
            let snapshot = try await db.collection("clientes").getDocuments()
            let clientes = try snapshot.documents.compactMap { try $0.data(as: Cliente.self) }
            return .success(clientes)
        } catch {
            return .failure(mapError(error))
        }
    }
    
    public func fetchCliente(byId id: String) async -> Result<Cliente, RequestError> {
        do {
            let doc = try await db.collection("clientes").document(id).getDocument()
            let cliente = try doc.data(as: Cliente.self)
            return .success(cliente)
        } catch {
            return .failure(mapError(error))
        }
    }
    
    public func searchClientes(query: String) async -> Result<[Cliente], RequestError> {
            guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                return await fetchAllClientes()
            }
            
            do {
                let snapshot = try await db.collection("clientes")
                    .whereField("nomeCompleto", isGreaterThanOrEqualTo: query)
                    .whereField("nomeCompleto", isLessThan: query + "\u{f8ff}")
                    .getDocuments()
                
                let clientes = try snapshot.documents.compactMap { try $0.data(as: Cliente.self) }
                return .success(clientes)
            } catch {
                return .failure(mapError(error))
            }
        }
    
    public func createCliente(_ data: CreateClienteRequest) async -> Result<Void, RequestError> {
        do {
            let newId = UUID().uuidString
            var dict = try data.asDictionary()
            dict["id"] = newId
            
            try await db.collection("clientes").document(newId).setData(dict)
            return .success(())
        } catch {
            return .failure(mapError(error))
        }
    }
    
    public func updateCliente(_ cliente: Cliente) async -> Result<Void, RequestError> {
        do {
            try db.collection("clientes").document(cliente.id).setData(from: cliente)
            return .success(())
        } catch {
            return .failure(mapError(error))
        }
    }
    
    public func deleteCliente(id: String) async -> Result<Void, RequestError> {
        do {
            try await db.collection("clientes").document(id).delete()
            return .success(())
        } catch {
            return .failure(mapError(error))
        }
    }
    
    // MARK: - Peças de Estoque
    
    public func fetchPecasEstoque() async -> Result<[PecaEstoque], RequestError> {
        do {
            let snapshot = try await db.collection("pecas").getDocuments()
            let pecas = try snapshot.documents.compactMap { try $0.data(as: PecaEstoque.self) }
            return .success(pecas)
        } catch {
            return .failure(mapError(error))
        }
    }
    
    public func fetchPeca(byId id: String) async -> Result<PecaEstoque, RequestError> {
        do {
            let doc = try await db.collection("pecas").document(id).getDocument()
            let peca = try doc.data(as: PecaEstoque.self)
            return .success(peca)
        } catch {
            return .failure(mapError(error))
        }
    }
    
    public func searchPecas(query: String) async -> Result<[PecaEstoque], RequestError> {
            guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                return await fetchPecasEstoque()
            }
            
            do {
                let snapshot = try await db.collection("pecas")
                    .whereField("nomePeca", isGreaterThanOrEqualTo: query)
                    .whereField("nomePeca", isLessThan: query + "\u{f8ff}")
                    .getDocuments()
                
                let pecas = try snapshot.documents.compactMap { try $0.data(as: PecaEstoque.self) }
                return .success(pecas)
            } catch {
                return .failure(mapError(error))
            }
        }
    
    public func createPeca(_ data: CreatePecaRequest) async -> Result<Void, RequestError> {
        do {
            let newId = UUID().uuidString
            var dict = try data.asDictionary()
            dict["id"] = newId
            
            try await db.collection("pecas").document(newId).setData(dict)
            return .success(())
        } catch {
            return .failure(mapError(error))
        }
    }
    
    public func updatePeca(_ peca: PecaEstoque) async -> Result<Void, RequestError> {
        do {
            try db.collection("pecas").document(peca.id).setData(from: peca)
            return .success(())
        } catch {
            return .failure(mapError(error))
        }
    }
    
    public func deletePeca(id: String) async -> Result<Void, RequestError> {
        do {
            try await db.collection("pecas").document(id).delete()
            return .success(())
        } catch {
            return .failure(mapError(error))
        }
    }
    
    // MARK: - Orçamento Itens
    
    public func fetchAllItens() async -> Result<[OrcamentoItem], RequestError> {
        do {
            let snapshot = try await db.collection("orcamento_itens").getDocuments()
            let itens = try snapshot.documents.compactMap { try $0.data(as: OrcamentoItem.self) }
            return .success(itens)
        } catch {
            return .failure(mapError(error))
        }
    }
    
    public func fetchItens(paraOrdemDeServicoId id: String) async -> Result<[OrcamentoItem], RequestError> {
        do {
            let snapshot = try await db.collection("orcamento_itens")
                .whereField("ordemServicoId", isEqualTo: id)
                .getDocuments()
            
            let itens = try snapshot.documents.compactMap { try $0.data(as: OrcamentoItem.self) }
            return .success(itens)
        } catch {
            return .failure(mapError(error))
        }
    }
    
    public func addItem(_ item: OrcamentoItem, paraOrdemDeServicoId id: String) async -> Result<Void, RequestError> {
        do {
            var itemToSave = item
            itemToSave.ordemServicoId = id
            
            let itemId = itemToSave.id.isEmpty ? UUID().uuidString : itemToSave.id
            
            var dict = try itemToSave.asDictionary()
            dict["id"] = itemId
            
            try await db.collection("orcamento_itens").document(itemId).setData(dict)
            return .success(())
        } catch {
            return .failure(mapError(error))
        }
    }
    
    public func updateItem(_ item: OrcamentoItem) async -> Result<Void, RequestError> {
        do {
            try db.collection("orcamento_itens").document(item.id).setData(from: item)
            return .success(())
        } catch {
            return .failure(mapError(error))
        }
    }
    
    public func deleteItem(id: String) async -> Result<Void, RequestError> {
        do {
            try await db.collection("orcamento_itens").document(id).delete()
            return .success(())
        } catch {
            return .failure(mapError(error))
        }
    }
    
    // MARK: - Técnicos
    
    public func fetchAllTecnicos() async -> Result<[Tecnico], RequestError> {
        do {
            let snapshot = try await db.collection("tecnicos").getDocuments()
            let tecnicos = try snapshot.documents.compactMap { try $0.data(as: Tecnico.self) }
            return .success(tecnicos)
        } catch {
            return .failure(mapError(error))
        }
    }
    
    public func fetchTecnico(byId id: String) async -> Result<Tecnico, RequestError> {
        do {
            let doc = try await db.collection("tecnicos").document(id).getDocument()
            let tecnico = try doc.data(as: Tecnico.self)
            return .success(tecnico)
        } catch {
            return .failure(mapError(error))
        }
    }
    
    public func createTecnico(_ data: CreateTecnicoRequest) async -> Result<Void, RequestError> {
        do {
            let newId = UUID().uuidString
            var dict = try data.asDictionary()
            dict["id"] = newId
            
            try await db.collection("tecnicos").document(newId).setData(dict)
            return .success(())
        } catch {
            return .failure(mapError(error))
        }
    }
    
    public func updateTecnico(_ tecnico: Tecnico) async -> Result<Void, RequestError> {
        do {
            try db.collection("tecnicos").document(tecnico.id).setData(from: tecnico)
            return .success(())
        } catch {
            return .failure(mapError(error))
        }
    }
    
    public func deleteTecnico(id: String) async -> Result<Void, RequestError> {
        do {
            try await db.collection("tecnicos").document(id).delete()
            return .success(())
        } catch {
            return .failure(mapError(error))
        }
    }
    
    // MARK: - Relatórios (Client-Side Logic)
    
    public func fetchTopPecas(limit: Int = 5) async -> Result<[TopPecaReport], RequestError> {
        let resultItens = await fetchAllItens()
        
        switch resultItens {
        case .failure(let error): return .failure(error)
        case .success(let itens):
            var counts: [String: Int] = [:]
            for item in itens {
                if let pId = item.pecaId {
                    counts[pId, default: 0] += item.quantidade
                }
            }
            
            let sortedIds = counts.sorted { $0.value > $1.value }.prefix(limit).map { $0.key }
            
            var reports: [TopPecaReport] = []
            
            for pId in sortedIds {
                let pecaResult = await fetchPeca(byId: pId)
                if case .success(let peca) = pecaResult {
                    let qtd = counts[pId] ?? 0
                    reports.append(TopPecaReport(nomePeca: peca.nomePeca, quantidade: qtd))
                }
            }
            
            return .success(reports)
        }
    }
    
    public func fetchTopClientes(limit: Int = 5) async -> Result<[TopClienteReport], RequestError> {
        let resultOS = await fetchOrdensDeServico()
        
        switch resultOS {
        case .failure(let error): return .failure(error)
        case .success(let ordens):
            var clienteStats: [String: (total: Decimal, count: Int)] = [:]
            
            for os in ordens {
                let current = clienteStats[os.clienteId] ?? (total: 0, count: 0)
                let valor = os.valorTotal ?? 0
                clienteStats[os.clienteId] = (total: current.total + valor, count: current.count + 1)
            }
            
            let sortedStats = clienteStats.sorted { $0.value.total > $1.value.total }.prefix(limit)
            
            var reports: [TopClienteReport] = []
            for (clienteId, stats) in sortedStats {
                let clienteResult = await fetchCliente(byId: clienteId)
                let nome = (try? clienteResult.get().nomeCompleto) ?? "Desconhecido"
                
                reports.append(TopClienteReport(nomeCliente: nome, totalGasto: stats.total, quantidadeOs: stats.count))
            }
            
            return .success(reports)
        }
    }
    
    public func fetchTopTecnicos(limit: Int = 5) async -> Result<[TopTecnicoReport], RequestError> {
        let resultOS = await fetchOrdensDeServico()
        
        switch resultOS {
        case .failure(let error): return .failure(error)
        case .success(let ordens):
            var counts: [String: Int] = [:]
            
            for os in ordens {
                if let tid = os.tecnicoId {
                    counts[tid, default: 0] += 1
                }
            }
            
            let sortedStats = counts.sorted { $0.value > $1.value }.prefix(limit)
            
            var reports: [TopTecnicoReport] = []
            for (tecId, count) in sortedStats {
                let tecResult = await fetchTecnico(byId: tecId)
                let nome = (try? tecResult.get().nomeCompleto) ?? "Desconhecido"
                
                reports.append(TopTecnicoReport(nomeTecnico: nome, quantidadeServicos: count))
            }
            
            return .success(reports)
        }
    }
}

extension Encodable {
    public func asDictionary() throws -> [String: Any] {
        let encoder = Firestore.Encoder()
        return try encoder.encode(self)
    }
}
