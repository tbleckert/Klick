//
//  CameraView.swift
//  Klick
//
//  Created by Tobias Bleckert on 2026-01-16.
//

import SwiftUI
import SwiftData
#if canImport(ConfettiSwiftUI)
import ConfettiSwiftUI
#endif

struct CameraView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Photo.timestamp, order: .reverse) private var photos: [Photo]
    
    @StateObject private var cameraManager = CameraManager()
    @State private var showGallery = false
    @State private var buttonScale: CGFloat = 1.0
    @State private var lastZoomFactor: CGFloat = 1.0
    @State private var showFilterName = false
    @State private var showFrameName = false
    @State private var confettiCounter = 0
    
    var body: some View {
        ZStack {
            // Camera preview - full screen
            CameraPreviewView(session: cameraManager.session, cameraManager: cameraManager)
                .ignoresSafeArea()
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            let delta = value / lastZoomFactor
                            lastZoomFactor = value
                            let newZoom = cameraManager.zoomFactor * delta
                            cameraManager.setZoom(factor: newZoom)
                        }
                        .onEnded { _ in
                            lastZoomFactor = 1.0
                        }
                )
                .simultaneousGesture(
                    DragGesture(minimumDistance: 30)
                        .onEnded { gesture in
                            if abs(gesture.translation.width) > abs(gesture.translation.height) {
                                // Horizontal swipe - change filter
                                if gesture.translation.width > 0 {
                                    cameraManager.previousFilter()
                                } else {
                                    cameraManager.nextFilter()
                                }
                                showFilterName = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    showFilterName = false
                                }
                            } else {
                                // Vertical swipe - change frame
                                if gesture.translation.height > 0 {
                                    cameraManager.previousFrame()
                                } else {
                                    cameraManager.nextFrame()
                                }
                                showFrameName = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    showFrameName = false
                                }
                            }
                        }
                )

            // Frame overlay (animal emojis in corners)
            if cameraManager.currentFrame != .none {
                GeometryReader { geometry in
                    let emoji = cameraManager.currentFrame.emoji
                    let size: CGFloat = 60

                    // Top-left
                    Text(emoji)
                        .font(.system(size: size))
                        .position(x: size/2 + 20, y: size/2 + 60)

                    // Top-right
                    Text(emoji)
                        .font(.system(size: size))
                        .position(x: geometry.size.width - size/2 - 20, y: size/2 + 60)

                    // Bottom-left
                    Text(emoji)
                        .font(.system(size: size))
                        .position(x: size/2 + 20, y: geometry.size.height - size/2 - 120)

                    // Bottom-right
                    Text(emoji)
                        .font(.system(size: size))
                        .position(x: geometry.size.width - size/2 - 20, y: geometry.size.height - size/2 - 120)
                }
                .allowsHitTesting(false)
            }


            // Filter/Frame name overlay
            VStack {
                if showFilterName || showFrameName {
                    Text(showFilterName ? cameraManager.currentFilter.displayName : cameraManager.currentFrame.displayName)
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.black.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.top, 60)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
                Spacer()
            }
            .animation(.easeInOut, value: showFilterName)
            .animation(.easeInOut, value: showFrameName)
            
            // UI Overlay
            VStack {
                Spacer()
                
                HStack(alignment: .bottom) {
                    // Gallery button - bottom left (only show if photos exist)
                    if let latestPhoto = photos.first,
                       let uiImage = loadImage(from: latestPhoto.fileURL) {
                        Button(action: {
                            showGallery = true
                        }) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 70, height: 70)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                        }
                        .padding(.leading, 30)
                    } else {
                        // Placeholder for symmetry when no photos
                        Color.clear
                            .frame(width: 70, height: 70)
                            .padding(.leading, 30)
                    }
                    
                    Spacer()
                    
                    // Large capture button - center
                    Button(action: {
                        capturePhoto()
                    }) {
                        ZStack {
                            // Outer ring - plain color
                            Circle()
                                .stroke(Color.orange, lineWidth: 6)
                                .frame(width: 100, height: 100)
                            
                            // Inner white circle
                            Circle()
                                .fill(Color.white)
                                .frame(width: 85, height: 85)
                                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                        }
                        .scaleEffect(buttonScale)
                    }
                    .padding(.bottom, 10)
                    
                    Spacer()
                    
                    // Placeholder for symmetry
                    Color.clear
                        .frame(width: 70, height: 70)
                        .padding(.trailing, 30)
                }
                .padding(.bottom, 40)
            }
        }
#if canImport(ConfettiSwiftUI)
        .confettiCannon(trigger: $confettiCounter, num: 40, confettis: [.text("🐶"), .text("🐱"), .text("🐭"), .text("🐹"), .text("🐰"), .text("🦊"), .text("🐻"), .text("🐼"), .text("🐨"), .text("🐯"), .text("🦁"), .text("🐮"), .text("🐷"), .text("🐸"), .text("🐵"), .text("🐔"), .text("🐧"), .text("🐦"), .text("🐤"), .text("🦆"), .text("🦅"), .text("🦉"), .text("🦇"), .text("🐺"), .text("🐗"), .text("🐴"), .text("🦄"), .text("🐝"), .text("🐛"), .text("🦋"), .text("🐌"), .text("🐞"), .text("🐢"), .text("🐍"), .text("🦎"), .text("🦖"), .text("🦕")], radius: 500)
#else
        // ConfettiSwiftUI not available; no-op to keep build green
        .onChange(of: confettiCounter) { _, _ in }
#endif
        .onAppear {
            cameraManager.onPhotoCaptured = { filename in
                savePhotoToDatabase(filename: filename)
                confettiCounter += 1
            }
        }
        .fullScreenCover(isPresented: $showGallery) {
            GalleryView()
        }
        .animation(.easeInOut(duration: 0.1), value: cameraManager.showFlashAnimation)
    }
    
    private func capturePhoto() {
        // Button press animation
        withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
            buttonScale = 0.85
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                buttonScale = 1.0
            }
        }
        
        cameraManager.capturePhoto()
    }
    
    private func savePhotoToDatabase(filename: String) {
        let photo = Photo(filename: filename)
        modelContext.insert(photo)
        
        do {
            try modelContext.save()
        } catch {
            print("Error saving photo to database: \(error)")
        }
    }
    
    private func loadImage(from url: URL) -> UIImage? {
        guard FileManager.default.fileExists(atPath: url.path) else {
            return nil
        }
        return UIImage(contentsOfFile: url.path)
    }
}

#Preview {
    CameraView()
        .modelContainer(for: Photo.self, inMemory: true)
}
