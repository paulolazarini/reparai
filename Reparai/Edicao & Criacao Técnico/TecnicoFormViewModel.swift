//
//  TecnicoFormViewModel.swift
//  Repar.ai
//
//  Created by Paulo Lazarini on 14/09/25.
//

import SwiftUI

@MainActor
final class TecnicoFormViewModel: ObservableObject {
    
    @Published var nomeCompleto: String
    @Published var especialidade: String
    @Published var dataAdmissao: Date
    @Published var ativo: Bool
    
    @Published var isSaving = false
    @Published var podeSalvar = false
    
    private var tecnico: Tecnico?
    let networkManager: NetworkManagerProtocol
    
    var navigationTitle: String {
        tecnico == nil ? "Novo Técnico" : "Editar Técnico"
    }
    
    init(tecnico: Tecnico? = nil, networkManager: NetworkManagerProtocol) {
        self.tecnico = tecnico
        self.networkManager = networkManager
        
        _nomeCompleto = Published(initialValue: tecnico?.nomeCompleto ?? "")
        _especialidade = Published(initialValue: tecnico?.especialidade ?? "")
        _dataAdmissao = Published(initialValue: tecnico?.dataAdmissao ?? Date())
        _ativo = Published(initialValue: tecnico?.ativo ?? true)
        
        setupValidation()
    }
    
    private func setupValidation() {
        $nomeCompleto
            .map { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            .assign(to: &$podeSalvar)
    }
    
    func save() async -> Bool {
        guard podeSalvar else { return false }
        
        isSaving = true
        let resultado: Result<Void, RequestError>
        
        if var tecnicoParaAtualizar = self.tecnico {
            tecnicoParaAtualizar.nomeCompleto = nomeCompleto
            tecnicoParaAtualizar.especialidade = especialidade.isEmpty ? nil : especialidade
            tecnicoParaAtualizar.dataAdmissao = dataAdmissao
            tecnicoParaAtualizar.ativo = ativo
            resultado = await networkManager.updateTecnico(tecnicoParaAtualizar)
        } else {
            let novoTecnicoRequest = CreateTecnicoRequest(
                nomeCompleto: nomeCompleto,
                especialidade: especialidade.isEmpty ? nil : especialidade,
                dataAdmissao: dataAdmissao,
                ativo: ativo
            )
            resultado = await networkManager.createTecnico(novoTecnicoRequest)
        }
        
        isSaving = false
        
        switch resultado {
        case .success:
            return true
        case .failure(let error):
            print("❌ Falha ao salvar técnico: \(error.localizedDescription)")
            return false
        }
    }
}
