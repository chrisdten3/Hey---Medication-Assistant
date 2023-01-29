//
//  ContentView.swift
//  againig
//
//  Created by Chris Tengey on 12/29/22.
//

import SwiftUI
import UserNotifications
import Foundation
import Combine

class NotificationManager {
    
    static let instance = NotificationManager()
    
    func requestAuthorization() {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { (success, error) in
            if let error = error {
                print("ERROR : \(error)")
            } else {
                print("SUCCESS")
            }
        }
    }
    
    func scheduleNotification() {
        
        let content = UNMutableNotificationContent()
        content.title = "It is time!"
        content.subtitle = "Return to the app"
        content.sound = .default
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 61.0 , repeats: true)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString,
                                            content: content,
                                            trigger: trigger)
        UNUserNotificationCenter.current().add(request)
        
    }
    
    func cancelNotification() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
}



struct SlideOneView: View {
    
    @State private var user = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                VStack {
                    SlideOne()
                    
                           TextField("Name", text: $user)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                        .onAppear{
                            NotificationManager.instance.requestAuthorization()
                        }
                    
                    NavigationLink(destination: SlideTwoView(name: user), label: {Text("Submit")
                            .bold()
                            .frame(width: 200, height: 50)
                            .background(Color(.white))
                            .foregroundColor(.gray)
                            .cornerRadius(10)
                    })
                }
                
            }
        }
    }
}

struct SlideTwoView: View {
    @State private var med = ""
    
    var name: String
    var body: some View {
        
        ZStack {
            Color.black.ignoresSafeArea()
            VStack {
                
                Text("So... \(name), what are you taking?")
                    .font(.system(size: 100, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.1)
                
                TextField("Medication", text: $med)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                NavigationLink(destination: SlideThreeView(name: name, med: med), label: {Text("Submit")
                        .bold()
                        .frame(width: 200, height: 50)
                        .background(Color.white)
                        .foregroundColor(.gray)
                        .cornerRadius(10)
                })
            }
        }
        
    }
}


struct SlideThreeView: View {
    @State private var time = 0
    @State private var showMedicationAlert: Bool = false
    @State private var mins = 0
    
    
    var name: String
    var med: String
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack {
                Text(" \(name), in how long do you need to take \(med)?")
                    .font(.system(size: 100, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.1)
                TextField("Time in hours", value: $time, formatter: NumberFormatter())
                    .keyboardType(UIKeyboardType.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Time in minutes", value: $mins, formatter: NumberFormatter())
                    .keyboardType(UIKeyboardType.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                NavigationLink(destination: Freak(hours: time, minutes: mins, med: med), label: {Text("Next Screen")
                        .bold()
                        .frame(width: 200, height: 50)
                        .background(Color.white)
                        .foregroundColor(.gray)
                        .cornerRadius(10)
                    
                })
            }
        }
    }
}


struct Freak: View {
    var hours: Int
    var minutes: Int
    var med: String
    
    let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    
    @State var timeRemaining : String = ""
    @State var finishedText: String? = nil
    @State var ConnectedTimer: Cancellable? = nil
    @State var state: Bool = false

    
    var futureDate: Date
    
    init(hours: Int, minutes: Int, med: String) {
        self.med = med
        self.hours = hours
        self.futureDate = Calendar.current.date(byAdding: .hour, value: hours, to: Date()) ?? Date()
        self.minutes = minutes
        var dateComponents = DateComponents()
        dateComponents.hour = hours
        dateComponents.minute = minutes
        self.futureDate = Calendar.current.date(byAdding: dateComponents, to: Date()) ?? Date()
    }
    
    
    func updateTimeRemaining() -> Void {
        let remaining = Calendar.current.dateComponents([.hour, .minute, .second], from: Date(), to: futureDate)
        let hour = remaining.hour ?? 0
        let minute = remaining.minute ?? 0
        let second = remaining.second ?? 0
        timeRemaining = "\(hour) hours, \(minute) minutes, \(second) seconds"
        
        if hour == 0 && minute == 0 && second == 0 {
            timer.upstream.connect().cancel()
            finishedText = "You Should Take Your \(med) Now"
            NotificationManager.instance.scheduleNotification()
            timeRemaining = finishedText!
            return
        }
        
        
        if state == true {
            timer.upstream.connect().cancel()
            finishedText = "Great You've Taken Your \(med)"
        }
        
    }
    
    @ViewBuilder
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack {
                Text(finishedText ?? "\(timeRemaining)")
                    .font(.system(size: 100, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.1)
                    .onReceive(timer, perform: {_ in
                        updateTimeRemaining()
                    })
                
                
                VStack {
                    Button ("I've Taken my Meds") {
                        NotificationManager.instance.cancelNotification()
                        state = true
                        self.ConnectedTimer?.cancel()
                        UIApplication.shared.applicationIconBadgeNumber = 0
                    }
                    .bold()
                    .frame(width: 200, height: 50)
                    .background(Color.white)
                    .foregroundColor(.gray)
                    .cornerRadius(10)
                }
            }
        }
    }
}

struct RandomView: View {
    var body: some View {
        ZStack {
            Text("Great!")
                .font(.system(size: 100, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.1)
            
                .onAppear {
                    UIApplication.shared.applicationIconBadgeNumber = 0
                }
        }
    }
}

struct SlideOne: View {
    var body: some View {
        Text("hey what is your name?")
            .font(.system(size: 100, weight: .semibold, design: .rounded))
            .foregroundColor(.white)
            .lineLimit(1)
            .minimumScaleFactor(0.1)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SlideOneView()
    }
}
