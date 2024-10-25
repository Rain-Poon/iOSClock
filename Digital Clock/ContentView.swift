import SwiftUI

struct ContentView: View {
    @State private var currentTime = Date()
    @State private var currentPage: Int = 0 // Track the current page (0 for Clock, 1 for Focus Timer)
    
    // Focus Timer State
    @State private var focusActive = false
    @State private var startTime: Date?
    @State private var totalElapsedTimeToday: TimeInterval = 0
    @State private var sessionElapsedTime: TimeInterval = 0
    let focusTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                ClockView(currentTime: $currentTime)
                    .frame(width: geometry.size.width)
                
                FocusTimerView(
                    focusActive: $focusActive,
                    startTime: $startTime,
                    totalElapsedTimeToday: $totalElapsedTimeToday,
                    sessionElapsedTime: $sessionElapsedTime
                )
                .frame(width: geometry.size.width)
            }
            .frame(width: geometry.size.width * 2, alignment: currentPage == 0 ? .leading : .trailing)
            .offset(x: currentPage == 0 ? 0 : -geometry.size.width)
            .animation(.easeInOut(duration: 0.3), value: currentPage)
            .onReceive(timer) { _ in
                currentTime = Date()
            }
            .onReceive(focusTimer) { _ in
                if focusActive {
                    updateSessionElapsedTime()
                }
            }
            .gesture(
                DragGesture()
                    .onEnded { value in
                        if value.translation.width < -50 && currentPage == 0 {
                            // Swipe Left: Go to Focus Timer
                            withAnimation {
                                currentPage = 1
                            }
                        } else if value.translation.width > 50 && currentPage == 1 {
                            // Swipe Right: Go to Clock
                            withAnimation {
                                currentPage = 0
                            }
                        }
                    }
            )
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
    
    // Update the elapsed time for the current session
    private func updateSessionElapsedTime() {
        if let start = startTime {
            sessionElapsedTime = Date().timeIntervalSince(start)
        }
    }
}

// Separate ClockView
struct ClockView: View {
    @Binding var currentTime: Date

    var body: some View {
        HStack {
            // Time Display (Hour and Minute Side-by-Side)
            HStack(alignment: .center, spacing: 0) {
                // Hour Display
                Text(currentTime, formatter: DateFormatter.hour)
                    .font(.system(size: 180, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.482, green: 0.671, blue: 0.953))
                    .scaleEffect(x: 1, y: 1.2)
                    .transition(.scale)
                
                // Colon Separator
                Text(":")
                    .font(.system(size: 200, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.482, green: 0.671, blue: 0.953))
                    .padding(.horizontal, 10)
                    .padding(.bottom, 30)
                
                // Minute Display
                Text(currentTime, formatter: DateFormatter.minute)
                    .font(.system(size: 180, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.482, green: 0.671, blue: 0.953))
                    .scaleEffect(x: 1, y: 1.2)
                    .transition(.scale)
            }
            
            Spacer()
            
            // Weekday and Date Display
            HStack {
                VStack(alignment: .trailing) {
                    Text(currentTime, formatter: DateFormatter.shortWeekday)
                        .font(.system(size: 50, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.482, green: 0.671, blue: 0.953))
                    Text(currentTime, formatter: DateFormatter.dayMonth)
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                }
                .padding()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}

// Focus Timer View
struct FocusTimerView: View {
    @Binding var focusActive: Bool
    @Binding var startTime: Date?
    @Binding var totalElapsedTimeToday: TimeInterval
    @Binding var sessionElapsedTime: TimeInterval
    
    var body: some View {
        VStack(spacing: 40) {
            Text("Focus Timer")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            // Display the total elapsed time today
            Text(totalElapsedTimeFormatted)
                .font(.system(size: 100, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0.482, green: 0.671, blue: 0.953))
            
            // Focus Button
            Button(action: toggleFocus) {
                Text(focusActive ? "Stop Focus" : "Start Focus")
                    .font(.system(size: 30, weight: .bold))
                    .padding(10)
                    .background(focusActive ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
    
    // Toggle the focus state and start/stop the timer
    private func toggleFocus() {
        focusActive.toggle()
        if focusActive {
            startTime = Date()
        } else {
            // Stop the current session and add its time to the total
            if let start = startTime {
                totalElapsedTimeToday += Date().timeIntervalSince(start)
            }
            startTime = nil
            sessionElapsedTime = 0
        }
    }
    
    // Format the total elapsed time today as hours, minutes, and seconds
    private var totalElapsedTimeFormatted: String {
        let totalTime = totalElapsedTimeToday + sessionElapsedTime
        let hours = Int(totalTime) / 3600
        let minutes = (Int(totalTime) % 3600) / 60
        let seconds = Int(totalTime) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

// Date Formatters for hour and minute
extension DateFormatter {
    static let hour: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh"
        return formatter
    }()
    
    static let minute: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "mm"
        return formatter
    }()
    
    static let shortWeekday: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter
    }()
    
    static let dayMonth: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        return formatter
    }()
}

#Preview {
    ContentView()
}
