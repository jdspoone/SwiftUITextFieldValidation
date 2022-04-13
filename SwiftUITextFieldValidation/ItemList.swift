/*
  ItemList.swift
  SwiftUITextFieldValidation

  Created by Jeff Spooner on 2022-04-12.
*/

import SwiftUI


struct ItemList: View
  {
    @Environment(\.managedObjectContext) var context

    @FetchRequest var items: FetchedResults<Item>

    @Binding var editMode: EditMode


    init(editMode: Binding<EditMode>)
      {
        _items = FetchRequest<Item>(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)], predicate: nil, animation: nil)

        _editMode = editMode
      }


    var body: some View
      {
        List {
          Section {
            ForEach(items) { item in
              NavigationLink(destination: {
                ItemView(item: item, editMode: editMode)
              }, label: {
                Text("\(item.name)")
              })
            }
          }
        }
      }
  }


struct ItemList_Previews: PreviewProvider
  {
    static var previews: some View
      {
        let dataStore = DataStore(options: [.preview, .addSampleData])

        ItemList(editMode: .constant(.inactive))
          .environment(\.managedObjectContext, dataStore.managedObjectContext)
      }
  }
