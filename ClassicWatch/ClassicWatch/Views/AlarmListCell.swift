//
//  AlarmListCell.swift
//  ClassicWatch
//
//  Created by Vishal Manhas on 30/08/24.
//

import SwiftUI

struct AlarmListCell: View {
    @Binding var isOn: Bool
  
    let alarm: AlarmList

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\(alarm.hours):\(String(format: "%02d", alarm.minutes))")
                    .font(.largeTitle)
                    .fontWeight(.light)
                
                Text(alarm.alarmDiscription ?? "No Label")
                    .fontWeight(.thin)
              
                if let date = alarm.date {
                    Text("Date: \(formattedDate(date))")
                        .font(.caption)
                        .foregroundColor(.gray)
                } else {
                    Text(alarm.day ?? "No Days")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            HStack {
             
                    Toggle("", isOn: $isOn)
                        .labelsHidden()
                        .tint(.red)
                        .onChange(of: isOn) { newValue in
                            if newValue {
                                print("Toggle is ON")
                            } else {
                                print("Toggle is OFF")
                            }
                        }
                }
            
        }
        .padding(.leading, 2)
        .padding(.trailing, 2)
        .frame(maxWidth: .infinity)
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}
