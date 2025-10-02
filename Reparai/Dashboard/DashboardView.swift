//
//  DashboardView.swift
//  Repar.ai
//
//  Created by Paulo Lazarini on 12/09/25.
//

import SwiftUI
import Combine
import NetworkCore

struct DashboardView: View {
    @ObservedObject var viewModel: DashboardViewModel
    
    let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        LazyVGrid(columns: columns, spacing: 8) {
                            MetricCardView(title: "Total OS no Mês", value: "\(viewModel.totalOSMes)")
                            MetricCardView(title: "Aguardando Aceite", value: "\(viewModel.aguardandoAprovacaoCount)")
                            MetricCardView(title: "OS em Andamento", value: "\(viewModel.emAndamentoCount)")
                            MetricCardView(title: "Faturamento Mensal", value: viewModel.faturamentoMensal.formatted(.currency(code: "BRL")))
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Atividade Recente")
                                .font(.title2).bold()
                            
                            ForEach(viewModel.atividadesRecentes) { os in
                                AtividadeRecenteRowView(
                                    ordemDeServico: os,
                                    fetchCliente: viewModel.fetchCliente
                                )
                                .onTapGesture {
                                    viewModel.navigate(
                                        to: .detalhesOrdemDeServico(os.id)
                                    )
                                }
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Top 5 Peças Mais Usadas (Últimos 30 dias)")
                                .font(.title2).bold()
                            
                            VStack {
                                ForEach(viewModel.topPecas) { peca in
                                    TopPecaBarView(
                                        peca: peca,
                                        valorMaximo: viewModel.topPecas.map { $0.quantidade }.max() ?? 1
                                    )
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Top 5 Clientes")
                                .font(.title2).bold()
                            
                            VStack {
                                ForEach(viewModel.topClientes) { cliente in
                                    TopClienteRowView(cliente: cliente)
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Top 5 Técnicos")
                                .font(.title2).bold()
                            
                            VStack {
                                ForEach(viewModel.topTecnicos) { tecnico in
                                    TopTecnicoRowView(tecnico: tecnico)
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                        }
                        
                    }
                    .padding()
                }
            }
            .navigationTitle("Dashboard")
            .onAppear {
                Task {
                    await viewModel.fetchData()
                }
            }
            .opacity(viewModel.isLoading ? 0 : 1)
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                }
            }
        }
    }
}

struct MetricCardView: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
        }
        .padding()
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .topLeading
        )
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct AtividadeRecenteRowView: View {
    @State private var cliente: Cliente?
    
    let ordemDeServico: OrdemDeServico
    
    @MainActor let fetchCliente: (String) async -> Cliente?
    
    var body: some View {
        HStack(spacing: 16) {
            VStack {
                Image(systemName: ordemDeServico.status.icone)
                    .font(.title3)
                    .foregroundColor(ordemDeServico.status.cor)
            }
            .frame(width: 50, height: 50)
            .background(ordemDeServico.status.cor.opacity(0.15))
            .cornerRadius(10)
            
            VStack(alignment: .leading) {
                Text("OS #\(ordemDeServico.id.prefix(8))")
                    .font(.headline)
                
                if let cliente {
                    Text("Cliente: \(cliente.nomeCompleto)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } else {
                    ProgressView()
                }
                
                Text("Dispositivo: \(ordemDeServico.marcaModelo)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(ordemDeServico.status.rawValue)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(ordemDeServico.dataEntrada.timeAgoDisplay())
                .font(.footnote)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .task {
            cliente = await fetchCliente(ordemDeServico.clienteId)
        }
    }
}

struct TopPecaBarView: View {
    let peca: TopPecaReport
    let valorMaximo: Int
    
    var body: some View {
        HStack {
            Text(peca.nomePeca)
                .font(.subheadline)
                .frame(width: 80, alignment: .leading)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.2))
                    
                    Capsule()
                        .fill(Color.blue)
                        .frame(width: geometry.size.width * CGFloat(peca.quantidade) / CGFloat(valorMaximo))
                }
            }
            .frame(height: 12)
            
            Text("\(peca.quantidade)")
                .font(.headline)
                .frame(width: 40, alignment: .trailing)
        }
        .padding(.vertical, 4)
    }
}

struct TopClienteRowView: View {
    let cliente: TopClienteReport
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(cliente.nomeCliente ?? "Sem nome")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text("\(cliente.quantidadeOs) OS")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text(cliente.totalGasto.formatted(.currency(code: "BRL")))
                .font(.headline)
        }
        .padding(.vertical, 4)
    }
}

struct TopTecnicoRowView: View {
    let tecnico: TopTecnicoReport
    
    var body: some View {
        HStack {
            Text(tecnico.nomeTecnico ?? "Sem nome")
                .font(.subheadline)
                .fontWeight(.semibold)
            Spacer()
            Text("\(tecnico.quantidadeServicos) serviços")
                .font(.headline)
        }
        .padding(.vertical, 4)
    }
}

extension Date {
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}

#Preview {
    NavigationStack {
        DashboardView(
            viewModel: .init(
                networkManager: MockNetworkManager(),
                navigationEvents: PassthroughSubject<NavigationEvents,
                Never>()
            )
        )
    }
}

