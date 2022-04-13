/*
    ItemView.swift
    SwiftUITextFieldValidation

    Created by Jeff Spooner on 2022-04-12.
*/

import SwiftUI


struct ItemView: View
  {
    @Environment(\.managedObjectContext) var context


    @StateObject var item: Item
    @StateObject var validator: Validator<String>

    @State var editMode: EditMode


    init(item: Item, editMode: EditMode)
      {
        _item = StateObject(wrappedValue: item)
        _validator = StateObject(wrappedValue: Validator())
        _editMode = State(initialValue: editMode)
      }


    var body: some View
      {
        List {
          ItemNameTextField(item: item, validator: validator, editMode: $editMode)
        }
          .navigationTitle(item.name)
          .navigationBarTitleDisplayMode(.inline)
          .editingToolbar(editMode: $editMode,
                          cancelAction: {
                            // Discard any pending changes
                            context.rollback()

                            // Post a WillCancelEditing notification, signalling the active textField to revert any changes
                            NotificationCenter.default.post(name: NSNotification.Name.DidCancelEditing, object: nil)

                            // Reset the validator
                            validator.reset()
                          },
                          saveAction: {
                            // Post a WillEndEditing notification, signalling the active textField to endEditing
                            NotificationCenter.default.post(name: NSNotification.Name.WillEndEditing, object: nil)

                            // Save any pending changes
                            do { try context.save() }
                            catch { print("Failed to save with error: \(error)") }
                          },
                          disableSave: !validator.isValid)
      }
  }


struct ItemView_Previews: PreviewProvider
  {
    static var previews: some View
      {
        let dataStore = DataStore(options: [.preview, .addSampleData])
        let item = dataStore.items.first!

        ItemView(item: item, editMode: .inactive)
      }
  }
