import SwiftUI

struct WatchView: View {
    @State private var currentTime = Time()
    @State private var selectedComponent: TimeComponent? = .hour
    @State private var selectedAMPM: String = Calendar.current.component(.hour, from: Date()) < 12 ? "AM" : "PM"
    @State private var showConfirmation = false
    @Environment(\.presentationMode) var presentationMode
    
    init(initialTime: Time, onSave: ((Time, String) -> Void)? = nil) {
        _currentTime = State(initialValue: initialTime)
        _selectedAMPM = State(initialValue: initialTime.hours < 12 ? "AM" : "PM")
        self.onSave = onSave
    }
    
    var onSave: ((Time, String) -> Void)?
    
    enum TimeComponent {
        case hour, minute
    }
    
    var body: some View {
        VStack {
            
            HStack(spacing: 8) {
                Text("\(currentTime.hours)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(width: 75, height: 75)
                    .background(selectedComponent == .hour ? Color.red : Color.gray.opacity(0.3))
                    .cornerRadius(12)
                    .onTapGesture {
                        selectedComponent = .hour
                    }
                
                Image("seprator")
                
                
                
                Text("\(String(format: "%02d", currentTime.minutes))")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(width: 75, height: 75)
                    .background(selectedComponent == .minute ? Color.red : Color.gray.opacity(0.3))
                    .cornerRadius(12)
                    .onTapGesture {
                        selectedComponent = .minute
                    }
                
                
                VStack {
                    Text("AM")
                        .font(.title3)
                        .foregroundColor(selectedAMPM == "AM" ? .red : .black)
                        .onTapGesture {
                            selectedAMPM = "AM"
                        }
                    
                    Text("PM")
                        .font(.title3)
                        .foregroundColor(selectedAMPM == "PM" ? .red : .black)
                        .onTapGesture {
                            selectedAMPM = "PM"
                        }
                }
                .padding()
                .frame(height: 75)
                .background(Color.gray.opacity(0.3))
                .cornerRadius(12)
            }
            .padding()
            
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 300, height: 300)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                updateDrag(value: value)
                            }
                            .onEnded { value in
                                finalizeDrag(value: value)
                            }
                    )
                
                Circle()
                    .fill(Color.red)
                    .frame(width: 10, height: 10)
                
                Circle()
                    .foregroundColor(.red)
                    .frame(width: 45, height: 45)
                    .offset(y: -120)
                    .rotationEffect(.degrees(
                        selectedComponent == .hour
                        ? Double(currentTime.hours % 12) * 30
                        : Double(currentTime.minutes) * 6
                    ))
                
                Rectangle()
                    .foregroundColor(.red)
                    .frame(width: 6, height: 120)
                    .offset(y: -60)
                    .rotationEffect(.degrees(
                        selectedComponent == .hour
                        ? Double(currentTime.hours % 12) * 30
                        : Double(currentTime.minutes) * 6
                    ))
                
                
                ZStack {
                    if selectedComponent == .hour {
                        ForEach(1..<13, id: \.self) { number in
                            Text("\(number)")
                                .font(.system(size: 20))
                                .position(circlePosition(for: number, hourORMinute: Double(12)))
                        }
                    } else if selectedComponent == .minute {
                        ForEach(Array(stride(from: 0, through: 55, by: 5)), id: \.self) { number in
                            Text(String(format: "%02d", number))
                                .font(.system(size: 20))
                                .position(circlePosition(for: number, hourORMinute: Double(60)))
                        }
                    }
                }
                .frame(width: 300, height: 300)
            }
            .padding()
            
            HStack(spacing: 20) {
                Spacer()
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Text("Cancel")
                        .foregroundColor(.red)
                })
                Button(action: {
                    saveAlarm()
                    showConfirmation = true
                }, label: {
                    Text("Save")
                        .foregroundColor(.red)
                })
                .alert(isPresented: $showConfirmation) {
                    Alert(
                        title: Text("Alarm Set Successfully"),
                        message: Text("Your alarm is set for \(currentTime.hours):\(String(format: "%02d", currentTime.minutes)) \(selectedAMPM)"),
                        dismissButton: .default(Text("OK")){
                            presentationMode.wrappedValue.dismiss()
                        }
                    )
                }
            }
            .padding()
        }
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
        .padding(.leading, 16)
        .padding(.trailing, 16)
    }
    
    private func updateDrag(value: DragGesture.Value) {
        let dragPosition = value.location
        let center = CGPoint(x: 150, y: 150) // Center of the clock
        let angle = atan2(dragPosition.y - center.y, dragPosition.x - center.x) * 180 / .pi
        let normalizedAngle = (angle < 0 ? angle + 360 : angle) + 90
        let finalAngle = normalizedAngle.truncatingRemainder(dividingBy: 360)
        
        if selectedComponent == .hour {
            // Map angle to hour units (1-12)
            let hourUnit = Int((finalAngle / 30).rounded()) % 12
            currentTime.hours = hourUnit == 0 ? 12 : hourUnit
        } else if selectedComponent == .minute {
            // Map angle to minute units (0-59)
            let minuteUnit = Int((finalAngle / 6).rounded()) % 60
            currentTime.minutes = minuteUnit
        }
    }
    
    
    private func finalizeDrag(value: DragGesture.Value) {
        updateDrag(value: value)
    }
    
    private func circlePosition(for number: Int, hourORMinute: Double) -> CGPoint {
        let angle = Double(number) * (360 / hourORMinute) - 90
        let radian = angle * .pi / 180
        let radius: CGFloat = 120
        let x = radius * CGFloat(cos(radian)) + 150
        let y = radius * CGFloat(sin(radian)) + 150
        return CGPoint(x: x, y: y)
    }
    
    
    
    private func saveAlarm() {
        let formattedTime = "\(currentTime.hours):\(String(format: "%02d", currentTime.minutes)) \(selectedAMPM)"
        print("Saving alarm with time: \(formattedTime)")
        onSave?(currentTime, formattedTime)
        showConfirmation = true
    }
}
struct Time {
    var hours: Int = Calendar.current.component(.hour, from: Date())
    var minutes: Int = Calendar.current.component(.minute, from: Date())
    var seconds: Int = Calendar.current.component(.second, from: Date())
}

    
#Preview {
    WatchView(initialTime: Time())
}
