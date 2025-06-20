import SwiftUI

struct SidebarView: View {
    @Binding var selectedMood: String
    
    let moods = ["Happy", "Sad", "Excited", "Romantic"]
    
    // Netflix-inspired mood configurations
    let moodData: [String: (emoji: String, description: String, colors: [Color], netflixGenre: String)] = [
        "Happy": ("😊", "Feel-good comedies & uplifting stories", [.yellow, .orange], "Comedy • Family • Feel-Good"),
        "Sad": ("😢", "Emotional dramas & tearjerkers", [.blue, .cyan], "Drama • Emotional • Tearjerker"),
        "Excited": ("🤩", "Action-packed thrillers & blockbusters", [.red, .pink], "Action • Thriller • Adventure"),
        "Romantic": ("💕", "Romance & heartwarming love stories", [.pink, .purple], "Romance • Love Stories • Date Night")
    ]
    
    var body: some View {
        ZStack {
            // Netflix-style dark background with subtle gradient
            LinearGradient(
                colors: [
                    Color.black,
                    Color(red: 0.05, green: 0.05, blue: 0.1),
                    Color.black
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                // Netflix-style header
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        // Netflix-inspired logo
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.red, Color(red: 0.8, green: 0.1, blue: 0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 40, height: 40)
                                .shadow(color: Color.red.opacity(0.3), radius: 8, x: 0, y: 4)
                            
                            Image(systemName: "play.fill")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Flix Finder")
                                .font(.system(size: 20, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                                .tracking(1.2)
                            
                            Text("What's your vibe?")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.gray)
                                .opacity(0.8)
                        }
                        
                        Spacer()
                    }
                    
                    // Current mood indicator
                    if let currentMoodData = moodData[selectedMood] {
                        HStack(spacing: 8) {
                            Text("NOW BROWSING:")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.gray)
                                .tracking(1)
                            
                            Text(currentMoodData.netflixGenre)
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: currentMoodData.colors,
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(0.05))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(
                                            LinearGradient(
                                                colors: currentMoodData.colors.map { $0.opacity(0.3) },
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            ),
                                            lineWidth: 1
                                        )
                                )
                        )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 32)
                
                // Netflix-style mood grid
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(moods, id: \.self) { mood in
                            NetflixMoodCard(
                                mood: mood,
                                isSelected: selectedMood == mood,
                                moodData: moodData[mood]!,
                                onTap: {
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                        selectedMood = mood
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                }
                
                Spacer()
            }
        }
        .frame(minWidth: 320)
    }
}

// Netflix-style mood card
struct NetflixMoodCard: View {
    let mood: String
    let isSelected: Bool
    let moodData: (emoji: String, description: String, colors: [Color], netflixGenre: String)
    let onTap: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                // Main card content
                HStack(spacing: 16) {
                    // Netflix-style thumbnail area
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        moodData.colors[0].opacity(0.8),
                                        moodData.colors[1].opacity(0.6),
                                        Color.black.opacity(0.3)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 60)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        LinearGradient(
                                            colors: moodData.colors.map { $0.opacity(0.5) },
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: isSelected ? 2 : 1
                                    )
                                    .opacity(isSelected ? 1 : 0.3)
                            )
                        
                        Text(moodData.emoji)
                            .font(.system(size: 28))
                            .scaleEffect(isSelected ? 1.1 : 1.0)
                        
                        // Play button overlay on hover
                        if isHovered || isSelected {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.9))
                                    .frame(width: 24, height: 24)
                                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                                
                                Image(systemName: "play.fill")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.black)
                                    .offset(x: 1)
                            }
                            .offset(x: 24, y: -24)
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                    
                    // Content details
                    VStack(alignment: .leading, spacing: 8) {
                        Text(mood)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text(moodData.description)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.gray)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        
                        // Genre tags
                        Text(moodData.netflixGenre)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.gray)
                            .opacity(0.8)
                    }
                    
                    Spacer()
                    
                    // Selection indicator
                    VStack {
                        if isSelected {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: moodData.colors,
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 24, height: 24)
                                    .shadow(color: moodData.colors[0].opacity(0.5), radius: 4, x: 0, y: 2)
                                
                                Image(systemName: "checkmark")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            .transition(.scale.combined(with: .opacity))
                        }
                        
                        Spacer()
                    }
                }
                .padding(20)
                
                // Progress bar for selected mood
                if isSelected {
                    HStack {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: moodData.colors,
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(height: 3)
                            .animation(.easeInOut(duration: 0.8), value: isSelected)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        isSelected ?
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.1),
                                Color.white.opacity(0.05),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ) :
                        LinearGradient(
                            colors: [
                                Color.white.opacity(isHovered ? 0.05 : 0.02),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected ?
                                LinearGradient(
                                    colors: moodData.colors.map { $0.opacity(0.6) },
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ) :
                                LinearGradient(
                                    colors: [Color.white.opacity(isHovered ? 0.2 : 0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: isSelected ? 1.5 : (isHovered ? 1 : 0.5)
                            )
                    )
            )
            .scaleEffect(isSelected ? 1.02 : (isHovered ? 1.01 : 1.0))
            .shadow(
                color: isSelected ? moodData.colors[0].opacity(0.3) : Color.black.opacity(0.2),
                radius: isSelected ? 12 : (isHovered ? 8 : 4),
                x: 0,
                y: isSelected ? 6 : (isHovered ? 4 : 2)
            )
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isSelected)
            .animation(.easeInOut(duration: 0.2), value: isHovered)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}
