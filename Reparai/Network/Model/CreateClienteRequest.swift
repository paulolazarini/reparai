//
//  CreateClienteRequest.swift
//  NetworkCore
//
//  Created by Paulo Lazarini on 14/09/25.
//

import Foundation

public struct CreateClienteRequest: Encodable {
    public let nomeCompleto: String
    public let telefone: String
    public let email: String?
    public let cpf: String?
    public let dataCriacao: Date?
    
    public init(
        nomeCompleto: String,
        telefone: String,
        email: String? = nil,
        cpf: String? = nil,
        dataCriacao: Date? = nil
    ) {
        self.nomeCompleto = nomeCompleto
        self.telefone = telefone
        self.email = email
        self.cpf = cpf
        self.dataCriacao = dataCriacao
    }
}

public struct CreatePecaRequest: Encodable {
    public let nomePeca: String
    public let fabricante: String?
    public let descricao: String?
    public let quantidadeDisponivel: Int
    public let precoCusto: Decimal
    public let precoVenda: Decimal
    
    public init(
        nomePeca: String,
        fabricante: String?,
        descricao: String?,
        quantidadeDisponivel: Int,
        precoCusto: Decimal,
        precoVenda: Decimal
    ) {
        self.nomePeca = nomePeca
        self.fabricante = fabricante
        self.descricao = descricao
        self.quantidadeDisponivel = quantidadeDisponivel
        self.precoCusto = precoCusto
        self.precoVenda = precoVenda
    }
}

public struct CreateTecnicoRequest: Encodable {
    public let nomeCompleto: String
    public let especialidade: String?
    public let dataAdmissao: Date
    public let ativo: Bool
    
    public init(
        nomeCompleto: String,
        especialidade: String?,
        dataAdmissao: Date,
        ativo: Bool
    ) {
        self.nomeCompleto = nomeCompleto
        self.especialidade = especialidade
        self.dataAdmissao = dataAdmissao
        self.ativo = ativo
    }
}

public struct CreateOrdemDeServicoRequest: Encodable {
    public let clienteId: String
    public let tecnicoId: String?
    public let tipoEquipamento: String
    public let marcaModelo: String
    public let numeroSerie: String?
    public let defeitoRelatado: String
    public let status: StatusOrdemDeServico
    public let dataEntrada: Date
    
    public init(
        clienteId: String,
        tecnicoId: String?,
        tipoEquipamento: String,
        marcaModelo: String,
        numeroSerie: String?,
        defeitoRelatado: String,
        status: StatusOrdemDeServico,
        dataEntrada: Date
    ) {
        self.clienteId = clienteId
        self.tecnicoId = tecnicoId
        self.tipoEquipamento = tipoEquipamento
        self.marcaModelo = marcaModelo
        self.numeroSerie = numeroSerie
        self.defeitoRelatado = defeitoRelatado
        self.status = status
        self.dataEntrada = dataEntrada
    }
}
