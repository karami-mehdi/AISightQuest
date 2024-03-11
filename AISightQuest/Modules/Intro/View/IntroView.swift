//
//  IntroView.swift
//  AISightQuest
//
//  Created by Mehdi Karami on 3/3/24.
//

import SwiftUI
import SwiftData

// MARK: - Intro View

struct IntroView: View {
    @State private(set) var viewModel: ViewModel
    @EnvironmentObject private var navigationState: NavigationState
    
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
            
            VStack(spacing: 10) {
                LottieView(name: Intro.Data.firstIntro.imageName)
                    .padding(90)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size.width, height: size.height / 2)
                    .padding(.vertical, 60)
                
                
                Text(Intro.Data.firstIntro.text)
                    .font(.system(size: 14))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                
                Text("Let's begin")
                    .font(.system(size: 14, weight: .semibold))
                    .padding(.horizontal, 40)
                    .padding(.vertical, 14)
                    .foregroundColor(.white)
                    .background {
                        Capsule()
                            .fill(Color(.black))
                    }
                    .padding(.top, 30)
                    .onTapGesture {
                        showWalkThroughScreens.toggle()
                    }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            // MARK: Moving Up When Click
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
                // MARK: Converting Next Button Into  SignUp Button
                ZStack {
                    Image(systemName: "chevron.right")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .scaleEffect(!isLast ? 1 : 0.001)
                        .opacity(!isLast ? 1 : 0)
                    
                    HStack {
                        Text("Let's do it")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Image(systemName: "arrow.right")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 15)
                    .scaleEffect(isLast ? 1 : 0.001)
                    .frame(height: isLast ? nil : 0)
                    .opacity(isLast ? 1 : 0)
                }
                .frame(width: isLast ? (size.width / 1.5) : 55,
                       height: isLast ? 50 : 55)
                .foregroundColor(.white)
                .background {
                    RoundedRectangle(cornerRadius: isLast ? 10 : 30,
                                     style: isLast ? .continuous : .circular)
                    .fill(.black)
                }
                .onTapGesture {
                    // MARK: Update Current Index
                    if currentIndex == Intro.Data.intros.count {
                        // MARK: Moving To Home Screen
                        navigationState.routes.append(Routes.splash(.mainframe(modelContext: viewModel.modelContext)))
                    } else {
                        currentIndex += 1
                    }
                }
                .offset(y: isLast ? -40 : -90)
                .animation(.interactiveSpring(response: 0.8,
                                              dampingFraction: 0.8,
                                              blendDuration: 0.5),
                           value: isLast)
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
                .font(.system(size: 28, weight: .bold))
                .offset(x: -size.width * CGFloat(currentIndex - index))
                .animation(.interactiveSpring(response: 0.9,
                                              dampingFraction: 0.8,
                                              blendDuration: 0.5).delay(0.2),
                           value: currentIndex)
            
            Text(intro.text)
                .font(.system(size: 14, weight: .regular))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
                .offset(x: -size.width * CGFloat(currentIndex - index))
                .animation(.interactiveSpring(response: 0.9,
                                              dampingFraction: 0.8,
                                              blendDuration: 0.5).delay(0.1),
                           value: currentIndex)
            
            LottieView(name: intro.imageName, loopMode: .loop)
                .aspectRatio(contentMode: .fit)
                .frame(height: 250, alignment: .top)
                .padding(.horizontal, 20)
                .offset(x: -size.width * CGFloat(currentIndex - index))
                .animation(.interactiveSpring(response: 0.9,
                                              dampingFraction: 0.8,
                                              blendDuration: 0.5).delay(0),
                           value: currentIndex)
        }
    }
    
    // MARK: - Welcome View
    
    @ViewBuilder
    func WelcomeView(size: CGSize, index: Int) -> some View {
        VStack(spacing: 10) {
            LottieView(name: Intro.Data.lastIntro.imageName, loopMode: .loop)
                .aspectRatio(contentMode: .fit)
                .frame(height: 250, alignment: .top)
                .padding(.horizontal, 20)
                .offset(x: -size.width * CGFloat(currentIndex - index))
                .animation(.interactiveSpring(response: 0.9,
                                              dampingFraction: 0.8,
                                              blendDuration: 0.5).delay(0),
                           value: currentIndex)
            
            Text(Intro.Data.lastIntro.text)
                .font(.system(size: 28, weight: .bold))
                .offset(x: -size.width * CGFloat(currentIndex - index))
                .animation(.interactiveSpring(response: 0.9,
                                              dampingFraction: 0.8,
                                              blendDuration: 0.5).delay(0.2),
                           value: currentIndex)
            
            Text(Intro.Data.lastIntro.text)
                .font(.system(size: 14, weight: .regular))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
                .offset(x: -size.width * CGFloat(currentIndex - index))
                .animation(.interactiveSpring(response: 0.9,
                                              dampingFraction: 0.8,
                                              blendDuration: 0.5).delay(0.1),
                           value: currentIndex)
        }
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
                    .foregroundColor(Color.black)
            }
            
            Spacer()
            
            Button("skip") { currentIndex = Intro.Data.intros.count }
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color.black)
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
