//
//  KLPStrategiesTest.m
//  KlappaDeSerializer
//
//  Created by Ilja Kosynkin on 1/28/17.
//  Copyright © 2017 Ilja Kosynkin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "KLPExplicitNamingStrategy.h"
#import "KLPDefaultNamingStrategy.h"

static id<KLPNamingStrategy> defaultStrategy;
static id<KLPNamingStrategy> explicitStrategy;

@interface KLPStrategiesTest : XCTestCase

@end

@implementation KLPStrategiesTest

+ (void)setUp {
    defaultStrategy = [[KLPDefaultNamingStrategy alloc] init];
    explicitStrategy = [[KLPExplicitNamingStrategy alloc] init];
}


- (void)testDefaultStrategy {
    NSString* fieldToTest1 = @"testField";
    NSString* fieldToTest2 = @"testField";
    NSString* fieldToTest3 = @"TestField";
    NSString* correctField = @"test_field";
    
    XCTAssertTrue([[defaultStrategy convertName:fieldToTest1] isEqualToString:correctField]);
    XCTAssertTrue([[defaultStrategy convertName:fieldToTest2] isEqualToString:correctField]);
    XCTAssertTrue([[defaultStrategy convertName:fieldToTest3] isEqualToString:correctField]);
}

- (void)testExplicitStrategy {
    NSString* fieldToTest1 = @"test_field";
    NSString* fieldToTest2 = @"testField";
    NSString* fieldToTest3 = @"TestField";
    NSString* fieldToTest4 = @"Test_Field";
    
    XCTAssertTrue([[explicitStrategy convertName:fieldToTest1] isEqualToString:fieldToTest1]);
    XCTAssertTrue([[explicitStrategy convertName:fieldToTest2] isEqualToString:fieldToTest2]);
    XCTAssertTrue([[explicitStrategy convertName:fieldToTest3] isEqualToString:fieldToTest3]);
    XCTAssertTrue([[explicitStrategy convertName:fieldToTest4] isEqualToString:fieldToTest4]);
}

@end
