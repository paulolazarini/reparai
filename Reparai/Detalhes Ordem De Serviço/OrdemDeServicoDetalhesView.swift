//
//  OrdemDeServicoDetalhesView.swift
//  Repar.ai
//
//  Created by Paulo Lazarini on 13/09/25.
//

import SwiftUI
import NetworkCore

struct OrdemDeServicoDetalhesView: View {
    
    @ObservedObject var viewModel: OrdemDeServicoDetalhesViewModel
    @FocusState var isFocused
    @Environment(\.dismiss) private var dismiss
    
    var isShowingClienteList: Bool {
        !viewModel.resultadosBuscaCliente.isEmpty
        && viewModel.buscaClienteTexto != ""
        && isFocused
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()
                
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.ordemDeServico != nil {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            statusCard
                            detalhesEquipamentoCard()
                            diagnosticoTecnicoCard
                            orcamentoPecasCard
                        }
                        .padding()
                    }
                } else {
                    Text("Não foi possível carregar a Ordem de Serviço.")
                }
            }
            .navigationTitle(viewModel.ordemDeServico != nil ? "Ordem de Serviço #\(viewModel.ordemDeServico!.id)" : "")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundStyle(.gray)
                            .padding(8)
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    if viewModel.temAlteracoes {
                        Button("Salvar") {
                            Task {
                                await viewModel.salvarAlteracoes()
                            }
                        }
                        .disabled(viewModel.isSaving)
                    }
                }
            }
            .task {
                await viewModel.fetchDetalhes()
            }
        }
    }
    
    private var statusCard: some View {
        DetalhesCardView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Status").font(.headline)
                    Spacer()
                    Menu {
                        ForEach(StatusOrdemDeServico.allCases) { status in
                            Button(status.rawValue) { viewModel.statusSelecionado = status }
                        }
                    } label: {
                        StatusTagView(status: viewModel.statusSelecionado)
                    }
                }
                
                clienteSearchField
                
                HStack {
                    Image(systemName: "wrench.fill").font(.title).foregroundColor(.gray)
                    Picker("Técnico Responsável", selection: $viewModel.tecnicoSelecionadoId) {
                        Text("Nenhum").tag(String?.none)
                        ForEach(viewModel.tecnicosDisponiveis) { tecnico in
                            Text(tecnico.nomeCompleto).tag(tecnico.id as String?)
                        }
                    }
                    .pickerStyle(.wheel)
                }
                .frame(height: 100)
            }
        }
    }
    
    private var clienteSearchField: some View {
        VStack {
            HStack(spacing: 16) {
                Image(systemName: "person.fill").font(.title).foregroundColor(.gray)
                VStack(alignment: .leading) {
                    Text("Cliente")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Buscar cliente...", text: $viewModel.buscaClienteTexto)
                        .focused($isFocused)
                }
            }
            
            if !viewModel.resultadosBuscaCliente.isEmpty {
                List(viewModel.resultadosBuscaCliente) { cliente in
                    Button {
                        viewModel.selecionarCliente(cliente)
                    } label: {
                        Text(cliente.nomeCompleto)
                    }
                }
                .listStyle(.plain)
                .frame(maxHeight: 200)
                .background(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3)
                    )
                )
                .frame(height: isShowingClienteList ? 166 : 0)
                .animation(.bouncy, value: isShowingClienteList)
            }
        }
        .frame(height: isShowingClienteList ? 166 : 0)
        .animation(.bouncy, value: isShowingClienteList)
    }

    private func detalhesEquipamentoCard() -> some View {
        DetalhesCardView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Detalhes do Equipamento").font(.title3).bold()
                Picker("Equipamento", selection: $viewModel.tipoEquipamento) {
                    ForEach(TipoEquipamento.allCases) { Text($0.rawValue).tag($0) }
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Marca e Modelo").font(.caption).foregroundColor(.secondary)
                    TextField("Ex: Apple iPhone 15", text: $viewModel.marcaModelo)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Número de Série (Opcional)").font(.caption).foregroundColor(.secondary)
                    TextField("N/A", text: $viewModel.numeroSerie)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Problema Relatado").font(.caption).foregroundColor(.secondary)
                    TextEditor(text: $viewModel.defeitoRelatado).frame(minHeight: 80)
                }
            }
        }
    }
    
    private var diagnosticoTecnicoCard: some View {
        DetalhesCardView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Diagnóstico Técnico")
                    .font(.title3).bold()
                
                TextEditor(text: $viewModel.diagnosticoTecnico)
                    .frame(height: 100)
                    .padding(4)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
        }
    }
    
    private var orcamentoPecasCard: some View {
        DetalhesCardView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Orçamento e Peças")
                    .font(.title3).bold()
                
                TextField("Buscar Item/Peça...", text: $viewModel.buscaPecaTexto)
                    .textFieldStyle(.roundedBorder)
                
                if !viewModel.resultadosBuscaPeca.isEmpty {
                    List(viewModel.resultadosBuscaPeca) { peca in
                        Button {
                            viewModel.adicionarPecaAoOrcamento(peca)
                        } label: {
                            VStack(alignment: .leading) {
                                Text(peca.nomePeca)
                                    .foregroundColor(.primary)
                                Text("Disponível: \(peca.quantidadeDisponivel)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .listStyle(.plain)
                    .frame(height: 150)
                    .background(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3))
                    )
                    .zIndex(1)
                }
                
                Divider()
                
                if viewModel.orcamentoItens.isEmpty {
                    Text("Nenhum item adicionado ao orçamento.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } else {
                    ForEach(viewModel.orcamentoItens) { item in
                        OrcamentoItemRowView(item: item) { novaQuantidade in
                            Task {
                                await viewModel.atualizarQuantidadeItem(
                                    item: item,
                                    novaQuantidade: novaQuantidade
                                )
                            }
                        } onDelete: {
                            viewModel.removerItemEspecifico(item)
                        }
                    }
                }
                
                Divider()
                
                VStack(spacing: 10) {
                    HStack {
                        Text("Subtotal (Peças)")
                            .font(.subheadline)
                        Spacer()
                        Text(viewModel.subtotalPecas.formatted(.currency(code: "BRL")))
                            .font(.subheadline)
                    }
                    
                    HStack {
                        Text("Mão de Obra")
                            .font(.subheadline)
                        Spacer()
                        TextField("Valor", text: $viewModel.valorMaoDeObraString)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                            .frame(maxWidth: 100)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("VALOR TOTAL")
                            .font(.headline).bold()
                        Spacer()
                        Text(viewModel.valorTotalCalculado.formatted(.currency(code: "BRL")))
                            .font(.headline).bold()
                    }
                }
                .padding(.top, 8)
            }
        }
    }
}

