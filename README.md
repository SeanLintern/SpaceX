# SpaceX

The intended architecture is MVVM-C with an FRP approach without importing any RX or binding. This resulted in some potentially confusing view models but still performed the way I intended it.

View models have a basic structure of Inputs + Outputs using protocols for implementation obfuscation. Generally results in a high test coverage and easy to test with data traceability.

Coordinators are event driven with a clear testable state machine.

Unit tests cover view models, models, utility classes and the image caching helper.

Image caching based on the lastPathComponent of the URL but no expiration.

90%+ Test coverage.
