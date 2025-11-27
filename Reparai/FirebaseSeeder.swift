//
//  FirebaseSeeder.swift
//  Repar.ai
//
//  Created by Paulo Lazarini on 23/11/25.
//

import Foundation
import FirebaseFirestore

class FirebaseSeeder {
    
    private let db = Firestore.firestore()
    
    func seedDatabase() async throws {
        print("🌱 Iniciando Seed do Banco de Dados (Modo Compatível)...")
        
        // 1. Criar Clientes
        let cliente1 = Cliente(
            id: "seed_cliente_01",
            nomeCompleto: "Maria da Silva",
            telefone: "11999999999",
            email: "maria@email.com",
            cpf: "123.456.789-00",
            dataCriacao: Date().ISO8601Format()
        )
        
        let cliente2 = Cliente(
            id: "seed_cliente_02",
            nomeCompleto: "João Souza",
            telefone: "11988888888",
            email: "joao@email.com",
            cpf: "987.654.321-00",
            dataCriacao: Date().ISO8601Format()
        )
        
        // Usamos asDictionary() para garantir que o formato no banco seja idêntico ao que o App cria
        try await db.collection("clientes").document(cliente1.id).setData(cliente1.asDictionary())
        try await db.collection("clientes").document(cliente2.id).setData(cliente2.asDictionary())
        print("✅ Clientes criados.")
        
        // 2. Criar Técnicos
        let tecnico1 = Tecnico(
            id: "seed_tecnico_01",
            nomeCompleto: "Carlos Técnico",
            especialidade: "Hardware Apple",
            dataAdmissao: Date(),
            ativo: true
        )
        
        try await db.collection("tecnicos").document(tecnico1.id).setData(tecnico1.asDictionary())
        print("✅ Técnicos criados.")
        
        // 3. Criar Peças
        let peca1 = PecaEstoque(
            id: "seed_peca_01",
            nomePeca: "Tela iPhone 13 Original",
            descricao: "Tela OLED genuína",
            fabricante: "Apple",
            quantidadeDisponivel: 10,
            precoCusto: 500.00,
            precoVenda: 1200.00
        )
        
        let peca2 = PecaEstoque(
            id: "seed_peca_02",
            nomePeca: "Bateria Samsung S20",
            descricao: "Bateria Li-ion",
            fabricante: "Samsung",
            quantidadeDisponivel: 5,
            precoCusto: 100.00,
            precoVenda: 250.00
        )
        
        try await db.collection("pecas").document(peca1.id).setData(peca1.asDictionary())
        try await db.collection("pecas").document(peca2.id).setData(peca2.asDictionary())
        print("✅ Peças criadas.")
        
        // 4. Criar Ordens de Serviço
        let os1 = OrdemDeServico(
            id: "seed_os_01",
            clienteId: "seed_cliente_01",
            tecnicoId: "seed_tecnico_01",
            tipoEquipamento: "Smartphone",
            marcaModelo: "iPhone 13",
            numeroSerie: "SERIE123456",
            defeitoRelatado: "Tela Quebrada",
            diagnosticoTecnico: "Necessária troca do display frontal",
            status: .emConserto,
            dataEntrada: Date(),
            valorMaoDeObra: 200.00,
            valorTotal: 1400.00
        )
        
        let os2 = OrdemDeServico(
            id: "seed_os_02",
            clienteId: "seed_cliente_02",
            tecnicoId: nil,
            tipoEquipamento: "Notebook",
            marcaModelo: "Dell Inspiron",
            numeroSerie: "DELL123",
            defeitoRelatado: "Não liga",
            diagnosticoTecnico: nil,
            status: .aguardandoAvaliacao,
            dataEntrada: Date()
        )
        
        try await db.collection("ordens_servico").document(os1.id).setData(os1.asDictionary())
        try await db.collection("ordens_servico").document(os2.id).setData(os2.asDictionary())
        print("✅ OSs criadas.")
        
        // 5. Criar Itens de Orçamento
        let item1 = OrcamentoItem(
            id: "seed_item_01",
            ordemServicoId: "seed_os_01",
            pecaId: "seed_peca_01",
            descricaoServico: "Troca de Display",
            quantidade: 1,
            valorUnitario: 1200.00
        )
        
        try await db.collection("orcamento_itens").document(item1.id).setData(item1.asDictionary())
        print("✅ Itens criados.")
        
        print("🚀 SEED FINALIZADO COM SUCESSO! 🚀")
    }
}
