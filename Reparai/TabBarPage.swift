//
//  TabBarPage.swift
//  Repar.ai
//
//  Created by Paulo Lazarini on 12/09/25.
//

import UIKit

enum TabBarPage: Int, CaseIterable {
    case dashboard = 0
    case ordens = 1
    case clientes = 2
    case estoque = 3
    case tecnicos = 4
    
    var title: String {
        switch self {
        case .dashboard:
            "Dashboard"
        case .ordens:
            "Ordens"
        case .clientes:
            "Clientes"
        case .estoque:
            "Estoque"
        case .tecnicos:
            "Técnicos"
        }
    }
    
    var image: UIImage? {
        switch self {
        case .dashboard:
            UIImage(systemName: "square.grid.2x2")
        case .ordens:
            UIImage(systemName: "text.document")
        case .clientes:
            UIImage(systemName: "person.2")
        case .estoque:
            UIImage(systemName: "archivebox")
        case .tecnicos:
            UIImage(systemName: "person.badge.shield.checkmark")
        }
    }

    var selectedImage: UIImage? {
        switch self {
        case .dashboard:
            UIImage(systemName: "square.grid.2x2.fill")
        case .ordens:
            UIImage(systemName: "text.document.fill")
        case .clientes:
            UIImage(systemName: "person.2.fill")
        case .estoque:
            UIImage(systemName: "archivebox.fill")
        case .tecnicos:
            UIImage(systemName: "person.badge.shield.checkmark.fill")
        }
    }
    
    var tabBarItem: UITabBarItem {
        UITabBarItem(title: self.title, image: self.image, selectedImage: self.selectedImage)
    }
}
