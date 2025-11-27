//
//  ReparaiEndpoint.swift
//  NetworkCore
//
//  Created by Paulo Lazarini on 14/09/25.
//

import Foundation

enum ReparaiEndpoint {
    case fetchOrdensDeServico
    case fetchOrdemDeServico(id: String)
    case createOrdemDeServico(data: CreateOrdemDeServicoRequest)
    case updateOrdemDeServico(id: String, data: OrdemDeServico)
    case deleteOrdemDeServico(id: String)
    
    case fetchAllClientes
    case fetchCliente(byId: String)
    case searchClientes(query: String)
    case createCliente(data: CreateClienteRequest)
    case updateCliente(id: String, data: Cliente)
    case deleteCliente(id: String)

    case fetchPecasEstoque
    case fetchPeca(byId: String)
    case searchPecas(query: String)
    case createPeca(data: CreatePecaRequest)
    case updatePeca(id: String, data: PecaEstoque)
    case deletePeca(id: String)
    
    case fetchAllItens
    case fetchItens(osId: String)
    case addItem(data: OrcamentoItem)
    case updateItem(id: String, data: OrcamentoItem)
    case deleteItem(id: String)
    
    case fetchAllTecnicos
    case fetchTecnico(byId: String)
    case createTecnico(data: CreateTecnicoRequest)
    case updateTecnico(id: String, data: Tecnico)
    case deleteTecnico(id: String)
    
    case fetchTopPecas(limit: Int = 5)
    case fetchTopClientes(limit: Int = 5)
    case fetchTopTecnicos(limit: Int = 5)
}

extension ReparaiEndpoint: Endpoint {
    
    var scheme: Scheme {
        .https
    }
    
    var baseURL: String {
        return SupabaseKeys.baseURL
    }
    
    var path: String {
        switch self {
        case .fetchOrdensDeServico, .createOrdemDeServico, .updateOrdemDeServico, .deleteOrdemDeServico, .fetchOrdemDeServico:
            return "/rest/v1/ordens_servico"
        case .fetchAllClientes, .createCliente, .updateCliente, .deleteCliente, .fetchCliente, .searchClientes:
            return "/rest/v1/clientes"
        case .fetchPecasEstoque, .createPeca, .updatePeca, .deletePeca, .fetchPeca, .searchPecas:
            return "/rest/v1/pecas_estoque"
        case .fetchAllItens, .fetchItens, .addItem, .updateItem, .deleteItem:
            return "/rest/v1/orcamento_itens"
        case .fetchAllTecnicos, .createTecnico, .updateTecnico, .deleteTecnico, .fetchTecnico:
            return "/rest/v1/tecnicos"
        case .fetchTopPecas:
            return "/rest/v1/rpc/report_top_pecas"
        case .fetchTopClientes:
            return "/rest/v1/rpc/report_top_clientes"
        case .fetchTopTecnicos:
            return "/rest/v1/rpc/report_top_tecnicos"
        }
    }

    var parameters: [URLQueryItem] {
        var params = [URLQueryItem(name: "select", value: "*")]
        
        switch self {
        case .fetchOrdemDeServico(let id), .updateOrdemDeServico(let id, _), .deleteOrdemDeServico(let id):
            params.append(URLQueryItem(name: "id", value: "eq.\(id)"))
        case .fetchCliente(let id), .updateCliente(let id, _), .deleteCliente(let id):
            params.append(URLQueryItem(name: "id", value: "eq.\(id)"))
        case .fetchPeca(let id), .updatePeca(let id, _), .deletePeca(let id):
            params.append(URLQueryItem(name: "id", value: "eq.\(id)"))
        case .fetchItens(let osId):
            params.append(URLQueryItem(name: "ordem_servico_id", value: "eq.\(osId)"))
        case .updateItem(let id, _), .deleteItem(let id):
            params.append(URLQueryItem(name: "id", value: "eq.\(id)"))
        case .fetchTecnico(let id), .updateTecnico(let id, _), .deleteTecnico(let id):
            params.append(URLQueryItem(name: "id", value: "eq.\(id)"))
        case .searchClientes(let query):
            params.append(URLQueryItem(name: "nome_completo", value: "ilike.*\(query)*"))
        case .searchPecas(let query):
            params.append(URLQueryItem(name: "nome_peca", value: "ilike.*\(query)*"))
        default:
            break
        }
        return params
    }
    
    var body: Encodable? {
        switch self {
        case .createOrdemDeServico(let data):
            return data
        case .updateOrdemDeServico(_, let data):
            return data
        case .createCliente(let data):
            return data
        case .updateCliente(_, let data):
            return data
        case .createPeca(let data):
            return data
        case .updatePeca(_, let data):
            return data
        case .addItem(let data):
            return data
        case .updateItem(_, let data):
            return data
        case .createTecnico(let data):
            return data
        case .updateTecnico(_, let data):
            return data
        case .fetchTopPecas(let limit):
            return ["limit_count": limit]
        case .fetchTopClientes(let limit):
            return ["limit_count": limit]
        case .fetchTopTecnicos(let limit):
            return ["limit_count": limit]
        default:
            return nil
        }
    }
    
    var method: RequestMethod {
        switch self {
        case .fetchAllItens, .fetchOrdensDeServico, .fetchOrdemDeServico, .fetchAllClientes, .fetchCliente, .searchClientes, .fetchPecasEstoque, .fetchPeca, .searchPecas, .fetchItens, .fetchAllTecnicos, .fetchTecnico:
            return .get
        case .createOrdemDeServico, .createCliente, .createPeca, .addItem, .createTecnico, .fetchTopPecas, .fetchTopClientes, .fetchTopTecnicos:
            return .post
        case .updateOrdemDeServico, .updateCliente, .updatePeca, .updateItem, .updateTecnico:
            return .patch
        case .deleteOrdemDeServico, .deleteCliente, .deletePeca, .deleteItem, .deleteTecnico:
            return .delete
        }
    }
    
    var headers: [String: String] {
        var headers = [
            "apikey": SupabaseKeys.anonKey,
            "Authorization": "Bearer \(SupabaseKeys.anonKey)"
        ]
        
        if method == .post || method == .patch {
            headers["Content-Type"] = "application/json"
            headers["Prefer"] = "return=representation"
        }
        
        return headers
    }
}

private enum SupabaseKeys {
    static var baseURL: String {
        "tweeaocqsmasfgkxwkgh.supabase.co"
//        guard let url = Bundle.main.infoDictionary?["SUPABASE_URL"] as? String else {
//            fatalError("Supabase URL not found in Info.plist")
//        }
//        return url
    }
    
    static var anonKey: String {
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR3ZWVhb2Nxc21hc2Zna3h3a2doIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc4NzMxODUsImV4cCI6MjA3MzQ0OTE4NX0.59JoulWwRMgaDmcCP1OINdFmsCIykehpb_oxchAqVzE"
//        guard let key = Bundle.main.infoDictionary?["SUPABASE_ANON_KEY"] as? String else {
//            fatalError("Supabase Anon Key not found in Info.plist")
//        }
//        return key
    }
}
