/*
    SwiftUITextFieldValidationApp.swift
    SwiftUITextFieldValidation

    Created by Jeff Spooner on 2022-04-12.
*/

import SwiftUI


@main
struct SwiftUITextFieldValidationApp: App
  {
    private let dataStore = DataStore(options: ProcessInfo.processInfo.arguments.contains("--reset-store") ? [.resetStore, .addSampleData] : [])


    var body: some Scene
      {
        WindowGroup
          {
            ContentView()
              .environment(\.managedObjectContext, dataStore.managedObjectContext)
          }
      }
  }
