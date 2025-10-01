//
//  NovaPecaViewModel.swift
//  Repar.ai
//
//  Created by Paulo Lazarini on 13/09/25.
//

import SwiftUI
import Combine
import NetworkCore

@MainActor
class NovaPecaViewModel: ObservableObject {
    @Published var nomePeca: String = ""
    @Published var fabricante: String = ""
    @Published var descricao: String = ""
    @Published var quantidadeInicial: String = ""
    @Published var precoCusto: String = ""
    @Published var precoVenda: String = ""
    
    @Published var isSaving = false
    @Published var podeSalvar = false
    
    private let networkManager: NetworkManagerProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
        setupValidation()
    }
    
    private func setupValidation() {
        Publishers.CombineLatest4($nomePeca, $quantidadeInicial, $precoCusto, $precoVenda)
            .map { nome, qtd, custo, venda in
                return !nome.isEmpty &&
                Int(qtd) != nil &&
                Decimal(string: custo) != nil &&
                Decimal(string: venda) != nil
            }
            .assign(to: &$podeSalvar)
    }
    
    func salvarPeca() async -> Bool {
        guard let quantidade = Int(quantidadeInicial),
              let custo = Decimal(string: precoCusto.replacingOccurrences(of: ",", with: ".")),
              let venda = Decimal(string: precoVenda.replacingOccurrences(of: ",", with: "."))
        else {
            return false
        }
        
        isSaving = true
        
        let novaPecaRequest = CreatePecaRequest(
            nomePeca: nomePeca,
            fabricante: fabricante.isEmpty ? nil : fabricante,
            descricao: descricao.isEmpty ? nil : descricao,
            quantidadeDisponivel: quantidade,
            precoCusto: custo,
            precoVenda: venda
        )
        
        let resultado = await networkManager.createPeca(novaPecaRequest)
        isSaving = false
        
        switch resultado {
        case .success:
            return true
        case .failure(let error):
            print("❌ Falha ao criar peça: \(error.localizedDescription)")
            return false
        }
    }
}
