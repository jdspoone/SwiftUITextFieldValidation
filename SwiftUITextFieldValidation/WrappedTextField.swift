/*
    WrappedTextField.swift
    RecipeBook

    Created by Jeff Spooner on 2022-03-20.

    WrappedTextField presents a UITextField for use in a SwiftUI View. This struct can be
    used to present and modify the string-representable properties of NSManagedObjects, while
    ensuring that the entered text is valid for that property.

    WrappedTextField is parameterized by an an object conforming to the TextFieldEventHandler
    protcol, which serves the following purposes:

      1. Validates the text of the UITextField before any attempt is made to modify the represented managed property
      2. Updates the represented managed property when changes are saved
      3. Reverts the text of the UITextField to the initial value of the managed property when changes are cancelled
*/

import SwiftUI
import CoreData


extension NSNotification.Name
  {
    static let WillEndEditing = Notification.Name(rawValue: "WillEndEditing")
    static let DidCancelEditing = Notification.Name(rawValue: "DidCancelEditing")
  }


// MARK: -

protocol TextFieldEventHandler
  {
    func validateText(_: String) -> Bool
    func endEditingWith(_: String) -> Void
    func cancelEditing(_: UITextField) -> Void
  }


// MARK: -

struct WrappedTextField<T: TextFieldEventHandler>: UIViewRepresentable
  {
    var id: String
    var initialText: String
    var textStyle: UIFont.TextStyle
    var alignment: NSTextAlignment
    var keyboardType: UIKeyboardType
    var validator: Validator<String>
    var eventHandler: T


    func makeUIView(context: Context) -> UITextField
      {
        let textField = UITextField()
        textField.delegate = context.coordinator
        textField.text = initialText
        textField.font = UIFont.preferredFont(forTextStyle: textStyle)
        textField.textAlignment = alignment
        textField.keyboardType = keyboardType
        textField.returnKeyType = .done

        return textField
      }


    func makeCoordinator() -> Coordinator<T>
      {
        return Coordinator(id: id, eventHandler: eventHandler, validator: validator)
      }


    func updateUIView(_ textField: UITextField, context: Context)
      {
        let isEditing = context.environment.editMode!.wrappedValue.isEditing

        // To prevent cycles, wrap all modifications to the text field in an async block
        DispatchQueue.main.async {
          textField.isUserInteractionEnabled = isEditing
        }
      }


    // MARK: -

    class Coordinator<T: TextFieldEventHandler>: NSObject, UITextFieldDelegate
      {
        var id: String
        var eventHandler: T
        var validator: Validator<String>

        init(id: String, eventHandler: T, validator: Validator<String>)
          {
            self.id = id
            self.eventHandler = eventHandler
            self.validator = validator
          }


        // MARK: UITextFieldDelegate

        func textFieldDidBeginEditing(_ textField: UITextField)
          {
            // The active text field should resign first responder prior to changes being saved
            NotificationCenter.default.addObserver(forName: NSNotification.Name.WillEndEditing, object: nil, queue: .main) { _ in
              textField.resignFirstResponder()
            }

            NotificationCenter.default.addObserver(forName: NSNotification.Name.DidCancelEditing, object: nil, queue: .main) { _ in
              // The event handler must restore the textField to its initial state after receiving the DidCancelEditing notification
              self.eventHandler.cancelEditing(textField)

              // Tear down the observation for DidCancelEditing
              NotificationCenter.default.removeObserver(self, name: NSNotification.Name.DidCancelEditing, object: nil)
            }
          }


        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
          {
            // Generate the proposed text
            var proposedText = textField.text!
            proposedText.replaceSubrange(Range(range, in: textField.text!)!, with: string)

            // Update the binding for the valid state of the textfield
            let binding = validator.bindingFor(identifier: id)
            binding.wrappedValue = eventHandler.validateText(proposedText)

            // Always return true
            return true
          }



        func textFieldShouldReturn(_ textField: UITextField) -> Bool
          {
            // Defer to the event handler's validateText method
            if let text = textField.text {
              return eventHandler.validateText(text)
            }

            return false
          }


        func textFieldShouldEndEditing(_ textField: UITextField) -> Bool
          {
            // Defer to the event handler's validateText method
            if let text = textField.text {
              return eventHandler.validateText(text)
            }

            return false
          }


        func textFieldDidEndEditing(_ textField: UITextField)
          {
            guard let text = textField.text, text.isEmpty == false else { fatalError("unexpected state") }

            // De-register to observe notifications for WillEndEditing
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.WillEndEditing, object: nil)

            // Execute the event handler's endEditing function
            eventHandler.endEditingWith(text)
          }
      }
  }
