//
//  KLPDeserializerFactoryTests.m
//  KlappaDeSerializer
//
//  Created by Ilja Kosynkin on 1/29/17.
//  Copyright © 2017 Ilja Kosynkin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "KLPDeserializer.h"
#import "KLPStandardDeserializer.h"
#import "KLPExplicitNamingStrategy.h"
#include "KLPAncestor.h"

@interface KLPFSimpleObject : KLPAncestor
@property NSString* name;
@property NSDecimalNumber* price;
@end

@implementation KLPFSimpleObject

@end

@interface KLPFThumbnail : KLPAncestor

@property NSString* url;
@property NSString* height;
@property NSString* width;

@end

@implementation KLPFThumbnail

@end

@interface KLPFAddress : KLPAncestor

@property NSString* streetAddress;
@property NSString* city;
@property NSString* state;
@property NSString* postalCode;

@end

@implementation KLPFAddress

@end

@interface KLPFPhone : KLPAncestor

@property NSString* type;
@property NSString* number;

@end

@implementation KLPFPhone

@end

@interface KLPFNestedObjectWithArray : KLPAncestor

@property NSString* firstName;
@property NSString* lastName;
@property NSUInteger age;
@property KLPFAddress* address;
@property NSArray* phoneNumber;

@end

@implementation KLPFNestedObjectWithArray

+ (NSDictionary*) getFieldsToClassMap {
    return @{@"phoneNumber": [KLPFPhone class]};
}

@end

@interface KLPFObjectWithArrayOfPrimitives : KLPAncestor

@property NSArray* ints;
@property NSArray* strings;

@end

@implementation KLPFObjectWithArrayOfPrimitives

@end

@interface KLPAddressDeserializer : NSObject<KLPDeserializerProtocol>

- (void) setGlobalNamingStrategy:(id<KLPNamingStrategy>) strategy;
- (id) deserialize:(Class) classToDeserialize json:(NSDictionary*) jsonToDeserialize;

@end

@implementation KLPAddressDeserializer

- (void) setGlobalNamingStrategy:(id<KLPNamingStrategy>) strategy {
    
}

- (id) deserialize:(Class) classToDeserialize json:(NSDictionary*) jsonToDeserialize {
    KLPFAddress* address = [[KLPFAddress alloc] init];
    address.streetAddress = @"a";
    address.city = @"a";
    address.postalCode = @"a";
    address.state = @"a";
    return address;
}

@end

@interface KLPFNestedObject : KLPAncestor

@property NSString* title;
@property NSString* summary;
@property NSString* url;
@property NSString* clickUrl;
@property NSString* refererUrl;
@property NSUInteger fileSize;
@property NSString* fileFormat;
@property NSString* height;
@property NSString* width;
@property KLPFThumbnail* thumbnail;

@end

@implementation KLPFNestedObject

@end


@interface KLPDeserializerFactoryTests : XCTestCase

@end

@implementation KLPDeserializerFactoryTests
- (NSString*) getJsonFile:(NSString*) name {
    NSString* filepath = [[NSBundle bundleForClass:[self class]] pathForResource:name ofType:@"json"];
    NSString *jsonString = [[NSString alloc] initWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:nil];
    return jsonString;
}


- (void) testJsonStringSimpleObjectParsing {
    NSString* json = [self getJsonFile:@"SimpleObject"];
    KLPFSimpleObject* object = [KLPDeserializer deserializeWithString:[KLPFSimpleObject class] jsonString:json];
    
    XCTAssertNotNil(object);
    XCTAssertTrue([object.name isEqualToString:@"A green door"]);
    XCTAssertTrue([object.price isEqual:@12.50]);
}


- (void) testJsonStringNestedObjectParse {
    NSString* json = [self getJsonFile:@"NestedObject"];
    KLPFNestedObject* object = [KLPDeserializer deserializeWithString:[KLPFNestedObject class] jsonString:json];
    XCTAssertNotNil(object);
    XCTAssertTrue([object.title isEqualToString:@"potato jpg"]);
    XCTAssertTrue([object.summary isEqualToString:@"Kentang Si bungsu dari keluarga Solanum tuberosum L ini ternyata memiliki khasiat untuk mengurangi kerutan  jerawat  bintik hitam dan kemerahan pada kulit  Gunakan seminggu sekali sebagai"] == YES);
    XCTAssertTrue([object.url isEqualToString:@"http://www.mediaindonesia.com/spaw/uploads/images/potato.jpg"]);
    XCTAssertTrue([object.clickUrl isEqualToString:@"http://www.mediaindonesia.com/spaw/uploads/images/potato.jpg"]);
    XCTAssertTrue([object.refererUrl isEqualToString:@"http://www.mediaindonesia.com/mediaperempuan/index.php?ar_id=Nzkw"]);
    XCTAssertTrue(object.fileSize == 22630);
    XCTAssertTrue([object.fileFormat isEqualToString:@"jpeg"]);
    XCTAssertTrue([object.height isEqualToString:@"362"]);
    XCTAssertTrue([object.width isEqualToString:@"532"]);
        
    XCTAssertNotNil(object.thumbnail);
    XCTAssertTrue([object.thumbnail.url isEqualToString:@"http://thm-a01.yimg.com/nimage/557094559c18f16a"]);
    XCTAssertTrue([object.thumbnail.height isEqualToString:@"98"]);
    XCTAssertTrue([object.thumbnail.width isEqualToString:@"145"]);
}

