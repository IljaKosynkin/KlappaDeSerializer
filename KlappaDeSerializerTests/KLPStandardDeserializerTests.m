//
//  KlappaDeSerializerTests.m
//  KlappaDeSerializerTests
//
//  Created by Ilja Kosynkin on 1/22/17.
//  Copyright © 2017 Ilja Kosynkin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "KLPStandardDeserializer.h"
#import "KLPExplicitNamingStrategy.h"

static KLPStandardDeserializer* deserializer;

@interface SimpleObject : NSObject
@property NSString* name;
@property NSDecimalNumber* price;
@end

@implementation SimpleObject

@end

@interface SimpleObject2 : NSObject
@property NSString* Name;
@property NSDecimalNumber* Price;
@end

@implementation SimpleObject2

@end

@interface Thumbnail : NSObject

@property NSString* url;
@property NSString* height;
@property NSString* width;

@end

@implementation Thumbnail

@end

@interface NestedObject : NSObject

@property NSString* title;
@property NSString* summary;
@property NSString* url;
@property NSString* clickUrl;
@property NSString* refererUrl;
@property NSUInteger fileSize;
@property NSString* fileFormat;
@property NSString* height;
@property NSString* width;
@property Thumbnail* thumbnail;

@end

@implementation NestedObject

@end

@interface NestedObjectCustomTypeMapping : NSObject

@property NSURL* url;
@property NSURL* clickUrl;
@property NSURL* refererUrl;
@property NSUInteger height;
@property NSUInteger width;

@end

@implementation NestedObjectCustomTypeMapping

@end

@interface Address : NSObject

@property NSString* streetAddress;
@property NSString* city;
@property NSString* state;
@property NSString* postalCode;

@end

@implementation Address

@end

@interface Phone : NSObject

@property NSString* type;
@property NSString* number;

@end

@implementation Phone

@end

@interface NestedObjectWithArray : NSObject<KLPDeserializable>

@property NSString* firstName;
@property NSString* lastName;
@property NSUInteger age;
@property Address* address;
@property NSArray* phoneNumber;

@end

@implementation NestedObjectWithArray
+ (NSDictionary*) getFieldsToClassMap {
    return @{@"phoneNumber": [Phone class]};
}
@end

@interface StringToNSURLConverter : NSObject<KLPValueConverter>
- (id) convert:(id) value;
@end

@implementation StringToNSURLConverter
- (id) convert:(id) value {
    NSString* val = value;
    return [[NSURL alloc] initWithString:val];
}
@end

@interface StringToNSUIntegerConverter : NSObject<KLPValueConverter>
- (id) convert:(id) value;
@end

@implementation StringToNSUIntegerConverter
- (id) convert:(id) value {
    NSString* val = value;
    NSUInteger casted = [val integerValue];
    return [NSNumber numberWithUnsignedInteger:casted];
}
@end

@interface KLPStandardDeserializerTests : XCTestCase

@end



@implementation KLPStandardDeserializerTests

- (NSDictionary*) getJsonFile:(NSString*) name {
    NSString* filepath = [[NSBundle bundleForClass:[self class]] pathForResource:name ofType:@"json"];
    NSString *jsonString = [[NSString alloc] initWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:nil];
    NSData* data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError* error;
    NSDictionary* dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    return dictionary;
}

+ (void) setUp {
}

