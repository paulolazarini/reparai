//
//  AppCoordinator.swift
//  Repar.ai
//
//  Created by Paulo Lazarini on 12/09/25.
//

import UIKit
import SwiftUI
import Combine
import NetworkCore

enum NavigationEvents {
    case novaOrdemDeServico
    case detalhesOrdemDeServico(String)
    case novaPeca
    case editarPeca(PecaEstoque)
    case novoCliente
    case editarCliente(Cliente)
    case novoTecnico
    case editarTecnico(Tecnico)
}

@MainActor
final class AppCoordinator: NSObject, @preconcurrency Coordinator {
    weak var navigationController: UINavigationController?
    let tabBarController: UITabBarController
    
    private let navigationEvents = PassthroughSubject<NavigationEvents, Never>()
    private let networkManager: NetworkManagerProtocol = FirebaseNetworkManager()
    private var cancelSet = Set<AnyCancellable>()
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.tabBarController = UITabBarController()
        super.init()
        
        self.setupBinding()
    }
    
    private func setupBinding() {
        navigationEvents
            .sink { [weak self] event in
                switch event {
                case .novaOrdemDeServico:
                    self?.presentNovaOrdemDeServico()
                case let .detalhesOrdemDeServico(ordemDeServicoId):
                    self?.presentDetalhesOrdemDeServico(for: ordemDeServicoId)
                case .novaPeca:
                    self?.presentNovaPecaEstoque()
                case let .editarPeca(peca):
                    self?.presentEditarPecaEstoque(peca)
                case .novoCliente:
                    self?.presentNovoCliente()
                case let .editarCliente(cliente):
                    self?.presentEditarCliente(cliente)
                case .novoTecnico:
                    self?.presentNovoTecnico()
                case let .editarTecnico(tecnico):
                    self?.presentEditarTecnico(tecnico)
                }
            }.store(in: &cancelSet)
    }
    
    public func start() {
        tabBarController.viewControllers = [
            makeDashboardView(),
            makeOrdensView(),
            makeClientesView(),
            makeTecnicosView(),
            makeEstoqueView()
        ]
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.setViewControllers([tabBarController], animated: false)
    }
    
    private func makeDashboardView() -> UIViewController {
        let viewModel = DashboardViewModel(
            networkManager: networkManager,
            navigationEvents: navigationEvents
        )
        let view = DashboardView(viewModel: viewModel)
        let viewController = UIHostingController(rootView: view)
        viewController.tabBarItem = TabBarPage.dashboard.tabBarItem
        
        return viewController
    }
    
    private func makeOrdensView() -> UIViewController {
        let viewModel = OrdensDeServicoViewModel(
            networkManager: networkManager,
            navigationEvents: navigationEvents
        )
        let view = OrdensDeServicoView(viewModel: viewModel)
        let viewController = UIHostingController(rootView: view)
        viewController.tabBarItem = TabBarPage.ordens.tabBarItem
        
        return viewController
    }
    
    private func makeClientesView() -> UIViewController {
        let viewModel = ClientesViewModel(
            networkManager: networkManager,
            navigationEvents: navigationEvents
        )
        let view = ClientesView(viewModel: viewModel)
        let viewController = UIHostingController(rootView: view)
        viewController.tabBarItem = TabBarPage.clientes.tabBarItem
        
        return viewController
    }
    
    private func makeTecnicosView() -> UIViewController {
        let viewModel = TecnicosViewModel(
            networkManager: networkManager,
            navigationEvents: navigationEvents
        )
        let view = TecnicosView(viewModel: viewModel)
        let viewController = UIHostingController(rootView: view)
        viewController.tabBarItem = TabBarPage.tecnicos.tabBarItem
        
        return viewController
    }
    
    private func makeEstoqueView() -> UIViewController {
        let viewModel = EstoqueViewModel(
            networkManager: networkManager,
            navigationEvents: navigationEvents
        )
        let view = EstoqueView(viewModel: viewModel)
        let viewController = UIHostingController(rootView: view)
        viewController.tabBarItem = TabBarPage.estoque.tabBarItem
        
        return viewController
    }
    
    private func presentNovaOrdemDeServico() {
        let viewModel = NovaOrdemDeServicoViewModel(networkManager: networkManager)
        let view = NovaOrdemDeServicoView(viewModel: viewModel) { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        
        push(view)
    }
    
    private func presentDetalhesOrdemDeServico(for id: String) {
        let viewModel = OrdemDeServicoDetalhesViewModel(
            ordemDeServicoID: id,
            networkManager: networkManager
        )
        let view = OrdemDeServicoDetalhesView(viewModel: viewModel)
        
        push(view)
    }
    
    private func presentNovaPecaEstoque() {
        let viewModel = NovaPecaViewModel(networkManager: networkManager)
        let view = NovaPecaView(viewModel: viewModel)
        
        push(view)
    }
    
    private func presentEditarPecaEstoque(_ pecaEstoque: PecaEstoque) {
        let viewModel = EditarPecaViewModel(
            peca: pecaEstoque,
            networkManager: networkManager
        )
        let view = EditarPecaView(viewModel: viewModel)
        
        push(view)
    }
    
    private func presentNovoCliente() {
        let viewModel = ClienteFormViewModel(networkManager: networkManager)
        let view = ClienteFormView(viewModel: viewModel)
        
        push(view)
    }
    
    private func presentEditarCliente(_ cliente: Cliente) {
        let viewModel = ClienteFormViewModel(
            cliente: cliente,
            networkManager: networkManager
        )
        let view = ClienteFormView(viewModel: viewModel)
        
        push(view)
    }

    private func presentNovoTecnico() {
        let viewModel = TecnicoFormViewModel(networkManager: networkManager)
        let view = TecnicoFormView(viewModel: viewModel)
        
        push(view)
    }
    
    private func presentEditarTecnico(_ tecnico: Tecnico) {
        let viewModel = TecnicoFormViewModel(
            tecnico: tecnico,
            networkManager: networkManager
        )
        let view = TecnicoFormView(viewModel: viewModel)
        
        push(view)
    }
}

protocol Coordinator: AnyObject {
    var navigationController: UINavigationController? { get set }
    func start()
}

extension Coordinator {
    func dismiss() {
        navigationController?.dismiss(animated: true)
    }
    
    func popVC() {
        navigationController?.popViewController(animated: true)
    }
    
    func present(
        _ view: some View,
        animated: Bool = true,
        presentationStyle: UIModalPresentationStyle = .pageSheet
    ) {
        let viewController = UIHostingController(rootView: view)
        viewController.modalPresentationStyle = presentationStyle
        
        navigationController?.present(viewController, animated: animated)
    }
    
    func push(
        _ view: some View,
        animated: Bool = true
    ) {
        let viewController = UIHostingController(rootView: view)
        
        navigationController?.pushViewController(viewController, animated: animated)
    }
}
