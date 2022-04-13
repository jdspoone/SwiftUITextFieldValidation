/*
    ItemNameTextField.swift
    SwiftUITextFieldValidation

    Created by Jeff Spooner on 2022-04-12.

    ItemNameTextField is a SwiftUI View presenting a WrappedTextField configured
    to present and modify the name property of an Item.

    The EventHandler class declared within implements the TextFieldEventHandler
    protocol for this specific use case. Please note that its scope is limited
    to the enclosing View.
*/

import SwiftUI


struct ItemNameTextField: View
  {
    let item: Item
    let validator: Validator<String>

    let eventHandler: EventHandler

    @Binding var editMode: EditMode


    init(item: Item, validator: Validator<String>, editMode: Binding<EditMode>)
      {
        self.item = item
        self.validator = validator

        self.eventHandler = EventHandler(item: item)

        _editMode = editMode
      }


    var body: some View
      {
        WrappedTextField<EventHandler>(id: "name", initialText: item.name, textStyle: .title1, alignment: .left, keyboardType: .default, validator: validator, eventHandler: eventHandler)
          .environment(\.editMode, $editMode)
          .border(.gray, width: editMode.isEditing ? 0.75 : 0)
      }


    // MARK: -

    class EventHandler: TextFieldEventHandler
      {
        var item: Item


        init(item: Item)
          {
            self.item = item
          }


        func validateText(_ text: String) -> Bool
          {
            // Trim all whitespace from the given text
            let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)

            // The empty string is an invalid Item name
            return !trimmedText.isEmpty
          }


        func endEditingWith(_ text: String) -> Void
          {
            // Update the Recipe's name
            item.name = text
          }


        func cancelEditing(_ textField: UITextField)
          {
            // Restore the initial ingredient name
            textField.text = item.name
          }
      }

  }
