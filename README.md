#  README

This Xcode project demonstrates a solution for validating the input of text fields in a SwiftUI app.

---

Validation of text fields within a SwiftUI app often becomes a substantial problem, particularly when the represented model objects are reference-types such as NSManagedObject subclasses. Two specific problems arise, namely:

* Validating the contents of text fields, and updating the represented model object appropriately, and
* Preventing attempts to save while any text fields are in an invalid state

ParseableFormatStyle does allow for validation of SwiftUI TextFields, however this protocol is limited due to its requirement that conforming types must also conform to Decodable and Encodable, making it complicated to pass in external state. For example if your validation process requires any interaction with an NSManagedObjectContext instance, successfully getting that context into your custom format style becomes messy.

Subclassing Formatter (previously NSFormatter) has the potential to solve the validation problem as well, but is something of a non-starter as the process is quite complicated and intimidating right from the get-go. I have chosen not to pursue this route with any seriousness because we still have access to UIKit, which I believe is an altogether nicer solution.

Even though we are building a SwiftUI app, we do still have access to UIKit's UITextField, and thus UITextFieldDelegate, through the UIViewRepresentable protocol. Using this protocol we can use a UITextField within a SwiftUI View, and configure the Coordinator of the UIViewRepresentable to be the delegate of that text field. If you are unfamiliar with UITextFieldDelegate, this protocol allows conforming objects to respond to a variety of events for some text field. The UIViewRepresentable is also initialized with an object conforming to the custom protocol EventHandler. The conforming object implements methods for validating text and responding to end-editing events, with logic specific to the particular type of text field. These methods are then called by the delegate of the text field in response to various events.

The delegate of the text field also interacts with an instance of Validator, which is a custom class that maintains a dictionary of the validity state of text fields in your app. Instances of this class are parameterized with a Hashable type, resulting in greater flexibility for what you can key the dictionary with. Other parts of your app do not access the dictionary of valid states directly, instead they use a public method to access a dynamically generated Binding to a dictionary entry for some identifier. The Validator also has a derived property to return the overall valid state of all connected text fields via the conjuction of all dictionary entries. This can be used to prevent attempts to save while any text fields have invalid text, by binding this property to the enabled state of your application's end-editing button.
