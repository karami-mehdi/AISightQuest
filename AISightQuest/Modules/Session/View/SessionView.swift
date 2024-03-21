//
//  SessionView.swift
//  AISightQuest
//
//  Created by Mehdi Karami on 2/25/24.
//

import SwiftUI
import SwiftData

// MARK: - Session View

struct SessionView: View {
    @State private(set) var viewModel: ViewModel
    @EnvironmentObject private var navigationState: NavigationState
    
    @State private var isShowingScannerSheet = false
    @State private var clearAttributedTextButtonTapped = 0
    @State private var clearQuestionButtonTapped = 0

    @State private var questionText = ""
    @State private var attributedText = NSAttributedString(string: "")
    
    var body: some View {
        VStack(spacing: 8) {
            TextView(attributedText: $attributedText)
                .padding()
                .padding(.bottom, 52)
                .background {
                    LinearGradient(colors: [.darkBlue300, .lilac100,
                                            .darkBlue300, .lilac200],
                                   startPoint: .topLeading,
                                   endPoint: .bottomTrailing)
                }
                .clipShape(RoundedRectangle(cornerRadius: 36))
                .overlay(
                    RoundedRectangle(cornerRadius: 36)                        .stroke(.darkBlue300, lineWidth: 1)
                )
                .padding()
                .overlay {
                    VStack {
                        Spacer()
                        
                        HStack {
                            Spacer()
                            
                            Button {
                                isShowingScannerSheet = true
                            } label: {
                                HStack {
                                    Image(systemName: "camera.circle.fill")
                                        .foregroundStyle(.lilac200)
                                        .font(.title2)
                                    Text("scan")
                                        .foregroundStyle(.lilac100)
                                }
                                .bold()
                                .padding()
                                .frame(height: 40)
                                .background {
                                    Capsule()
                                        .fill(LinearGradient(colors: [Color.darkBlue500,
                                                                      .darkBlue900],
                                                             startPoint: .top,
                                                             endPoint: .bottom))
                                }
                            }
                            .background {
                                Capsule()
                                    .fill(.lilac500)
                                    .shadow(color: .lilac100, radius: 20, x: 0, y: 0)
                            }
                            .sensoryFeedback(.impact(flexibility: .rigid, intensity: 1),
                                             trigger: isShowingScannerSheet)
                            
                            Button {
                                setAttributedText("")
                                clearAttributedTextButtonTapped += 1
                            } label: {
                                Image(systemName: "xmark")
                                    .foregroundStyle(.lilac200)
                                    .bold()
                                    .padding()
                                    .frame(height: 40)
                                    .background {
                                        Circle()
                                            .fill(LinearGradient(colors: [Color.darkBlue500,
                                                                          .darkBlue900],
                                                                 startPoint: .top,
                                                                 endPoint: .bottom))
                                    }
                            }
                            .background {
                                Circle()
                                    .fill(.lilac500)
                                    .shadow(color: .lilac100, radius: 20, x: 0, y: 0)
                            }
                            .sensoryFeedback(.impact(flexibility: .rigid, intensity: 1),
                                             trigger: clearAttributedTextButtonTapped)
                        }
                    }
                    .padding(28)
                    .padding(.vertical, 4)
                }
            
            HStack {
                TextField("question text field", text: $questionText)
                    .submitLabel(.search)
                    .padding([.vertical, .leading])
                    .onSubmit {
                        let result = viewModel.findAnswer(for: questionText,
                                                          in: viewModel.sessions[viewModel.sessionIndex].text)
                        
                        if let attributedString = result.attributedText {
                            attributedText = attributedString
                        }
                        questionText = result.questionText
                    }
                
                Button {
                    questionText = ""
                    clearQuestionButtonTapped += 1
                } label: {
                    Image(systemName: "xmark.circle")
                        .foregroundStyle(.darkBlue500)
                        .font(.title)
                        .padding(.trailing)
                }
                .sensoryFeedback(.impact(flexibility: .rigid, intensity: 1),
                                 trigger: clearQuestionButtonTapped)
            }
            .overlay(
                Capsule()
                    .stroke(.lilac200, lineWidth: 2)
            )
            .padding()
        }
        .onChange(of: attributedText.string) { _, newValue in
            viewModel.sessions[viewModel.sessionIndex].text = newValue
        }
        .onAppear {
            setAttributedText(viewModel.sessions[viewModel.sessionIndex].text)
        }
        .sheet(isPresented: $isShowingScannerSheet) { makeScannerView().ignoresSafeArea() }
    }
    
    private func setAttributedText(_ text: String) {
        attributedText = NSMutableAttributedString(string: text,
                                                   attributes: [.foregroundColor: UIColor.black,
                                                                .font: UIFontMetrics(forTextStyle: .body)
                                                                .scaledFont(for: UIFont.systemFont(ofSize: 17))])
    }
    
    private func makeScannerView() -> ScannerView {
        ScannerView { textPerPage in
            if let text = textPerPage?
                .joined(separator: "\n")
                .trimmingCharacters(in: .whitespacesAndNewlines) {
                setAttributedText(text)
            }
            isShowingScannerSheet = false
        }
    }
}

// MARK: - Session View Preview

#if DEBUG
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let modelContainer = try! ModelContainer(for: Session.self, configurations: config)
    return SessionView(viewModel: SessionView.ViewModel(modelContext: modelContainer.mainContext, sessionIndex: 1))
}
#endif
