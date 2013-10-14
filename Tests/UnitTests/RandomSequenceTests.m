//
//  Created by Nick Lockwood on 12/01/2012.
//  Copyright (c) 2012 Charcoal Design. All rights reserved.
//

#import "RandomSequenceTests.h"
#import "RandomSequence.h"


@implementation RandomSequenceTests

- (void)testRepeatability
{
    RandomSequence *sequence1 = [[RandomSequence alloc] init];
    RandomSequence *sequence2 = [RandomSequence sequenceWithSeed:sequence1.seed];
    
    NSArray *values = @[@"foo", @"bar", @"baz"];
    NSArray *shuffled1 = [values shuffledArrayWithSequence:sequence1];
    NSArray *shuffled2 = [values shuffledArrayWithSequence:sequence2];
    
    NSAssert([shuffled1 isEqualToArray:shuffled2], @"Repeatability test failed");
}

- (void)testUniqueness
{
    RandomSequence *sequence = [RandomSequence sequenceWithSeed:123456];
    
    NSArray *values = @[@"foo", @"bar", @"baz"];
    NSArray *shuffled1 = [values shuffledArrayWithSequence:sequence];
    NSArray *shuffled2 = [values shuffledArrayWithSequence:sequence];
    
    NSAssert(![shuffled1 isEqualToArray:shuffled2], @"Uniqueness test failed");
}

- (void)testConsistency
{
    RandomSequence *sequence = [RandomSequence sequenceWithSeed:123456];
    
    NSArray *values = @[@([sequence nextIntegerFrom:0 to:INT32_MAX]),
                        @([sequence nextIntegerFrom:0 to:INT32_MAX]),
                        @([sequence nextIntegerFrom:0 to:INT32_MAX]),
                        @([sequence nextIntegerFrom:0 to:INT32_MAX])];
    
    NSArray *compare = @[@(1007028800),
                         @(1652498240),
                         @(799479219),
                         @(1821642035)];
    
    NSAssert([values isEqualToArray:compare], @"Consistency test failed");
}

@end