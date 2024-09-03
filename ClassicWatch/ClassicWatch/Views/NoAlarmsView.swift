//
//  NoAlarmsView.swift
//  ClassicWatch
//
//  Created by Vishal Manhas on 02/09/24.
//

import SwiftUI

struct NoAlarmsView: View {
    var onAdd: () -> Void  // Closure to handle the add action

    var body: some View {
        VStack {
            Image(systemName: "bell.slash.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.gray)
                .padding(.bottom, 20)
            
            Text("No Alarms Added")
                .font(.title)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
                .padding(.bottom, 10)
            
            Text("Please click the button below to add a new alarm.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.bottom, 30)
            
            Button(action: {
                onAdd()
            }) {
                Text("Add Alarm")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 40)
        }
        .padding()
    }
}


#Preview {
    NoAlarmsView(onAdd: {
    print("")})
}
