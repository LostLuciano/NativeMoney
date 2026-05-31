import SwiftUI
import PhotosUI

public struct AIChatView: View {
    @EnvironmentObject var aiVM: AIViewModel
    @State private var inputText = ""
    @State private var scrollProxy: ScrollViewProxy?
    @State private var showImagePicker = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var showRecommendations = false
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.05, green: 0.05, blue: 0.08)
                    .ignoresSafeArea()
                
                // Ambient glow
                Circle()
                    .fill(Color.purple.opacity(0.08))
                    .frame(width: 300, height: 300)
                    .blur(radius: 80)
                    .offset(x: 80, y: -150)
                
                VStack(spacing: 0) {
                    // AI Recommendation Bubble (Dismissable)
                    if showRecommendations && !aiVM.recommendations.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(aiVM.recommendations.indices, id: \.self) { i in
                                    Text(aiVM.recommendations[i])
                                        .font(.caption)
                                        .foregroundStyle(.white)
                                        .padding(12)
                                        .frame(maxWidth: 240)
                                        .glassEffect(.regular.tint(.purple.opacity(0.15)), in: RoundedRectangle(cornerRadius: 14))
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                        }
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    // Chat Messages
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(aiVM.chatHistory) { message in
                                    ChatBubbleView(message: message)
                                        .id(message.id)
                                }
                                
                                if aiVM.isLoading {
                                    HStack(alignment: .bottom, spacing: 8) {
                                        AIAvatarView()
                                        
                                        HStack(spacing: 5) {
                                            ForEach(0..<3, id: \.self) { i in
                                                Circle()
                                                    .fill(Color.white.opacity(0.6))
                                                    .frame(width: 7, height: 7)
                                                    .scaleEffect(aiVM.isLoading ? 1.0 : 0.5)
                                                    .animation(
                                                        Animation.easeInOut(duration: 0.5)
                                                            .repeatForever()
                                                            .delay(Double(i) * 0.15),
                                                        value: aiVM.isLoading
                                                    )
                                            }
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .glassEffect(in: RoundedRectangle(cornerRadius: 16))
                                        
                                        Spacer()
                                    }
                                    .padding(.horizontal, 16)
                                    .id("typing_indicator")
                                }
                            }
                            .padding(.vertical, 16)
                        }
                        .onChange(of: aiVM.chatHistory.count) { _ in
                            withAnimation {
                                proxy.scrollTo(aiVM.chatHistory.last?.id, anchor: .bottom)
                            }
                        }
                        .onChange(of: aiVM.isLoading) { loading in
                            if loading {
                                withAnimation {
                                    proxy.scrollTo("typing_indicator", anchor: .bottom)
                                }
                            }
                        }
                    }
                    
                    // Input Area
                    VStack(spacing: 0) {
                        Divider()
                            .background(Color.white.opacity(0.1))
                        
                        HStack(spacing: 12) {
                            // Attachment picker (receipt scan)
                            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                                Image(systemName: "camera.fill")
                                    .font(.title3)
                                    .foregroundStyle(.white)
                                    .padding(10)
                                    .glassEffect(in: Circle())
                            }
                            .onChange(of: selectedPhotoItem) { newItem in
                                if let newItem {
                                    Task {
                                        if let data = try? await newItem.loadTransferable(type: Data.self) {
                                            await aiVM.scanReceiptImage(data: data, filename: "receipt.jpg")
                                            selectedPhotoItem = nil
                                        }
                                    }
                                }
                            }
                            
                            // Text Input Field — styled with glass
                            HStack {
                                TextField("Tanyakan sesuatu...", text: $inputText, axis: .vertical)
                                    .font(.body)
                                    .foregroundStyle(.white)
                                    .lineLimit(1...4)
                                    .submitLabel(.send)
                                    .onSubmit {
                                        sendMessage()
                                    }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .glassEffect(in: RoundedRectangle(cornerRadius: 20))
                            
                            // Send Button
                            Button(action: sendMessage) {
                                Image(systemName: "arrow.up.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(
                                        inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?
                                        Color.secondary : Color.white
                                    )
                            }
                            .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || aiVM.isLoading)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                }
            }
            .navigationTitle("Monassist AI")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    AIAvatarView(size: 30)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    GlassEffectContainer(spacing: 8) {
                        HStack(spacing: 8) {
                            Button(action: {
                                withAnimation(.spring()) {
                                    showRecommendations.toggle()
                                }
                                if !showRecommendations {
                                    Task {
                                        await aiVM.generateSmartRecommendations()
                                    }
                                }
                            }) {
                                Image(systemName: "lightbulb.fill")
                                    .foregroundStyle(showRecommendations ? .yellow : .secondary)
                            }
                            .glassEffect()
                            
                            Button(action: {
                                aiVM.chatHistory = []
                                Task {
                                    await MainActor.run {
                                        aiVM.chatHistory = [
                                            ChatMessage(text: "Sesi obrolan direset. Ada yang bisa saya bantu?", isUser: false)
                                        ]
                                    }
                                }
                            }) {
                                Image(systemName: "arrow.clockwise")
                                    .foregroundStyle(.secondary)
                            }
                            .glassEffect()
                        }
                    }
                }
            }
        }
    }
    
    private func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        inputText = ""
        Task {
            await aiVM.sendMessage(text)
        }
    }
}

// AI Avatar
struct AIAvatarView: View {
    var size: CGFloat = 36
    
    var body: some View {
        ZStack {
            Circle()
                .fill(LinearGradient(
                    colors: [Color.blue, Color.purple],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: size, height: size)
            
            Image(systemName: "sparkles")
                .font(.system(size: size * 0.42))
                .foregroundStyle(.white)
        }
    }
}

// Individual Chat Bubble
struct ChatBubbleView: View {
    let message: ChatMessage
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if !message.isUser {
                AIAvatarView()
            }
            
            if message.isUser { Spacer(minLength: 60) }
            
            Text(message.text)
                .font(.body)
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .glassEffect(
                    message.isUser
                        ? .regular.tint(.blue.opacity(0.2))
                        : .regular.tint(.white.opacity(0.04)),
                    in: RoundedRectangle(cornerRadius: 18)
                )
            
            if !message.isUser { Spacer(minLength: 60) }
            
            if message.isUser {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 36, height: 36)
                    Image(systemName: "person.fill")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.horizontal, 16)
    }
}
