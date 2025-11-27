//
//  TopPecaReport.swift
//  NetworkCore
//
//  Created by Paulo Lazarini on 02/10/25.
//

import Foundation

public struct TopPecaReport: Decodable, Identifiable {
    public let id: UUID = UUID()
    public let nomePeca: String
    public let quantidade: Int
    
    public init(
        nomePeca: String,
        quantidade: Int
    ) {
        self.nomePeca = nomePeca
        self.quantidade = quantidade
    }
}
