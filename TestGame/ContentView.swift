//
//  ContentView.swift
//  TestGame
//
//  Created by Mario Vanegas on 22/3/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = ContentViewModel()
    
    var body: some View {
        VStack {
            Text("Friend's Message")
                .bold()
            Text(viewModel.friendsMessage)
            
            TextField("Write Here...", text: $viewModel.message)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Button("Send") {
                viewModel.sendMessage()
            }
        }
        .padding()
        .onAppear {
            viewModel.setup()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
