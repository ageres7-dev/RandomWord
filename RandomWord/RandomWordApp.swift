//
//  RandomWordApp.swift
//  RandomWord
//
//  Created by Sergey Dolgikh on 02.07.2022.
//

import SwiftUI

@main
struct RandomWordApp: App {
    @StateObject private var dataController = DataController()
    
    var body: some Scene {
        WindowGroup {
            StartTabView()
                .environment(\.managedObjectContext, dataController.container.viewContext )
        }
    }
}
