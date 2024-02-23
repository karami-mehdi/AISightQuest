//
//  MainframeView.swift
//  AISightQuest
//
//  Created by Mehdi Karami on 2/22/24.
//

import SwiftUI
import SwiftData

// MARK: - Mainframe View

struct MainframeView: View {
    @State private(set) var viewModel: ViewModel

    var body: some View {
        NavigationSplitView {
            List {
                ForEach($viewModel.sessions) { session in
                    NavigationLink {
                        // TODO: Route to Session View
                        Text(session.text.wrappedValue)
                    } label: {
                        SessionRow(session: session)
                    }
                }
                .onDelete { indexSet in
                    withAnimation {
                        viewModel.deleteSession(indexSet: indexSet)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                        .foregroundStyle(.darkBlue500)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.addSession(name: "New Session", lastChange: Date())
                    } label: {
                        HStack {
                            Image(systemName: "plus")
                            Text("New Session")
                        }
                        .foregroundStyle(.darkBlue500)
                    }
                }
            }
        } detail: {
            Text("Select an item")
        }
    }
}

// MARK: - Mainframe View Preview

#if DEBUG
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let modelContainer = try! ModelContainer(for: Session.self, configurations: config)
    return MainframeView(viewModel: MainframeView.ViewModel(modelContext: modelContainer.mainContext))
}
#endif
