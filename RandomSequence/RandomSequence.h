//
//  RandomSequence.h
//
//  Version 1.0
//
//  Created by Nick Lockwood on 25/02/2012.
//  Copyright (c) 2012 Charcoal Design
//
//  Distributed under the permissive zlib License
//  Get the latest version from here:
//
//  https://github.com/nicklockwood/RandomSequence
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//

#import <Foundation/Foundation.h>

@interface RandomSequence : NSObject <NSCoding, NSCopying>

@property (nonatomic, assign) uint64_t seed;

+ (instancetype)defaultSequence;
+ (instancetype)sequenceWithSeed:(uint64_t)seed;

- (double)value;
- (double)nextValue;
- (NSUInteger)nextIntegerInRange:(NSRange)range;
- (NSInteger)nextIntegerFrom:(NSInteger)from to:(NSInteger)to;

@end


@interface NSArray (RandomSequence)

- (NSUInteger)randomIndexWithSequence:(RandomSequence *)sequence;
- (id)randomObjectWithSequence:(RandomSequence *)sequence;
- (NSArray *)shuffledArrayWithSequence:(RandomSequence *)sequence;

@end


@interface NSMutableArray (RandomSequence)

- (void)shuffleWithSequence:(RandomSequence *)sequence;

@end