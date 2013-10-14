Purpose
--------------

RandomSequence is a simple library for generating repeatable pseudorandom number sequences on Mac and iOS. Unlike the C random functions such as rand() and arc4random(), it is easy to create multiple RandomSequence instances that operate independently and can be individually set/reset to a known state.


Supported OS & SDK Versions
-----------------------------

* Supported build target - iOS 7.0 / Mac OS 10.8 (Xcode 5.0, Apple LLVM compiler 5.0)
* Earliest supported deployment target - iOS 5.0 / Mac OS 10.7
* Earliest compatible deployment target - iOS 4.3 / Mac OS 10.6

NOTE: 'Supported' means that the library has been tested with this version. 'Compatible' means that the library should work on this OS version (i.e. it doesn't rely on any unavailable SDK features) but is no longer being tested for compatibility and may require tweaking or bug fixes to run correctly.


ARC Compatibility
------------------

RandomSequence is compatible with both ARC and non-ARC compile targets.


Thread Safety
--------------

Any given RandomSequence instance should only be accessed from a single thread, however it is safe to use multiple RandomSequence instances on different threads concurrently.


Installation
--------------

To use the RandomSequence class in an app, just drag the RandomSequence class files (any demo files or assets are not needed) into your project.


Properties
--------------

The RandomSequence class has a single property:

	@property (nonatomic, assign) uint32_t seed;

The seed value represents the current state of the sequence. It is used to generate the value returned by the `value` method, and to calculate the next seed. When you create a new RandomSequence instance, the seed is automatically set to an arbitrary value generated using arc4random(), so the sequence will be unique for each instance that is created. To create a repeatable sequence, set the seed to a known value before use. To save and restore the state of a given sequence to a particular point, just record the current seed value and restore it later. The seed value must be between 0 and 233280, but larger values will be automatically wrapped to that range.


Methods
--------------

The RandomSequence class has the following methods:

	+ (instancetype)defaultSequence;
	
This method returns the shared default sequence, initialised using the current time at the point when it was first called.
	
    + (instancetype)sequenceWithSeed:(uint32_t)seed;
    
This method returns a new, autoreleased RandomSequence instance with the specified seed value.

    - (double)value;

This method returns the current sequence value, which is a double precision floating point number in the range 0.0 - 1.0 (note that the value will always be slightly less than 1.0, so `floor(value)` will always be zero, and `floor(value * SOME_POSITIVE_INTEGER)` will never exceed `SOME_POSITIVE_INTEGER - 1`, which is useful for creating random array indexes.

    - (double)nextValue;
    
This method returns the current pseudorandom sequence value, just like the `value` method, however in addition to returning the value, it also advances the seed to the next value in the sequence. Calling `nextValue` repeatedly will therefore return a new pseudorandom value each time.
    
    - (NSUInteger)nextIntegerInRange:(NSRange)range;
    
This method returns a random positive integer in the specified range. Like `nextValue`, this method advances the seed to the next value in the sequence, so calling this method repeatedly will return a new value each time. 
    
    - (NSInteger)nextIntegerFrom:(NSInteger)from to:(NSInteger)to;

This method returns a random integer in the specified range. Unlike `nextIntegerInRange:`, the from and to values can be negative and to can be less than from. Like `nextValue`, this method advances the seed to the next value in the sequence, so calling this method repeatedly will return a new value each time. 


NSArray Extensions
---------------

RandomSequence extends NSArray with the following category methods:

    - (NSUInteger)randomIndexWithSequence:(RandomSequence *)sequence;
    
This method returns a random index within the array using the specified sequence object. Like the RandomSequence `nextValue`, this method advances the seed to the next value in the sequence, so calling this method repeatedly with the same sequence instance will return a different index each time. 
    
    - (id)randomObjectWithSequence:(RandomSequence *)sequence;
    
This method returns a random object within the array using the specified sequence object. Like the RandomSequence `nextValue`, this method advances the seed to the next value in the sequence, so calling this method repeatedly with the same sequence instance will return a different object each time.
 
    - (NSArray *)shuffledArrayWithSequence:(RandomSequence *)sequence;
    
This method shuffles the array using the specified sequence object. Internally this calls the RandomSequence `nextValue` method repeatedly, so the seed of the sequence will be modified, and calling this method repeatedly with the same sequence instance will return a different array order each time.


NSMutableArray Extensions
-----------------------------

RandomSequence extends NSMutableArray with the following category methods:

    - (void)shuffleWithSequence:(RandomSequence *)sequence;

This method shuffles the array using the specified sequence object. Internally this calls the RandomSequence `nextValue` method repeatedly, so the seed of the sequence will be modified.


Protocols
------------------

RandomSequence conforms to the NSCopying and NSCoding protocols. This allows you to make a copy of a sequence at a particular point (e.g. if you want to be able to repeat the same sequence later) and/or save it to disk so that the sequence can resume from the same point at a later date.


Algorithm
------------------

The random number generating algorithm is fairly simple. Each new seed is generated from the previous value using the following function:

    _seed = (_seed * 9301 + 49297) % 233280;
    
This provides a reasonably random sequence that can be easily recreated using any programming language that supports 32-bit integer math, which is handy if you want to replicate the sequence logic on the server-side.