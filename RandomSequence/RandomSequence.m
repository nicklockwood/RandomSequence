//
//  RandomSequence.m
//
//  Version 1.2
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


#import <Availability.h>
#if !__has_feature(objc_arc)
#error This class requires automatic reference counting
#endif


static NSString *const SeedPropertyKey = @"seed";
static NSString *const VersionKey = @"version";


#define PARAMS_V1 {233280, 9301, 49297}
#define PARAMS_V2 {4294967296, 1664525, 1013904223}


typedef struct
{
    double modulus;
    double multiplier;
    double increment;
}
RandomSequenceParams;

static const RandomSequenceParams params[] = {PARAMS_V1, PARAMS_V1, PARAMS_V2};

@implementation RandomSequence

+ (instancetype)defaultSequence
{
    static RandomSequence *defaultSequence = nil;
    if (defaultSequence == nil)
    {
        defaultSequence = [[self alloc] init];
    }
    return defaultSequence;
}

+ (instancetype)sequenceWithSeed:(uint32_t)seed
{
    RandomSequence *sequence = [(__typeof__(self))[self alloc] init];
    sequence.seed = seed;
    return sequence;
}

- (instancetype)init
{
    if ((self = [super init]))
    {
        _version = RandomSequenceAlgorithmVersion;
        _seed = arc4random();
        
#ifdef DEBUG
        
        RandomSequenceParams p = params[self.version];
        assert((double)p.modulus * (double)p.multiplier + (double)p.increment <= 9007199254740992);
        
#endif
        
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super init]))
    {
        _seed = (uint32_t)[aDecoder decodeInt32ForKey:SeedPropertyKey];
        _version = (uint32_t)[aDecoder decodeIntegerForKey:VersionKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt32:(int32_t)self.seed forKey:SeedPropertyKey];
    [aCoder encodeInteger:(NSInteger)self.version forKey:VersionKey];
}

- (id)copyWithZone:(NSZone *)zone
{
    RandomSequence *sequence = [[[self class] allocWithZone:zone] init];
    sequence.seed = self.seed;
    return sequence;
}

- (uint32_t)seed
{
    RandomSequenceParams p = params[self.version];
    if (p.modulus < (double)UINT32_MAX)
    {
        return _seed % (uint32_t)p.modulus;
    }
    return _seed;
}

- (uint32_t)nextSeed
{
    RandomSequenceParams p = params[self.version];
    return self.seed = (uint32_t)(fmod((double)self.seed * p.multiplier + p.increment, p.modulus));
}

- (NSUInteger)nextIntegerInRange:(NSRange)range
{
    if (self.version < 2)
    {
        return (NSUInteger)(floor([self nextDouble] * (double)range.length)) + range.location;
    }
    return (NSUInteger)([self nextSeed] % range.length) + range.location;
}

- (NSInteger)nextIntegerFrom:(NSInteger)from to:(NSInteger)to
{
    if (self.version < 2)
    {
        return (NSInteger)(floor([self nextDouble] * (double)(to - from))) + from;
    }
    return (NSInteger)([self nextSeed] % ABS(to - from)) + MIN(to, from);
}

- (double)nextDouble
{
    return (double)[self nextSeed] / params[self.version].modulus;
}

- (BOOL)nextBool
{
    return [self nextSeed] % 2 == 0;
}

@end


@implementation RandomSequence (Deprecated)

- (double)value
{
    return (double)self.seed / (double)params[self.version].modulus;
}

- (double)nextValue
{
    return [self nextDouble];
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
    if (sequence.version < 1)
    {
        //this shuffle algorithm is non-uniform
        //you should switch to the new one if possible
        NSUInteger count = [self count];
        for (NSUInteger i = 0; i < count; i++)
        {
            NSUInteger index = [sequence nextIntegerInRange:NSMakeRange(i, count - i)];
            [self exchangeObjectAtIndex:i withObjectAtIndex:index];
        }
    }
    else
    {
        for (NSInteger i = (NSInteger)[self count] - 1; i > 0; i--)
        {
            NSInteger j = [sequence nextIntegerFrom:0 to:i + 1];
            [self exchangeObjectAtIndex:(NSUInteger)j withObjectAtIndex:(NSUInteger)i];
        }
    }
}

@end
