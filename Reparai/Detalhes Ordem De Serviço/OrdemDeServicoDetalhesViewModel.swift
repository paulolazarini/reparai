//
//  OrdemDeServicoDetalhesViewModel.swift
//  Repar.ai
//
//  Created by Paulo Lazarini on 13/09/25.
//

import SwiftUI
import Combine

@MainActor
class OrdemDeServicoDetalhesViewModel: ObservableObject {
    
    @Published var ordemDeServico: OrdemDeServico?
    @Published var cliente: Cliente?
    @Published var orcamentoItens: [OrcamentoItem] = []
    @Published var tecnicosDisponiveis: [Tecnico] = []
    
    @Published var tipoEquipamento: TipoEquipamento = .celular
    @Published var marcaModelo: String = ""
    @Published var numeroSerie: String = ""
    @Published var defeitoRelatado: String = ""
    
    @Published var diagnosticoTecnico: String = ""
    @Published var statusSelecionado: StatusOrdemDeServico = .aguardandoAvaliacao
    @Published var tecnicoSelecionadoId: String?
    @Published var valorMaoDeObraString: String = "0"
    
    @Published var buscaPecaTexto: String = ""
    @Published var resultadosBuscaPeca: [PecaEstoque] = []
    @Published var buscaClienteTexto: String = ""
    @Published var resultadosBuscaCliente: [Cliente] = []
    
    @Published var isLoading = false
    @Published var isSaving = false
    
    private var osOriginal: OrdemDeServico?
    private let networkManager: NetworkManagerProtocol
    private let ordemDeServicoID: String
    private var cancellables = Set<AnyCancellable>()
    
    var subtotalPecas: Decimal {
        orcamentoItens.reduce(0) { $0 + ($1.valorUnitario * Decimal($1.quantidade)) }
    }
    
    var valorTotalCalculado: Decimal {
        let valorMaoDeObra = Decimal(string: valorMaoDeObraString.replacingOccurrences(of: ",", with: ".")) ?? 0
        return subtotalPecas + valorMaoDeObra
    }
    
    var temAlteracoes: Bool {
        guard let original = osOriginal else { return false }
        let valorMaoDeObraAtual = Decimal(string: valorMaoDeObraString.replacingOccurrences(of: ",", with: ".")) ?? 0
        
        return tipoEquipamento.rawValue != original.tipoEquipamento ||
               marcaModelo != original.marcaModelo ||
               numeroSerie != (original.numeroSerie ?? "") ||
               defeitoRelatado != original.defeitoRelatado ||
               statusSelecionado != original.status ||
               diagnosticoTecnico != (original.diagnosticoTecnico ?? "") ||
               tecnicoSelecionadoId != original.tecnicoId ||
               valorMaoDeObraAtual != (original.valorMaoDeObra ?? 0) ||
               cliente?.id != original.clienteId
    }
    
    init(ordemDeServicoID: String, networkManager: NetworkManagerProtocol) {
        self.ordemDeServicoID = ordemDeServicoID
        self.networkManager = networkManager
        setupBindings()
    }
    
    private func setupBindings() {
        $buscaPecaTexto
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            .sink { [weak self] query in self?.pesquisarPecas(query: query) }
            .store(in: &cancellables)
        
        $buscaPecaTexto
            .filter { $0.isEmpty }
            .sink { [weak self] _ in self?.resultadosBuscaPeca = [] }
            .store(in: &cancellables)
            
        $buscaClienteTexto
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .filter { [weak self] query in
                return !query.isEmpty && query != self?.cliente?.nomeCompleto
            }
            .sink { [weak self] query in
                self?.pesquisarClientes(query: query)
            }
            .store(in: &cancellables)
            
        $buscaClienteTexto
            .filter { $0.isEmpty }
            .sink { [weak self] _ in
                self?.resultadosBuscaCliente = []
            }
            .store(in: &cancellables)
    }
    
    func fetchDetalhes() async {
        isLoading = true
        
        async let osResult = networkManager.fetchOrdemDeServico(id: ordemDeServicoID)
        async let itensResult = networkManager.fetchItens(paraOrdemDeServicoId: ordemDeServicoID)
        async let tecnicosResult = networkManager.fetchAllTecnicos()
        
        let (os, itens, tecnicos) = await (osResult, itensResult, tecnicosResult)
        
        if case .success(let fetchedOS) = os {
            self.ordemDeServico = fetchedOS
            self.osOriginal = fetchedOS
            
            self.tipoEquipamento = TipoEquipamento(rawValue: fetchedOS.tipoEquipamento) ?? .outro
            self.marcaModelo = fetchedOS.marcaModelo
            self.numeroSerie = fetchedOS.numeroSerie ?? ""
            self.defeitoRelatado = fetchedOS.defeitoRelatado
            self.diagnosticoTecnico = fetchedOS.diagnosticoTecnico ?? ""
            self.statusSelecionado = fetchedOS.status
            self.tecnicoSelecionadoId = fetchedOS.tecnicoId
            self.valorMaoDeObraString = (fetchedOS.valorMaoDeObra ?? 0).formatted(.number.locale(Locale(identifier: "pt_BR")))
            
            if case .success(let fetchedCliente) = await networkManager.fetchCliente(byId: fetchedOS.clienteId) {
                self.cliente = fetchedCliente
                self.buscaClienteTexto = fetchedCliente.nomeCompleto
            }
        }
        
        if case .success(let fetchedItens) = itens { self.orcamentoItens = fetchedItens }
        if case .success(let fetchedTecnicos) = tecnicos { self.tecnicosDisponiveis = fetchedTecnicos }
        
        isLoading = false
    }
    
