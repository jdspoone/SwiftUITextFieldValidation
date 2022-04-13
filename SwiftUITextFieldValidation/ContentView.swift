/*
    ContentView.swift
    SwiftUITextFieldValidation

    Created by Jeff Spooner on 2022-04-12.
*/

import SwiftUI


struct ContentView: View
  {
    @Environment(\.managedObjectContext) var context

    @State var editMode: EditMode = .inactive


    var body: some View
      {
        NavigationView
          {
            ItemList(editMode: $editMode)
              .navigationTitle("Items")
              .navigationBarTitleDisplayMode(.inline)
          }
      }
  }


struct ContentView_Previews: PreviewProvider
  {
    static var previews: some View
      {
        let dataStore = DataStore(options: [.preview, .addSampleData])

        ContentView()
          .environment(\.managedObjectContext, dataStore.managedObjectContext)
      }
  }
