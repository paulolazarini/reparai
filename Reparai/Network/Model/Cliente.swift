//
//  Cliente.swift
//  NetworkCore
//
//  Created by Paulo Lazarini on 13/09/25.
//

import Foundation

public struct Cliente: Codable, Identifiable {
    public let id: String
    public var nomeCompleto: String
    public var telefone: String
    public var email: String?
    public var cpf: String?
    public var dataCriacao: String?
    
    public init(
        id: String,
        nomeCompleto: String,
        telefone: String,
        email: String? = nil,
        cpf: String? = nil,
        dataCriacao: String? = nil
    ) {
        self.id = id
        self.nomeCompleto = nomeCompleto
        self.telefone = telefone
        self.email = email
        self.cpf = cpf
        self.dataCriacao = dataCriacao
    }
}
