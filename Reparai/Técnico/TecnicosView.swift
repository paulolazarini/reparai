//
//  TecnicosView.swift
//  Repar.ai
//
//  Created by Paulo Lazarini on 14/09/25.
//

import SwiftUI

struct TecnicosView: View {
    
    @ObservedObject var viewModel: TecnicosViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    List {
                        ForEach(viewModel.tecnicosFiltrados) { tecnico in
                            TecnicoRowView(tecnico: tecnico)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    viewModel.navigate(to: .editarTecnico(tecnico))
                                }
                        }
                        .onDelete(perform: viewModel.deleteTecnico)
                    }
                    .listStyle(.plain)
                }
            }
            .searchable(text: $viewModel.textoBusca, prompt: "Buscar por nome ou especialidade")
            .navigationTitle("Técnicos")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.navigate(to: .novoTecnico)
                    } label: {
                        Image(systemName: "plus.circle")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundStyle(.gray)
                            .bold()
                    }
                }
            }
            .task {
                await viewModel.fetchTecnicos()
            }
        }
    }
}

struct TecnicoRowView: View {
    let tecnico: Tecnico
    
    var body: some View {
        HStack {
            Circle()
                .fill(tecnico.ativo ? Color.green : Color.gray)
                .frame(width: 10, height: 10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(tecnico.nomeCompleto)
                    .font(.headline)
                Text(tecnico.especialidade ?? "Sem especialidade")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray.opacity(0.5))
        }
        .padding(.vertical, 8)
    }
}
