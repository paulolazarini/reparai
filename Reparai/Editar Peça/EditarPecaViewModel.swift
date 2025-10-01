//
//  EditarPecaViewModel.swift
//  Repar.ai
//
//  Created by Paulo Lazarini on 13/09/25.
//


import SwiftUI
import NetworkCore
import Combine

@MainActor
class EditarPecaViewModel: ObservableObject {
    @Published var nomePeca: String
    @Published var fabricante: String
    @Published var descricao: String
    @Published var quantidadeDisponivel: String
    @Published var precoCusto: String
    @Published var precoVenda: String
    
    @Published var isSaving = false
    @Published var podeSalvar = false
    
    private let pecaOriginal: PecaEstoque
    private let networkManager: NetworkManagerProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(peca: PecaEstoque, networkManager: NetworkManagerProtocol) {
        self.pecaOriginal = peca
        self.networkManager = networkManager
        
        _nomePeca = Published(initialValue: peca.nomePeca)
        _fabricante = Published(initialValue: peca.fabricante ?? "")
        _descricao = Published(initialValue: peca.descricao ?? "")
        _quantidadeDisponivel = Published(initialValue: String(peca.quantidadeDisponivel))
        _precoCusto = Published(initialValue: String(describing: peca.precoCusto))
        _precoVenda = Published(initialValue: String(describing: peca.precoVenda))
        
        setupValidation()
    }
    
    private func setupValidation() {
        Publishers.CombineLatest4($nomePeca, $quantidadeDisponivel, $precoCusto, $precoVenda)
            .map { nome, qtd, custo, venda in
                return !nome.isEmpty &&
                       Int(qtd) != nil &&
                       Decimal(string: custo) != nil &&
                       Decimal(string: venda) != nil
            }
            .assign(to: &$podeSalvar)
    }
    
    func salvarAlteracoes() async -> Bool {
        guard let quantidade = Int(quantidadeDisponivel),
              let custo = Decimal(string: precoCusto.replacingOccurrences(of: ",", with: ".")),
              let venda = Decimal(string: precoVenda.replacingOccurrences(of: ",", with: "."))
        else {
            return false
        }
        
        isSaving = true
        
        var pecaAtualizada = pecaOriginal
        pecaAtualizada.nomePeca = nomePeca
        pecaAtualizada.fabricante = fabricante.isEmpty ? nil : fabricante
        pecaAtualizada.descricao = descricao.isEmpty ? nil : descricao
        pecaAtualizada.quantidadeDisponivel = quantidade
        pecaAtualizada.precoCusto = custo
        pecaAtualizada.precoVenda = venda
        
        let resultado = await networkManager.updatePeca(pecaAtualizada)
        isSaving = false
        
        switch resultado {
        case .success:
            return true
        case .failure(let error):
            print("❌ Falha ao atualizar peça: \(error.localizedDescription)")
            return false
        }
    }
}
