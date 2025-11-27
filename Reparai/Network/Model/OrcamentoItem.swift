//
//  OrcamentoItem.swift
//  NetworkCore
//
//  Created by Paulo Lazarini on 13/09/25.
//

import Foundation

public struct OrcamentoItem: Codable, Identifiable {
    public let id: String
    public var ordemServicoId: String
    public var pecaId: String?
    public var descricaoServico: String?
    public var quantidade: Int
    public var valorUnitario: Decimal
    
    public var valorTotalItem: Decimal {
        return valorUnitario * Decimal(quantidade)
    }
    
    public init(
        id: String,
        ordemServicoId: String,
        pecaId: String?,
        descricaoServico: String?,
        quantidade: Int,
        valorUnitario: Decimal
    ) {
        self.id = id
        self.ordemServicoId = ordemServicoId
        self.pecaId = pecaId
        self.descricaoServico = descricaoServico
        self.quantidade = quantidade
        self.valorUnitario = valorUnitario
    }
}
