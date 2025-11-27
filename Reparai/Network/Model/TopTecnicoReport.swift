//
//  TopTecnicoReport.swift
//  NetworkCore
//
//  Created by Paulo Lazarini on 02/10/25.
//

import Foundation

public struct TopTecnicoReport: Decodable, Identifiable {
    public let id: UUID = UUID()
    public let nomeTecnico: String?
    public let quantidadeServicos: Int
    
    public init(
        nomeTecnico: String?,
        quantidadeServicos: Int
    ) {
        self.nomeTecnico = nomeTecnico
        self.quantidadeServicos = quantidadeServicos
    }
}
