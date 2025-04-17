//
//  IntroView.swift
//  AISightQuest
//
//  Created by Mehdi Karami on 3/3/24.
//

import SwiftUI
import SwiftData
import Lottie

// MARK: - Intro View

struct IntroView: View {
    @State private(set) var viewModel: ViewModel
    @EnvironmentObject private var navigationState: NavigationState
    
    @Environment(\.colorScheme) private var colorScheme

    @State private var showWalkThroughScreens = false
    @State private var currentIndex = 0
    @State private var showHomeView = false
    
    var body: some View {
        ZStack {
            ZStack {
                IntroScreen()
                
                WalkThroughScreens()
                
                NavBar()
            }
            .animation(.interactiveSpring(response: 1.1,
                                          dampingFraction: 0.85,
                                          blendDuration: 0.85),
                       value: showWalkThroughScreens)
            .transition(.move(edge: .leading))
        }
        .animation(.interactiveSpring(response: 0.9,
                                      dampingFraction: 0.85,
                                      blendDuration: 0.6),
                   value: showHomeView)
        .sensoryFeedback(.impact(flexibility: .rigid, intensity: 1), trigger: currentIndex)
        .sensoryFeedback(.impact(flexibility: .rigid, intensity: 1), trigger: showWalkThroughScreens)
        .sensoryFeedback(.impact(flexibility: .rigid, intensity: 1), trigger: navigationState.routes)
        .navigationBarBackButtonHidden()
    }
}

// MARK: - Intro View Content Views

private extension IntroView {
    
    // MARK: - Intro Screen
    
    @ViewBuilder
    func IntroScreen() -> some View {
        GeometryReader {
            let size = $0.size
            let firstIntro = Intro.Data.getFirstIntro(colorScheme: colorScheme)
            
            VStack(spacing: 10) {
                LottieView(animation: .named(firstIntro.imageName))
                    .playing()
                    .padding(90)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size.width, height: size.height / 2)
                    .padding(.vertical, 60)
                
                
                Text(firstIntro.text)
                    .fontWidth(.condensed)
                    .foregroundStyle(.darkBlue600)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                
                Button {
                    withAnimation(.interactiveSpring) {
                        showWalkThroughScreens.toggle()
                    }
                } label: {
                    Text("first intro button text")
                        .fontWeight(.semibold)
                        .foregroundStyle(.lilac100)
                        .padding()
                }
                .padding(.top, 30)
                .padding(.vertical, 14)
                .padding(.horizontal, 40)
                .buttonStyle(CustomButtonStyle())
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            // MARK: Moving Up When Clicked
            .offset(y: showWalkThroughScreens ? (-size.height) : 0)
        }
        .ignoresSafeArea()
    }
    
    // MARK: - WalkThrough Screens
    
