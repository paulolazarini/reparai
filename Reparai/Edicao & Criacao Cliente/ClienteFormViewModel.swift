//
//  ClienteFormViewModel.swift
//  Repar.ai
//
//  Created by Paulo Lazarini on 13/09/25.
//

import SwiftUI
import Combine
import NetworkCore

@MainActor
class ClienteFormViewModel: ObservableObject {
    
    @Published var nomeCompleto: String
    @Published var telefone: String
    @Published var email: String
    @Published var cpf: String
    
    @Published var isSaving = false
    @Published var podeSalvar = false
    
    private var cliente: Cliente?
    private let networkManager: NetworkManagerProtocol
    
    var navigationTitle: String {
        cliente == nil ? "Novo Cliente" : "Editar Cliente"
    }
    
    init(cliente: Cliente? = nil, networkManager: NetworkManagerProtocol) {
        self.cliente = cliente
        self.networkManager = networkManager
        
        _nomeCompleto = Published(initialValue: cliente?.nomeCompleto ?? "")
        _telefone = Published(initialValue: cliente?.telefone ?? "")
        _email = Published(initialValue: cliente?.email ?? "")
        _cpf = Published(initialValue: cliente?.cpf ?? "")
        
        setupValidation()
    }
    
    private func setupValidation() {
        Publishers.CombineLatest($nomeCompleto, $telefone)
            .map { nome, tel in
                !nome.trimmingCharacters(in: .whitespaces).isEmpty &&
                !tel.trimmingCharacters(in: .whitespaces).isEmpty
            }
            .assign(to: &$podeSalvar)
    }
    
    func save() async -> Bool {
        isSaving = true
        let resultado: Result<Void, RequestError>
        
        if var clienteParaAtualizar = self.cliente {
            clienteParaAtualizar.nomeCompleto = nomeCompleto
            clienteParaAtualizar.telefone = telefone
            clienteParaAtualizar.email = email.isEmpty ? nil : email
            clienteParaAtualizar.cpf = cpf.isEmpty ? nil : cpf
            resultado = await networkManager.updateCliente(clienteParaAtualizar)
        } else {
            let novoClienteRequest = CreateClienteRequest(
                nomeCompleto: nomeCompleto,
                telefone: telefone,
                email: email.isEmpty ? nil : email,
                cpf: cpf.isEmpty ? nil : cpf,
                dataCriacao: Date()
            )
            let createResult = await networkManager.createCliente(novoClienteRequest)
            resultado = createResult.map { _ in () }
        }
        
        isSaving = false
        
        switch resultado {
        case .success:
            return true
        case .failure(let error):
            print("❌ Falha ao salvar cliente: \(error.localizedDescription)")
            return false
        }
    }
}
