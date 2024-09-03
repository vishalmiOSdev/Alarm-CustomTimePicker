//
//  AlarmListView.swift
//  ClassicWatch
//
//  Created by Vishal Manhas on 29/08/24.
//

import SwiftUI
import CoreData

struct AlarmListView: View {
    @State private var addAlarmClick: Bool = false
    @State private var selectedAlarm: AlarmList? = nil
    @State private var alarms: [AlarmList] = []
    @State private var isEditing: Bool = false
    @State private var showDeleteAlert: Bool = false
    
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        NavigationStack {
            VStack {
                if alarms.isEmpty {
                    NoAlarmsView(onAdd: {
                        addAlarmClick.toggle()
                    })
                } else {
                    List {
                        ForEach(alarms) { alarm in
                            Button(action: {
                                selectedAlarm = alarm
                            }) {
                                AlarmListCell(
                                    isOn: Binding(
                                        get: { alarm.isActiveAlarm },
                                        set: { newValue in
                                            CoreDataManager.shared.updateAlarm(
                                                alarm: alarm,
                                                time: "Updated Time",
                                                label: alarm.alarmDiscription ?? "",
                                                isActive: newValue,
                                                date: alarm.date,
                                                day: alarm.day
                                            )
                                            fetchAlarms() // Refresh the list
                                        }
                                    ),
                                  
                                    alarm: alarm
                                )
                            }
                            .listRowSeparator(.hidden)
                        }
                        .onDelete(perform: deleteAlarms) // Enable swipe-to-delete
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Alarm")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button {
                        if isEditing && alarms.isEmpty {
                            showDeleteAlert = true
                        } else {
                            isEditing.toggle()
                        }
                    } label: {
                        Text(isEditing ? "Done" : "Edit")
                            .fontWeight(.semibold)
                            .foregroundColor(.red)
                    }
                }
                
                ToolbarItemGroup(placement: .topBarTrailing) {
                    if isEditing {
                        Button(action: {
                            if alarms.isEmpty {
                                showDeleteAlert = true
                            }
                        }) {
                            Text("Delete all")
                                .fontWeight(.semibold)
                                .foregroundColor(.red)
                        }
                    }else{
                        
                        Image(systemName: "plus")
                            .fontWeight(.semibold)
                            .foregroundColor(.red)
                            .onTapGesture {
                                addAlarmClick.toggle()
                            }
                        
                    }
                }
            }
            .sheet(isPresented: $addAlarmClick) {
                let currentHour = Calendar.current.component(.hour, from: Date())
                let currentMinute = Calendar.current.component(.minute, from: Date())

                WatchView(initialTime: Time(hours: currentHour, minutes: currentMinute)) { time, formattedTime in
                    CoreDataManager.shared.addAlarm(time: formattedTime, label: "New Alarm", isActive: true, date: Date(), day: nil)
                    fetchAlarms() // Refresh the list
                }
            }
            .sheet(item: $selectedAlarm) { alarm in
                WatchView(initialTime: Time(hours: Int(alarm.hours), minutes: Int(alarm.minutes))) { time, formattedTime in
                    CoreDataManager.shared.updateAlarm(alarm: alarm, time: formattedTime, label: alarm.alarmDiscription ?? "", isActive: alarm.isActiveAlarm, date: alarm.date, day: alarm.day)
                    fetchAlarms() // Refresh the list
                }
            }
            .onAppear {
                fetchAlarms()
            }
            .alert(isPresented: $showDeleteAlert) {
                Alert(
                    title: Text("Are you sure?"),
                    message: Text("Do you want to delete all alarms?"),
                    primaryButton: .destructive(Text("Delete")) {
                        deleteAllAlarms()
                    },
                    secondaryButton: .cancel {
                        isEditing = false
                    }
                )
            }
        }
    }
    
    private func fetchAlarms() {
        let fetchRequest: NSFetchRequest<AlarmList> = AlarmList.fetchRequest()
        do {
            alarms = try viewContext.fetch(fetchRequest)
            print("Fetched alarms: \(alarms.count)")
        } catch {
            print("Error fetching alarms: \(error)")
        }
    }
    
    private func addAlarm() {
        let newAlarm = AlarmList(context: viewContext)
        newAlarm.id = UUID()
        newAlarm.alarmDiscription = "New Alarm"
        newAlarm.isActiveAlarm = true

        do {
            try viewContext.save()
            fetchAlarms()
        } catch {
            print("Error saving alarm: \(error)")
        }
    }
    
    private func deleteAlarms(at offsets: IndexSet) {
        for index in offsets {
            let alarm = alarms[index]
            viewContext.delete(alarm)
        }
        
        do {
            try viewContext.save()
            fetchAlarms()
        } catch {
            print("Error deleting alarms: \(error)")
        }
    }
    
    private func deleteAllAlarms() {
        let fetchRequest: NSFetchRequest<AlarmList> = AlarmList.fetchRequest()
        let allAlarms = try? viewContext.fetch(fetchRequest)
        
        allAlarms?.forEach { alarm in
            viewContext.delete(alarm)
        }
        
        do {
            try viewContext.save()
            fetchAlarms()
        } catch {
            print("Error deleting all alarms: \(error)")
        }
    }
}



struct AlarmListView_Previews: PreviewProvider {
    static var previews: some View {
        AlarmListView()
            .environment(\.managedObjectContext, CoreDataManager.shared.persistentContainer.viewContext)
    }
}