    @ViewBuilder
    func WalkThroughScreens() -> some View {
        let isLast = currentIndex == Intro.Data.intros.count
        
        GeometryReader {
            let size = $0.size
            
            ZStack {
                // MARK: Walk Through Screen
                ForEach(Intro.Data.intros.indices, id: \.self) { index in
                    ScreenView(size: size, index: index)
                }
                
                WelcomeView(size: size, index: Intro.Data.intros.count)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            // MARK: Next Button
            .overlay(alignment: .bottom) {
                // MARK: Converting Next Button Into SignUp Button
                HStack {
                    Spacer()
                    
                    Button {
                        // MARK: Update Current Index
                        if currentIndex == Intro.Data.intros.count {
                            // MARK: Moving To Home Screen
                            navigationState.routes.append(Routes.intro(.mainframe(modelContext: viewModel.modelContext)))
                            viewModel.isFirstOpen = true
                        } else {
                            currentIndex += 1
                        }
                    } label: {
                        ZStack {
                            Image(systemName: "chevron.right")
                                .font(.title3)
                                .foregroundStyle(.lilac200)
                                .hidden(isLast, remove: isLast)
                                .scaleEffect(!isLast ? 1 : 0.0001)
                            
                            HStack(spacing: 48) {
                                Text("last intro button text")
                                    .foregroundStyle(.lilac100)
                                
                                Image(systemName: "arrow.right")
                                    .font(.title3)
                                    .foregroundStyle(.lilac200)
                            }
                            .padding(.horizontal)
                            .hidden(!isLast, remove: !isLast)
                            .scaleEffect(isLast ? 1 : 0.0001)
                        }
                        .fontWeight(.semibold)
                    }
                    .padding()
                    .offset(y: isLast ? -20 : -50)
                    .animation(.interactiveSpring(response: 0.8,
                                                  dampingFraction: 0.8,
                                                  blendDuration: 0.5),
                               value: isLast)
                    .buttonStyle(CustomButtonStyle())
                    
                    Spacer()
                }
            }
            .offset(y: showWalkThroughScreens ? 0 : size.height)
        }
    }
    
    // MARK: - Screen View
    
    @ViewBuilder
    func ScreenView(size: CGSize, index: Int) -> some View {
        let intro = Intro.Data.intros[index]
        
        VStack(spacing: 10) {
            Text(intro.title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .fontWidth(.compressed)
                .offset(x: -size.width * CGFloat(currentIndex - index))
                .animation(.interactiveSpring(response: 0.9,
                                              dampingFraction: 0.8,
                                              blendDuration: 0.5).delay(0.2),
                           value: currentIndex)
            
            Text(intro.text)
                .fontWeight(.regular)
                .fontWidth(.condensed)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
                .offset(x: -size.width * CGFloat(currentIndex - index))
                .animation(.interactiveSpring(response: 0.9,
                                              dampingFraction: 0.8,
                                              blendDuration: 0.5).delay(0.1),
                           value: currentIndex)
            
            LottieView(animation: .named(intro.imageName))
                .playing(loopMode: .loop)
                .aspectRatio(contentMode: .fit)
                .frame(width: size.width * 0.7, alignment: .top)
                .padding(.horizontal, 20)
                .offset(x: -size.width * CGFloat(currentIndex - index))
                .animation(.interactiveSpring(response: 0.9,
                                              dampingFraction: 0.8,
                                              blendDuration: 0.5).delay(0),
                           value: currentIndex)
        }
        .foregroundStyle(.darkBlue600)
    }
    
    // MARK: - Welcome View
    
    @ViewBuilder
    func WelcomeView(size: CGSize, index: Int) -> some View {
        VStack(spacing: 10) {
            LottieView(animation: .named(Intro.Data.lastIntro.imageName))
                .playing(loopMode: .loop)
                .aspectRatio(contentMode: .fit)
                .frame(width: size.width * 0.7, alignment: .top)
                .padding(.horizontal, 20)
                .offset(x: -size.width * CGFloat(currentIndex - index))
                .animation(.interactiveSpring(response: 0.9,
                                              dampingFraction: 0.8,
                                              blendDuration: 0.5).delay(0),
                           value: currentIndex)
            
            Text(Intro.Data.lastIntro.title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .fontWidth(.compressed)
                .offset(x: -size.width * CGFloat(currentIndex - index))
                .animation(.interactiveSpring(response: 0.9,
                                              dampingFraction: 0.8,
                                              blendDuration: 0.5).delay(0.2),
                           value: currentIndex)
            
            Text(Intro.Data.lastIntro.text)
                .fontWeight(.regular)
                .fontWidth(.condensed)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
                .offset(x: -size.width * CGFloat(currentIndex - index))
                .animation(.interactiveSpring(response: 0.9,
                                              dampingFraction: 0.8,
                                              blendDuration: 0.5).delay(0.1),
                           value: currentIndex)
        }
        .foregroundStyle(.darkBlue600)
    }
    
    // MARK: - Nav Bar
    
    @ViewBuilder
    func NavBar() -> some View {
        let islast = currentIndex == Intro.Data.intros.count
        
        HStack {
            Button {
                if currentIndex > 0 { currentIndex -= 1 }
                else { showWalkThroughScreens.toggle() }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.darkBlue500)
            }
            
            Spacer()
            
            Button("skip") { currentIndex = Intro.Data.intros.count }
                .fontWeight(.regular)
                .foregroundStyle(Color.darkBlue500)
                .opacity(islast ? 0 : 1)
                .animation(.easeInOut, value: islast)
        }
        .padding(.horizontal, 15)
        .padding(.top, 10)
        .frame(maxHeight: .infinity, alignment: .top)
        .offset(y: showWalkThroughScreens ? 0 : -120)
    }
}


// MARK: - Intro View Preview

#if DEBUG
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let modelContainer = try! ModelContainer(for: Session.self, configurations: config)
    return IntroView(viewModel: IntroView.ViewModel(storageManager: StorageManager(),
                                                    modelContext: modelContainer.mainContext))
}
#endif