struct DetalhesCardView<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            content
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct DetalheItemView: View {
    let titulo: String
    let valor: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(titulo)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(valor)
                .font(.subheadline.weight(.medium))
        }
    }
}

struct OrcamentoItemRowView: View {
    @State private var quantidade: Int
    let item: OrcamentoItem
    let onQuantityChange: (Int) -> Void
    let onDelete: () -> Void

    init(
        item: OrcamentoItem,
        onQuantityChange: @escaping (Int) -> Void,
        onDelete: @escaping () -> Void
    ) {
        self.item = item
        self._quantidade = State(initialValue: item.quantidade)
        self.onQuantityChange = onQuantityChange
        self.onDelete = onDelete
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(item.descricaoServico ?? "Item desconhecido")
                    .font(.headline)
                Text(item.valorUnitario.formatted(.currency(code: "BRL")) + " /unid.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Stepper(value: $quantidade, in: 1...100) {
                Text("Qtd: \(quantidade)")
            }
            .frame(width: 150)
            
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 8)
        .onChange(of: quantidade) { _, novaQuantidade in
            onQuantityChange(novaQuantidade)
        }
    }
}

#Preview {
    NavigationStack {
        OrdemDeServicoDetalhesView(
            viewModel: OrdemDeServicoDetalhesViewModel(
                ordemDeServicoID: "202501",
                networkManager: MockNetworkManager()
            )
        )
    }
}
