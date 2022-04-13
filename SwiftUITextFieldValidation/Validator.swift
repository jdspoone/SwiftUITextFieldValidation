/*
    Validator.swift
    Lambda Recipes

    Created by Jeff Spooner on 2022-04-12.    
*/

import Foundation
import SwiftUI


class Validator<T: Hashable>: ObservableObject
  {
    @Published private var validStates: [T: Bool] = [:]

    public var isValid: Bool
      {
        var isValid = true

        for (_, validState) in validStates {
          isValid = isValid && validState
        }

        return isValid
      }


    public func reset() -> Void
      {
        validStates.removeAll()
      }


    public func bindingFor(identifier: T) -> Binding<Bool>
      {
        // Ensure we have an entry for the given identifier
        if validStates[identifier] == nil {
          validStates[identifier] = true
        }

        return Binding(get: { self.validStates[identifier]! }, set: { newValue in self.validStates[identifier] = newValue })
      }
  }