    func salvarAlteracoes() async {
        guard var osParaAtualizar = ordemDeServico, let clienteAtual = cliente, temAlteracoes else { return }
        
        isSaving = true
        
        osParaAtualizar.clienteId = clienteAtual.id
        osParaAtualizar.tipoEquipamento = tipoEquipamento.rawValue
        osParaAtualizar.marcaModelo = marcaModelo
        osParaAtualizar.numeroSerie = numeroSerie
        osParaAtualizar.defeitoRelatado = defeitoRelatado
        osParaAtualizar.status = statusSelecionado
        osParaAtualizar.tecnicoId = tecnicoSelecionadoId
        osParaAtualizar.diagnosticoTecnico = diagnosticoTecnico
        osParaAtualizar.valorMaoDeObra = Decimal(string: valorMaoDeObraString.replacingOccurrences(of: ",", with: ".")) ?? 0
        osParaAtualizar.valorTotal = valorTotalCalculado
        
        if case .success = await networkManager.updateOrdemDeServico(osParaAtualizar) {
            self.ordemDeServico = osParaAtualizar
            self.osOriginal = osParaAtualizar
        }
        isSaving = false
    }
    
    private func pesquisarPecas(query: String) {
        Task {
            if case .success(let pecas) = await networkManager.searchPecas(query: query) { self.resultadosBuscaPeca = pecas }
        }
    }
    
    private func pesquisarClientes(query: String) {
        Task {
            if case .success(let clientes) = await networkManager.searchClientes(query: query) {
                self.resultadosBuscaCliente = clientes.filter { $0.id != self.cliente?.id }
            }
        }
    }
    
    func selecionarCliente(_ novoCliente: Cliente) {
        self.cliente = novoCliente
        self.buscaClienteTexto = novoCliente.nomeCompleto
        self.resultadosBuscaCliente = []
    }

    func limparBuscaCliente() {
        guard let clienteOriginal = self.cliente else { return }
        self.buscaClienteTexto = clienteOriginal.nomeCompleto
        self.resultadosBuscaCliente = []
    }
    
    func adicionarPecaAoOrcamento(_ peca: PecaEstoque) {
        guard let osId = ordemDeServico?.id, peca.quantidadeDisponivel > 0 else { return }
        
        Task {
            if let itemExistente = orcamentoItens.first(where: { $0.pecaId == peca.id }) {
                await atualizarQuantidadeItem(item: itemExistente, novaQuantidade: itemExistente.quantidade + 1)
            } else {
                let novoItem = OrcamentoItem(id: UUID().uuidString, ordemServicoId: osId, pecaId: peca.id, descricaoServico: peca.nomePeca, quantidade: 1, valorUnitario: peca.precoVenda)
                if case .success = await networkManager.addItem(novoItem, paraOrdemDeServicoId: osId) {
                    await ajustarEstoque(pecaId: peca.id, quantidade: -1)
                }
            }
            buscaPecaTexto = ""
        }
    }
    
    func removerItemDoOrcamento(at offsets: IndexSet) {
        let itensParaRemover = offsets.map { orcamentoItens[$0] }
        Task {
            for item in itensParaRemover {
                if case .success = await networkManager.deleteItem(id: item.id), let pecaId = item.pecaId {
                    await ajustarEstoque(pecaId: pecaId, quantidade: item.quantidade)
                }
            }
        }
    }
    
    func removerClienteParaTroca() {
        self.cliente = nil
        self.buscaClienteTexto = ""
        self.resultadosBuscaCliente = []
    }

    func removerItemEspecifico(_ item: OrcamentoItem) {
        guard let index = orcamentoItens.firstIndex(where: { $0.id == item.id }) else { return }
        removerItemDoOrcamento(at: IndexSet(integer: index))
    }

    func atualizarQuantidadeItem(item: OrcamentoItem, novaQuantidade: Int) async {
        guard let pecaId = item.pecaId, novaQuantidade >= 0 else { return }
        let diferenca = novaQuantidade - item.quantidade
        
        guard diferenca != 0 else { return }
        
        if novaQuantidade == 0 {
            removerItemEspecifico(item)
            return
        }
        
        var itemAtualizado = item
        itemAtualizado.quantidade = novaQuantidade
        
        if case .success = await networkManager.updateItem(itemAtualizado) {
            await ajustarEstoque(pecaId: pecaId, quantidade: -diferenca)
        }
    }
    
    private func ajustarEstoque(pecaId: String, quantidade: Int) async {
        if case .success(var peca) = await networkManager.fetchPeca(byId: pecaId) {
            peca.quantidadeDisponivel += quantidade
            _ = await networkManager.updatePeca(peca)
        }
        await fetchItensOrcamento()
    }

    func fetchItensOrcamento() async {
        if case .success(let fetchedItens) = await networkManager.fetchItens(paraOrdemDeServicoId: ordemDeServicoID) {
            self.orcamentoItens = fetchedItens
        }
    }
}
