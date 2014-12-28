//
//  Created by Nick Lockwood on 12/01/2012.
//  Copyright (c) 2012 Charcoal Design. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RandomSequence.h"


@interface RandomSequenceTests : XCTestCase

@end


@implementation RandomSequenceTests

- (void)testRepeatability
{
    RandomSequence *sequence1 = [[RandomSequence alloc] init];
    RandomSequence *sequence2 = [RandomSequence sequenceWithSeed:sequence1.seed];
    
    NSArray *values = @[@"foo", @"bar", @"baz"];
    NSArray *shuffled1 = [values shuffledArrayWithSequence:sequence1];
    NSArray *shuffled2 = [values shuffledArrayWithSequence:sequence2];
    
    XCTAssertEqualObjects(shuffled1, shuffled2);
}

- (void)testUniqueness
{
    RandomSequence *sequence = [RandomSequence sequenceWithSeed:123456];
    sequence.version = 0;
    
    NSArray *values = @[@"foo", @"bar", @"baz"];
    NSArray *shuffled1 = [values shuffledArrayWithSequence:sequence];
    NSArray *shuffled2 = [values shuffledArrayWithSequence:sequence];
    NSArray *shuffled3 = [values shuffledArrayWithSequence:sequence];
    
    XCTAssertNotEqualObjects(shuffled1, shuffled2);
    XCTAssertNotEqualObjects(shuffled1, shuffled3);
}

- (void)testRepetition
{
    RandomSequence *sequence = [RandomSequence sequenceWithSeed:123456];
    
    NSMutableSet *values = [NSMutableSet set];
    for (int i = 0; i < 1000000; i++)
    {
        NSNumber *value = @([sequence nextDouble]);
        XCTAssertFalse([values containsObject:value]);
        [values addObject:value];
    }
}

- (void)testConsistency
{
    RandomSequence *sequence = [RandomSequence sequenceWithSeed:123456];
    
    NSArray *values = @[@([sequence nextIntegerFrom:0 to:UINT32_MAX]),
                        @([sequence nextIntegerFrom:0 to:UINT32_MAX]),
                        @([sequence nextIntegerFrom:0 to:UINT32_MAX]),
                        @([sequence nextIntegerFrom:0 to:UINT32_MAX])];
    
    NSArray *compare = @[@(351072415),
                         @(870155634),
                         @(704390697),
                         @(2406627700)];
    
    XCTAssertEqualObjects(values, compare);
}

- (void)testShuffleV0
{
    RandomSequence *sequence = [RandomSequence sequenceWithSeed:123456];
    sequence.version = 0;
    
    NSArray *values = @[@1, @2, @3, @4, @5, @6, @7, @8, @9, @10];
    NSArray *compare = @[@5, @8, @1, @9, @10, @3, @7, @6, @4, @2];
    
    XCTAssertEqualObjects([values shuffledArrayWithSequence:sequence], compare);
}

- (void)testShuffleV1
{
    RandomSequence *sequence = [RandomSequence sequenceWithSeed:123456];
    sequence.version = 1;
    
    NSArray *values = @[@1, @2, @3, @4, @5, @6, @7, @8, @9, @10];
    NSArray *compare = @[@2, @4, @8, @1, @10, @9, @6, @3, @7, @5];
    
    XCTAssertEqualObjects([values shuffledArrayWithSequence:sequence], compare);
}

- (void)testShuffleV2
{
    RandomSequence *sequence = [RandomSequence sequenceWithSeed:123456];
    sequence.version = 2;
    
    NSArray *values = @[@1, @2, @3, @4, @5, @6, @7, @8, @9, @10];
    NSArray *compare = @[@1, @5, @3, @7, @10, @9, @8, @2, @4, @6];
    
    XCTAssertEqualObjects([values shuffledArrayWithSequence:sequence], compare);
}

@end
