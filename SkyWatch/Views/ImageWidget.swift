//
//  ImageWidget.swift
//  SkyWatch
//
//  Created by Zane Helton on 6/11/23.
//

import SwiftUI

struct ImageWidget: View {
    let imageName: String
    let heading: String
    let subheading: String
    let color: Color
    var rotation: Int = 0
    
    init(imageName: String, heading: String, subheading: String, color: Color) {
        self.imageName = imageName
        self.heading = heading
        self.subheading = subheading
        self.color = color
    }
    
    init(imageName: String, heading: String, subheading: String, color: Color, rotation: Int) {
        self.imageName = imageName
        self.heading = heading
        self.subheading = subheading
        self.color = color
        self.rotation = rotation
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: imageName)
                .aspectRatio(contentMode: .fill)
                .foregroundColor(color)
                .font(.system(size: 32))
                .rotationEffect(Angle(degrees: Double(self.rotation)))
            
            VStack(spacing: 4) {
                Text(heading)
                    .font(.headline)
                    .bold()
                
                Text(subheading)
                    .font(.subheadline)
                    .bold()
            }
        }
        .frame(height: 52) // Set a fixed width for the widget
        .padding()
        .background(Color.secondary.opacity(0.25))
        .cornerRadius(8)
        .fixedSize(horizontal: false, vertical: true)
    }
}
