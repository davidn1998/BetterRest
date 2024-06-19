//
//  ContentView.swift
//  BetterRest
//
//  Created by David Nwachukwu on 18/06/2024.
//

import CoreML
import SwiftUI

struct ContentView: View {
	@State private var wakeUp = defaultWakeTime
	@State private var sleepAmount = 8.0
	@State private var coffeeAmount = 1
	
	@State private var alertTitle = ""
	@State private var alertMessage = ""
	@State private var showingAlert = false
	
	@State private var idealBedtime = ""
	
	static var defaultWakeTime: Date {
		var components = DateComponents()
		components.hour = 7
		components.minute = 0
		return Calendar.current.date(from: components) ?? Date.now
	}
	
	var body: some View {
		NavigationStack {
			ZStack {
				Color(.systemBackground)
				
				Form {
					Section {
						Text("When do you want to wake up?")
							.font(.headline)
						
						DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
							.labelsHidden()
					}
					.padding(.vertical, 10)
					
					Section {
						Text("Desired amount of sleep")
							.font(.headline)
						
						Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
					}
					.padding(.vertical, 10)
					
					Section {
						Text("Daily coffee intake")
							.font(.headline)
						
						Stepper(coffeeAmount == 1 ? "1 cup" : "\(coffeeAmount) cups", value: $coffeeAmount, in: 1...20)
					}
					.padding(.vertical, 10)
					
				}
				.padding(.top, 20)
			}
			.navigationTitle("BetterRest")
			.alert(alertTitle, isPresented: $showingAlert) {
				Button("OK") {}
			} message: {
				Text(alertMessage)
			}
			
			Text("Ideal Bedtime:  \(idealBedtime)")
				.padding(.vertical, 20)
				.font(.title)
				.bold()
		}
		.onAppear(perform: self.calculateBedtime)
		.onChange(of: wakeUp, calculateBedtime)
		.onChange(of: sleepAmount, calculateBedtime)
		.onChange(of: coffeeAmount, calculateBedtime)
		
	}
	
	func calculateBedtime() {
		do {
			let config = MLModelConfiguration()
			let model = try SleepCalculator(configuration: config)
			
			let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
			let hour = (components.hour ?? 0) * 3600
			let minute = (components.minute ?? 0) * 60
			
			let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
			
			let sleepTime = wakeUp - prediction.actualSleep
			
			idealBedtime = sleepTime.formatted(date: .omitted, time: .shortened)
		} catch {
			alertTitle = "Error"
			alertMessage = "Sorry, there was a problem calculating your bedtime"
			
			showingAlert = true
		}
	}
	
}

#Preview {
	ContentView()
}
