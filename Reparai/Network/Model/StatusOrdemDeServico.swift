//
//  StatusOrdemDeServico.swift
//  NetworkCore
//
//  Created by Paulo Lazarini on 14/09/25.
//

import SwiftUI

public enum StatusOrdemDeServico: String, Codable, CaseIterable, Identifiable {
    case aguardandoAvaliacao = "Aguardando Avaliação"
    case emOrcamento = "Em Orçamento"
    case aguardandoAprovacao = "Aguardando Aprovação"
    case aprovado = "Aprovado"
    case emConserto = "Em Conserto"
    case finalizado = "Finalizado"
    case entregue = "Entregue"
    
    public var id: String { self.rawValue }
    
    public var cor: Color {
        switch self {
        case .aguardandoAvaliacao, .emOrcamento, .aguardandoAprovacao:
            return .orange
        case .aprovado, .emConserto:
            return .blue
        case .finalizado, .entregue:
            return .green
        }
    }
    
    public var icone: String {
        switch self {
        case .aguardandoAvaliacao, .emOrcamento, .aguardandoAprovacao:
            return "hourglass"
        case .aprovado, .emConserto:
            return "arrow.clockwise"
        case .finalizado, .entregue:
            return "checkmark.circle"
        }
    }
}
