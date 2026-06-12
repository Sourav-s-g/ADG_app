//
//  SplashView.swift
//  ADG
//
//  Created by Sourav S Gaikwad on 07/06/26.
//

import SwiftUI

struct SplashView: View {
    
    @State private var logoOpacity: Double = 0
    @State private var splashOpacity: Double = 1
    
    var onFinished: (() -> Void)?
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            Image("ADGLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 180)
                .opacity(logoOpacity)
        }
        .opacity(splashOpacity)
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        
        // Fade logo in
        withAnimation(.easeOut(duration: 0.8)) {
            logoOpacity = 1
        }
        
        // Wait, then fade everything out
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            withAnimation(.easeInOut(duration: 0.8)) {
                splashOpacity = 0
            }
            
            // Notify parent view
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                onFinished?()
            }
        }
    }
}

#Preview {
    SplashView()
}
