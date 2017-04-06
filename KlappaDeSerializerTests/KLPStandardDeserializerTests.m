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
#import "KLPDefaultNamingStrategy.h"
#import "KLPDeserializer.h"
#import "KLPAncestor.h"

static KLPStandardDeserializer* deserializer;

@interface SimpleObject : KLPAncestor
@property NSString* name;
@property NSDecimalNumber* price;
@end

@implementation SimpleObject

+ (NSArray*) getRequiredFields {
    return @[@"name"];
}

@end

@interface SimpleObject2 : KLPAncestor
@property NSString* Name;
@property NSDecimalNumber* Price;
@end

@implementation SimpleObject2
+ (id<KLPNamingStrategy>) getNamingStrategy {
    return [[KLPExplicitNamingStrategy alloc] init];
}
@end

@interface SimpleObject3 : KLPAncestor
@property NSString* ammo;
@property NSDecimalNumber* price;
@end

@implementation SimpleObject3

+ (NSDictionary*) getCustomFieldsMapping {
    return @{@"ammo": @"name"};
}

@end

@interface Thumbnail : KLPAncestor

@property NSString* url;
@property NSString* height;
@property NSString* width;

@end

@implementation Thumbnail

@end

@interface NestedObject : KLPAncestor

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

@interface NestedObjectCustomTypeMapping : KLPAncestor

@property NSURL* url;
@property NSURL* clickUrl;
@property NSURL* refererUrl;
@property NSString* height;
@property NSString* width;

@end

@implementation NestedObjectCustomTypeMapping

@end

@interface Address : KLPAncestor

@property NSString* streetAddress;
@property NSString* city;
@property NSString* state;
@property NSString* postalCode;

@end

@implementation Address

@end

@interface Phone : KLPAncestor

@property NSString* type;
@property NSString* number;

@end

@implementation Phone

@end

@interface NestedObjectWithArray : KLPAncestor

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
    deserializer = [[KLPStandardDeserializer alloc] init];
}

- (void)setUp {
    [super setUp];
    [KLPDeserializer setGlobalNamingStrategy:[[KLPDefaultNamingStrategy alloc] init]];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testSimpleParsing {
    NSDictionary* jsonDict = [self getJsonFile:@"SimpleObject"];
    SimpleObject* object = (SimpleObject*)[deserializer deserialize:[SimpleObject class] json:jsonDict];
    
    XCTAssertNotNil(object);
    XCTAssertTrue([object.name isEqualToString:@"A green door"]);
    XCTAssertTrue([object.price isEqual:@12.50]);
}

- (void)testNestedObjectParse {
    NSDictionary* jsonDict = [self getJsonFile:@"NestedObject"];
    NestedObject* object = (NestedObject*)[deserializer deserialize:[NestedObject class] json:jsonDict];
    
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
    [deserializer addValueConverter:urlConverter forField:@"url" forInputType:String forOutputClass:[NSURL class]];
    [deserializer addValueConverter:urlConverter forField:@"clickUrl" forInputType:String forOutputClass:[NSURL class]];
    [deserializer addValueConverter:urlConverter forField:@"refererUrl" forInputType:String forOutputClass:[NSURL class]];
    
    NSDictionary* jsonDict = [self getJsonFile:@"NestedObject"];
    NestedObjectCustomTypeMapping* object = (NestedObjectCustomTypeMapping*)[deserializer deserialize:[NestedObjectCustomTypeMapping class] json:jsonDict];
    
    XCTAssertNotNil(object);
    XCTAssertTrue([object.url.absoluteString isEqualToString:@"http://www.mediaindonesia.com/spaw/uploads/images/potato.jpg"]);
    XCTAssertTrue([object.clickUrl.absoluteString isEqualToString:@"http://www.mediaindonesia.com/spaw/uploads/images/potato.jpg"]);
    XCTAssertTrue([object.refererUrl.absoluteString isEqualToString:@"http://www.mediaindonesia.com/mediaperempuan/index.php?ar_id=Nzkw"]);
}

- (void) testNestedArrayParsing {
    NSDictionary* jsonDict = [self getJsonFile:@"NestedObjectWithArray"];
    NestedObjectWithArray* object = (NestedObjectWithArray*)[deserializer deserialize:[NestedObjectWithArray class] json:jsonDict];
    
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
    NSDictionary* jsonDict = [self getJsonFile:@"SimpleObject2"];
    SimpleObject2* object = (SimpleObject2*)[deserializer deserialize:[SimpleObject2 class] json:jsonDict];
    
    XCTAssertNotNil(object);
    XCTAssertTrue([object.Name isEqualToString:@"A green door"]);
    XCTAssertTrue([object.Price isEqual:@12.50]);
}

- (void) testShouldNotParseJsonWithoutRequiredProperty {
    NSDictionary* jsonDict = [self getJsonFile:@"SimpleObject3"];
    SimpleObject* object = (SimpleObject*)[deserializer deserialize:[SimpleObject class] json:jsonDict];
    
    XCTAssertNil(object);
}

- (void) testCustomFieldsMapping {
    NSDictionary* jsonDict = [self getJsonFile:@"SimpleObject"];
    SimpleObject3* object = (SimpleObject3*)[deserializer deserialize:[SimpleObject3 class] json:jsonDict];
    
    XCTAssertNotNil(object);
    XCTAssertTrue([object.ammo isEqualToString:@"A green door"]);
    XCTAssertTrue([object.price isEqual:@12.50]);
}

@end
