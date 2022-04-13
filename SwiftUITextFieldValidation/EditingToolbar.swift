/*
    EditingToolbar.swift
    SwiftUITextFieldValidation

    Created by Jeff Spooner on 2022-04-12.
*/

import SwiftUI


struct EditingToolbar: ViewModifier
  {
    @Binding var editMode: EditMode

    var cancelAction: (() -> Void)?
    var saveAction: () -> Void
    var disableSave: Bool


    init(editMode: Binding<EditMode>, cancelAction: (() -> Void)? = nil, saveAction: @escaping () -> Void, disableSave: Bool)
      {
        _editMode = editMode
        self.cancelAction = cancelAction
        self.saveAction = saveAction
        self.disableSave = disableSave
      }


    func body(content: Content) -> some View
      {
        content
          .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
              if editMode.isEditing {
                Button(role: .cancel, action: {
                  // Update editMode
                  editMode = .inactive
                  // Execute the cancelAction, if it exists
                  if let cancelAction = cancelAction {
                    cancelAction()
                  }
                }, label: {
                  Text("Cancel")
                })
              }
            }
            ToolbarItemGroup(placement: .navigationBarTrailing) {
              Button (action: {
                if editMode.isEditing {
                  saveAction()
                }
                editMode = editMode.isEditing ? .inactive : .active
              }, label: {
                Text(editMode.isEditing ? "Done" : "Edit")
              })
                .disabled(disableSave)
            }
          }
          .navigationBarBackButtonHidden(editMode.isEditing)
      }
  }


extension View
  {
    func editingToolbar(editMode: Binding<EditMode>, cancelAction: (() -> Void)? = nil, saveAction: @escaping () -> Void, disableSave: Bool = false) -> some View
      {
        modifier(EditingToolbar(editMode: editMode, cancelAction: cancelAction, saveAction: saveAction, disableSave: disableSave))
      }
  }
