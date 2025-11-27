//
//  OrdemDeServico.swift
//  NetworkCore
//
//  Created by Paulo Lazarini on 13/09/25.
//

import Foundation

public struct OrdemDeServico: Codable, Identifiable {
    public var id: String
    public var clienteId: String
    public var tecnicoId: String?
    public var tipoEquipamento: String
    public var marcaModelo: String
    public var numeroSerie: String?
    public var defeitoRelatado: String
    public var diagnosticoTecnico: String?
    public var status: StatusOrdemDeServico
    public var dataEntrada: Date
    public var dataPrevisaoEntrega: Date?
    public var dataEntrega: Date?
    public var valorMaoDeObra: Decimal?
    public var valorTotal: Decimal?
    
    public init(
        id: String,
        clienteId: String,
        tecnicoId: String?,
        tipoEquipamento: String,
        marcaModelo: String,
        numeroSerie: String?,
        defeitoRelatado: String,
        diagnosticoTecnico: String?,
        status: StatusOrdemDeServico,
        dataEntrada: Date,
        dataPrevisaoEntrega: Date? = nil,
        dataEntrega: Date? = nil,
        valorMaoDeObra: Decimal? = nil,
        valorTotal: Decimal? = nil
    ) {
        self.id = id
        self.clienteId = clienteId
        self.tecnicoId = tecnicoId
        self.tipoEquipamento = tipoEquipamento
        self.marcaModelo = marcaModelo
        self.numeroSerie = numeroSerie
        self.defeitoRelatado = defeitoRelatado
        self.diagnosticoTecnico = diagnosticoTecnico
        self.status = status
        self.dataEntrada = dataEntrada
        self.dataPrevisaoEntrega = dataPrevisaoEntrega
        self.dataEntrega = dataEntrega
        self.valorMaoDeObra = valorMaoDeObra
        self.valorTotal = valorTotal
    }
}