- (void) testJsonStringArrayParsing {
    NSString* json = [self getJsonFile:@"Array"];
    NSArray* objects = [KLPDeserializer deserializeWithString:[KLPFNestedObject class] jsonString:json];
    for (KLPFNestedObject* object in objects) {
        XCTAssertNotNil(object);
        XCTAssertTrue([object.title isEqualToString:@"potato jpg"]);
        XCTAssertTrue([object.summary isEqualToString:@"Kentang Si bungsu dari keluarga Solanum tuberosum L ini ternyata memiliki khasiat untuk mengurangi kerutan  jerawat  bintik hitam dan kemerahan pada kulit  Gunakan seminggu sekali sebagai"] == YES);
        XCTAssertTrue([object.url isEqualToString:@"http://www.mediaindonesia.com/spaw/uploads/images/potato.jpg"]);
        XCTAssertTrue([object.clickUrl isEqualToString:@"http://www.mediaindonesia.com/spaw/uploads/images/potato.jpg"]);
        XCTAssertTrue([object.refererUrl isEqualToString:@"http://www.mediaindonesia.com/mediaperempuan/index.php?ar_id=Nzkw"]);
        XCTAssertTrue(object.fileSize == 22630);
        XCTAssertTrue([object.fileFormat isEqualToString:@"jpeg"]);
        XCTAssertTrue([object.height isEqualToString:@"362"]);
        XCTAssertTrue([object.width isEqualToString:@"532"]);
        
        XCTAssertNotNil(object.thumbnail);
        XCTAssertTrue([object.thumbnail.url isEqualToString:@"http://thm-a01.yimg.com/nimage/557094559c18f16a"]);
        XCTAssertTrue([object.thumbnail.height isEqualToString:@"98"]);
        XCTAssertTrue([object.thumbnail.width isEqualToString:@"145"]);
    }
}

- (void) testCustomDeserializer {
    NSString* json = [self getJsonFile:@"NestedObjectWithArray"];
    
    id<KLPDeserializerProtocol> deserializer = [[KLPAddressDeserializer alloc] init];
    Class cls = [KLPFNestedObjectWithArray class];
    [KLPDeserializer registerDeserializer:deserializer name:@"address" context:&cls];
    
    KLPFNestedObjectWithArray* object = [KLPDeserializer deserializeWithString:[KLPFNestedObjectWithArray class] jsonString:json];
    XCTAssertNotNil(object.address);
    XCTAssertTrue([object.address.streetAddress isEqualToString:@"a"]);
    XCTAssertTrue([object.address.postalCode isEqualToString:@"a"]);
    XCTAssertTrue([object.address.city isEqualToString:@"a"]);
    XCTAssertTrue([object.address.state isEqualToString:@"a"]);
}

- (void) testArrayOfPrimitives {
    NSString* json = [self getJsonFile:@"PrimitiveArray"];
    
    NSArray* primitives = [KLPDeserializer deserializeWithArrayOfPrimitives:json];
    
    XCTAssertEqual(primitives.count, 3);
    
    NSString* first = primitives[0];
    XCTAssertTrue([first isEqualToString:@"aaa"]);
    
    NSString* second = primitives[1];
    XCTAssertTrue([second isEqualToString:@"bbb"]);
    
    NSString* third = primitives[2];
    XCTAssertTrue([third isEqualToString:@"ccc"]);
}

- (void) testObjectWithArrayOfPrimitives {
    NSString* json = [self getJsonFile:@"ObjectWithArrayOfPrimitives"];
    
    KLPFObjectWithArrayOfPrimitives* obj = [KLPDeserializer deserializeWithString:[KLPFObjectWithArrayOfPrimitives class] jsonString:json];
    
    XCTAssertNotNil(obj);
    
    XCTAssertEqual(obj.ints.count, 3);
    XCTAssertEqual([obj.ints[0] intValue], 1);
    XCTAssertEqual([obj.ints[1] intValue], 2);
    XCTAssertEqual([obj.ints[2] intValue], 3);
    
    XCTAssertEqual(obj.strings.count, 2);
    
    NSString* first = obj.strings[0];
    XCTAssertTrue([first isEqualToString:@"aa"]);
    
    NSString* second = obj.strings[1];
    XCTAssertTrue([second isEqualToString:@"vv"]);
}
@end
