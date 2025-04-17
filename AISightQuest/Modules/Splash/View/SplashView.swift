//
//  SplashView.swift
//  AISightQuest
//
//  Created by Mehdi Karami on 3/3/24.
//

import SwiftUI
import SwiftData
import Lottie

// MARK: - Splash View

struct SplashView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private(set) var viewModel: ViewModel
    @EnvironmentObject private var navigationState: NavigationState
    
    @State private var isFirstOpen = true
    
    var body: some View {
        ZStack {
            Color.clear
            
            if !isFirstOpen {
                LottieView(animation: .named(colorScheme == .dark
                                             ? "AI-Sight-Quest-Lottie-Dark-Mode"
                                             : "AI-Sight-Quest-Lottie-Light-Mode"))
                .playing()
                .frame(width: 250, height: 250)
            }
        }
        .onAppear {
            if viewModel.isFirstOpen {
                navigationState.routes.append(Routes.splash(.intro(modelContext: viewModel.modelContext)))
            } else {
                isFirstOpen = false
                Task {
                    try? await Task.sleep(nanoseconds: 3 * 1_000_000_000) // Convert seconds to nanoseconds
                    withAnimation(.easeOut(duration: 0.5)) {
                        navigationState.routes.append(Routes.splash(.mainframe(modelContext: viewModel.modelContext)))
                    }
                }
            }
        }
    }
}

// MARK: - Splash View Preview

#if DEBUG
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let modelContainer = try! ModelContainer(for: Session.self, configurations: config)
    return SplashView(viewModel: SplashView.ViewModel(storageManager: StorageManager(),
                                                      modelContext: modelContainer.mainContext))
}
#endif
