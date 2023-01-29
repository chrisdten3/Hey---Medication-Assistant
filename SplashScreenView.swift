//
//  SplashScreenView.swift
//  Hey
//
//  Created by Chris Tengey on 1/17/23.
//

import Foundation
import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var size = 0.8
    @State private var opacity = 0.5
    
    var body: some View {
        if isActive {
            SlideOneView()
        } else {
            ZStack {
                Color.black.ignoresSafeArea()
                Image("kms")
                    .font(.system(size: 80))
                    .scaleEffect(size)
                    .opacity(opacity)
                    .onAppear {
                        withAnimation(.easeIn(duration: 1.2)) {
                            self.size = 0.9
                            self.opacity = 1.0
                        }
                    }
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            //withAnimation{
                                self.isActive = true
                            //}
                        }
                    }
            }
        }
        
    }
}

struct Preview: PreviewProvider {
    static var previews: some View {
        SplashScreenView()
    }
}