- (void)setUp {
    [super setUp];
    deserializer = [[KLPStandardDeserializer alloc] init];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testSimpleParsing {
    NSDictionary* jsonDict = [self getJsonFile:@"SimpleObject"];
    SimpleObject* object = [deserializer deserialize:[SimpleObject class] json:jsonDict];
    
    XCTAssertNotNil(object);
    XCTAssertTrue([object.name isEqualToString:@"A green door"]);
    XCTAssertTrue([object.price isEqual:@12.50]);
}

- (void)testNestedObjectParse {
    NSDictionary* jsonDict = [self getJsonFile:@"NestedObject"];
    NestedObject* object = [deserializer deserialize:[NestedObject class] json:jsonDict];
    
    XCTAssertNotNil(object);
    XCTAssertTrue([object.title isEqualToString:@"potato jpg"]);
    XCTAssertTrue([object.summary isEqualToString:@"Kentang Si bungsu dari keluarga Solanum tuberosum L ini ternyata memiliki khasiat untuk mengurangi kerutan  jerawat  bintik hitam dan kemerahan pada kulit  Gunakan seminggu sekali sebagai"]);
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

- (void) testCustomTypeMapping {
    StringToNSURLConverter* urlConverter = [[StringToNSURLConverter alloc] init];
    StringToNSUIntegerConverter* integerConverter = [[StringToNSUIntegerConverter alloc] init];
    [deserializer addValueConverter:urlConverter forField:@"Url" forInputType:String forOutputClass:nil];
    [deserializer addValueConverter:urlConverter forField:@"ClickUrl" forInputType:String forOutputClass:nil];
    [deserializer addValueConverter:urlConverter forField:@"RefererUrl" forInputType:String forOutputClass:nil];
    [deserializer addValueConverter:integerConverter forField:@"Height" forInputType:String forOutputClass:nil];
    [deserializer addValueConverter:integerConverter forField:@"Width" forInputType:String forOutputClass:nil];
    
    NSDictionary* jsonDict = [self getJsonFile:@"NestedObject"];
    NestedObjectCustomTypeMapping* object = [deserializer deserialize:[NestedObjectCustomTypeMapping class] json:jsonDict];
    
    XCTAssertNotNil(object);
    XCTAssertTrue([object.url.absoluteString isEqualToString:@"http://www.mediaindonesia.com/spaw/uploads/images/potato.jpg"]);
    XCTAssertTrue([object.clickUrl.absoluteString isEqualToString:@"http://www.mediaindonesia.com/spaw/uploads/images/potato.jpg"]);
    XCTAssertTrue([object.refererUrl.absoluteString isEqualToString:@"http://www.mediaindonesia.com/mediaperempuan/index.php?ar_id=Nzkw"]);
    XCTAssertTrue(object.height == 362);
    XCTAssertTrue(object.width == 532);
}

- (void) testNestedArrayParsing {
    NSDictionary* jsonDict = [self getJsonFile:@"NestedObjectWithArray"];
    NestedObjectWithArray* object = [deserializer deserialize:[NestedObjectWithArray class] json:jsonDict];
    
    XCTAssertNotNil(object);
    XCTAssertTrue([object.firstName isEqualToString:@"John"]);
    XCTAssertTrue([object.lastName isEqualToString:@"Smith"]);
    XCTAssertTrue(object.age == 25);
    
    XCTAssertNotNil(object.address);
    XCTAssertTrue([object.address.streetAddress isEqualToString:@"21 2nd Street"]);
    XCTAssertTrue([object.address.city isEqualToString:@"New York"]);
    XCTAssertTrue([object.address.state isEqualToString:@"NY"]);
    XCTAssertTrue([object.address.postalCode isEqualToString:@"10021"]);
    
    XCTAssertNotNil(object.phoneNumber);
    XCTAssertTrue(object.phoneNumber.count == 2);
    
    Phone* phone = object.phoneNumber[0];
    XCTAssertTrue([phone.type isEqualToString:@"home"]);
    XCTAssertTrue([phone.number isEqualToString:@"212 555-1234"]);
    
    phone = object.phoneNumber[1];
    XCTAssertTrue([phone.type isEqualToString:@"fax"]);
    XCTAssertTrue([phone.number isEqualToString:@"646 555-4567"]);
}

- (void) testCustomNamingStrategy {
    [deserializer setGlobalNamingStrategy:[[KLPExplicitNamingStrategy alloc] init]];
    
    NSDictionary* jsonDict = [self getJsonFile:@"SimpleObject2"];
    SimpleObject2* object = [deserializer deserialize:[SimpleObject2 class] json:jsonDict];
    
    XCTAssertNotNil(object);
    XCTAssertTrue([object.Name isEqualToString:@"A green door"]);
    XCTAssertTrue([object.Price isEqual:@12.50]);
}

@end
