//
//  TopClienteReport.swift
//  NetworkCore
//
//  Created by Paulo Lazarini on 02/10/25.
//

import Foundation

public struct TopClienteReport: Decodable, Identifiable {
    public let id: UUID = UUID()
    public let nomeCliente: String?
    public let totalGasto: Decimal
    public let quantidadeOs: Int
    
    public init(
        nomeCliente: String?,
        totalGasto: Decimal,
        quantidadeOs: Int
    ) {
        self.nomeCliente = nomeCliente
        self.totalGasto = totalGasto
        self.quantidadeOs = quantidadeOs
    }
}
