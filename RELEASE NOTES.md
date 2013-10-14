Version 1.0.1

- The seed value is now of type uint32_t instead of uint64_t, which makes it a bit easier to work with (this doesn't affect the algorithm, or generated values)
- The default seed is now generated using arc4random(), so that multiple RandomSequences created at the same time will each have different seeds
- Seed setter now automatically wraps value to an acceptable range
- Magic numbers are now magic constants instead :-)
- Added unit tests

Version 1.0

- Initial release.