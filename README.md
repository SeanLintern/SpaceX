# SpaceX

The intended architecture is MVVM-C with an FRP approach without importing any RX or binding. This resulted in some potentially confusing view models but still performed the way I intended it.

View models have a basic structure of Inputs + Outputs using protocols for implementation obfuscation. Generally results in a high test coverage and easy to test with data traceability. Using the flow handler a 'Factory' would map the resulting flow of a view model to a coordinator, this means that, to adapt a VM+Screen to a new coordinator, you just write a new factory adapter method and map events for the new coordinator. View models should follow a simple pattern, inputs from the UI, get transformed into streamed events to output some kind of action / data.

Coordinators are event driven with a clear testable state machine.

Unit tests cover view models, models, utility classes and the image caching helper.

Image caching based on the lastPathComponent of the URL but no expiration.

90%+ Test coverage.

Some simple UITests using accessibility identifier finding and some value mapping of expected values. All through the UITest helper to ensure screens are loaded directly.
