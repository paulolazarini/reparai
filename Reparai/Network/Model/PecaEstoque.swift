//
//  PecaEstoque.swift
//  NetworkCore
//
//  Created by Paulo Lazarini on 13/09/25.
//

import Foundation

public struct PecaEstoque: Codable, Identifiable {
    public let id: String
    public var nomePeca: String
    public var descricao: String?
    public var fabricante: String?
    public var quantidadeDisponivel: Int
    public var precoCusto: Decimal
    public var precoVenda: Decimal
    
    public init(
        id: String,
        nomePeca: String,
        descricao: String? = nil,
        fabricante: String? = nil,
        quantidadeDisponivel: Int,
        precoCusto: Decimal,
        precoVenda: Decimal
    ) {
        self.id = id
        self.nomePeca = nomePeca
        self.descricao = descricao
        self.fabricante = fabricante
        self.quantidadeDisponivel = quantidadeDisponivel
        self.precoCusto = precoCusto
        self.precoVenda = precoVenda
    }
}
