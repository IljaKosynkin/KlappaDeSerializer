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

@interface KLPFSimpleObject : NSObject
@property NSString* name;
@property NSDecimalNumber* price;
@end

@implementation KLPFSimpleObject

@end

@interface KLPFThumbnail : NSObject

@property NSString* url;
@property NSString* height;
@property NSString* width;

@end

@implementation KLPFThumbnail

@end

@interface KLPFAddress : NSObject

@property NSString* streetAddress;
@property NSString* city;
@property NSString* state;
@property NSString* postalCode;

@end

@implementation KLPFAddress

@end

@interface KLPFPhone : NSObject

@property NSString* type;
@property NSString* number;

@end

@implementation KLPFPhone

@end

@interface KLPFNestedObjectWithArray : NSObject

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

@interface KLPFNestedObject : NSObject

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


@end
