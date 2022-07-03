//
//  ContentView.swift
//  RandomWord
//
//  Created by Sergey Dolgikh on 02.07.2022.
//

import SwiftUI

struct StartTabView: View {
    var body: some View {
        TabView {
            RandomeView()
                .tabItem { Image(systemName: "dice") }
            SettingsView()
                .tabItem { Image(systemName: "gear") }
        }
    }
}

struct StartTabView_Previews: PreviewProvider {
    static var previews: some View {
        StartTabView()
    }
}
