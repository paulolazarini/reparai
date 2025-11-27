//
//  Tecnico.swift
//  NetworkCore
//
//  Created by Paulo Lazarini on 13/09/25.
//

import Foundation

public struct Tecnico: Codable, Identifiable {
    public let id: String
    public var nomeCompleto: String
    public var especialidade: String?
    public var dataAdmissao: Date
    public var ativo: Bool
    
    public init(
        id: String,
        nomeCompleto: String,
        especialidade: String? = nil,
        dataAdmissao: Date,
        ativo: Bool
    ) {
        self.id = id
        self.nomeCompleto = nomeCompleto
        self.especialidade = especialidade
        self.dataAdmissao = dataAdmissao
        self.ativo = ativo
    }
}
