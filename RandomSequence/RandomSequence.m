//
//  RandomSequence.m
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

#import "RandomSequence.h"

@implementation RandomSequence

+ (RandomSequence *)defaultSequence
{
    static RandomSequence *defaultSequence = nil;
    if (defaultSequence == nil)
    {
        defaultSequence = [[self alloc] init];
    }
    return defaultSequence;
}

+ (instancetype)sequenceWithSeed:(uint64_t)seed
{
    RandomSequence *sequence = [[self alloc] init];
    sequence.seed = seed;
    return sequence;
}

- (RandomSequence *)init
{
    if ((self = [super init]))
    {
        NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
        _seed = (uint64_t)(interval * 1000.0) % 233280;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super init]))
    {
        _seed = [aDecoder decodeInt64ForKey:@"seed"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt64:_seed forKey:@"seed"];
}

- (id)copyWithZone:(NSZone *)zone
{
    RandomSequence *sequence = [[[self class] allocWithZone:zone] init];
    sequence.seed = _seed;
    return sequence;
}

- (double)value
{
    return _seed / 233280.0;
}

- (double)nextValue
{
    _seed = (_seed * 9301 + 49297) % 233280;
    return [self value];
}

- (NSUInteger)nextIntegerInRange:(NSRange)range
{
    return floor([self nextValue] * (double)range.length) + range.location;
}

- (NSInteger)nextIntegerFrom:(NSInteger)from to:(NSInteger)to
{
    return floor([self nextValue] * (double)(to - from)) + from;
}

@end


@implementation NSArray (RandomSequence)

- (NSUInteger)randomIndexWithSequence:(RandomSequence *)sequence
{
    return [self count]? [sequence nextIntegerInRange:NSMakeRange(0, [self count])]: NSNotFound;
}

- (id)randomObjectWithSequence:(RandomSequence *)sequence
{
    NSUInteger index = [self randomIndexWithSequence:sequence];
    return [self count]? self[index]: nil;
}

- (NSArray *)shuffledArrayWithSequence:(RandomSequence *)sequence
{
    NSMutableArray *array = [NSMutableArray arrayWithArray:self];
    [array shuffleWithSequence:sequence];
    return array;
}

@end


@implementation NSMutableArray (RandomSequence)

- (void)shuffleWithSequence:(RandomSequence *)sequence
{
    NSUInteger count = [self count];
    for (NSUInteger i = 0; i < count; i++)
    {
        NSInteger index = [sequence nextIntegerInRange:NSMakeRange(i, count - i)];
        [self exchangeObjectAtIndex:i withObjectAtIndex:index];
    }
}

@end