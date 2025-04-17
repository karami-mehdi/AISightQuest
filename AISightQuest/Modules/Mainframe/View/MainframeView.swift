//
//  MainframeView.swift
//  AISightQuest
//
//  Created by Mehdi Karami on 2/22/24.
//

import SwiftUI
import SwiftData
import TipKit
import Lottie

// MARK: - Mainframe View

struct MainframeView: View {
    @State private(set) var viewModel: ViewModel
    @EnvironmentObject private var navigationState: NavigationState
    
    @Environment(\.colorScheme) private var colorScheme

    @State private var sessionTapped = 0
    @State private var addSessionButtonTapped = 0
    @State private var isShowingSessionSheet = false
    @State private var index = 0
    
    var body: some View {
        ZStack {
            MainframeBackgroundView()
            
            VStack {
                Group {
                    if viewModel.sessions.isEmpty {
                        VStack {
                            LottieView(animation: .named(colorScheme == .dark
                                                         ? "Mainframe-Lottie-Dark-Mode"
                                                         : "Mainframe-Lottie-Light-Mode"))
                            .playing(loopMode: .loop)
                            .aspectRatio(contentMode: .fit)
                            .padding(.horizontal, 20)
                            
                            Spacer()
                        }
                    } else {
                        List {
                            ForEach(Array($viewModel.sessions.enumerated()), id: \.element.id) { index, session in
                                Button {
                                    self.index = index
                                    isShowingSessionSheet = true
                                    sessionTapped += 1
                                } label: {
                                    SessionRow(session: session) { newName in
                                        let newName = viewModel.renameSession(currentName: session.name.wrappedValue,
                                                                              into: newName)
                                        
                                        viewModel.updateSession(sessionIndex: index, name: newName, lastChange: Date())
                                    }
                                }
                                .listRowBackground(LinearGradient(colors: [Color.darkBlue500,
                                                                           .darkBlue500,
                                                                           .darkBlue600],
                                                                  startPoint: .topLeading,
                                                                  endPoint: .bottomTrailing).opacity(0.9))
                                .listRowSeparatorTint(Color.lilac400)
                                .sensoryFeedback(.impact(flexibility: .rigid, intensity: 1), trigger: sessionTapped)
                            }
                            .onDelete { indexSet in
                                withAnimation {
                                    viewModel.deleteSession(indexSet: indexSet)
                                }
                            }
                        }
                        .scrollIndicators(.never)
                        .scrollContentBackground(.hidden)
                        .background(.clear)
                        .clipped()
                    }
                    
                    Text("hidden reset button")
                        .foregroundStyle(.clear)
                        .frame(height: 4)
                        .onTapGesture(count: 8) {
                            viewModel.resetApplication()
                        }
                    
                    Button {
                        withAnimation(.smooth) {
                            viewModel.addSession(name: "New Session", lastChange: Date())
                            addSessionButtonTapped += 1
                        }
                    } label: {
                        HStack {
                            Image(systemName: "plus")
                                .foregroundStyle(.lilac200)
                            Text("session")
                                .foregroundStyle(.lilac100)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .popoverTip(NewSessionTip())
                    .padding()
                    .buttonStyle(CustomButtonStyle())
                    .sensoryFeedback(.impact(flexibility: .rigid, intensity: 1), trigger: addSessionButtonTapped)
                }
            }
            .padding(.horizontal, 16)
        }
        .fullScreenCover(isPresented: $isShowingSessionSheet) {
            viewModel.fetchData()
        } content: {
            MainframeRouter(routes: .session(modelContext: viewModel.modelContext, sessionIndex: index))
                .configure()
        }
        .navigationBarBackButtonHidden()
    }
}

// MARK: - Mainframe View Preview

#if DEBUG
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let modelContainer = try! ModelContainer(for: Session.self, configurations: config)
    return MainframeView(viewModel: MainframeView.ViewModel(storageManager: StorageManager(),
                                                            modelContext: modelContainer.mainContext))
}
#endif
