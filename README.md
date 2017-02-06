# KlappaDeSerializer
JSON mapper library for iOS written in Objective-C for Objective-C.

# Description
Framework for automatic JSON deserialization. The main purpose is too allow developer to transform JSON to objects in an easy 
and robust way.

# Installation
Add:
```
    pod ‘KlappaDeSerializer’
```
to your Podfile.

Then run:
```
    pod install
```
or:
```
    pod update
```
And you're free to go.

# Usage
## Simple case
Library provides class with static methods called KLPDeserializer and it's highly encouraged to use it. 
Lets consider following JSON object:
```json
{
    "name": "A green door",
    "price": 12.50
}
```

And according to it class declaration:
```objective-c
@interface KLPFSimpleObject : NSObject
@property NSString* name;
@property NSDecimalNumber* price;
@end

@implementation KLPFSimpleObject
@end
```

And then you can deserialize it in the following way:
```objective-c
KLPFSimpleObject* object = [KLPDeserializer deserializeWithString:[KLPFSimpleObject class] jsonString:json];
```
or 
```objective-c
KLPFSimpleObject* object = [KLPDeserializer deserializeWithDictionary:[KLPFSimpleObject class] jsonDictionary:dict];
```
And it's pretty much it. 

## Nested objects
KlappaDeSerializer also let you to easily deserialize JSON with nested objects.
Lets consider following JSON object:
```json
{
  "Title": "potato jpg",
  "Summary": "Kentang Si bungsu dari keluarga Solanum tuberosum L ini ternyata memiliki khasiat untuk mengurangi kerutan  jerawat  bintik hitam dan kemerahan pada kulit  Gunakan seminggu sekali sebagai",
  "Url": "http://www.mediaindonesia.com/spaw/uploads/images/potato.jpg",
  "ClickUrl": "http://www.mediaindonesia.com/spaw/uploads/images/potato.jpg",
  "RefererUrl": "http://www.mediaindonesia.com/mediaperempuan/index.php?ar_id=Nzkw",
  "FileSize": 22630,
  "FileFormat": "jpeg",
  "Height": "362",
  "Width": "532",
  "Thumbnail": {
    "Url": "http://thm-a01.yimg.com/nimage/557094559c18f16a",
    "Height": "98",
    "Width": "145"
  }
}
```
And according to it classes declarations:
```objective-c
@interface KLPFThumbnail : NSObject

@property NSString* url;
@property NSString* height;
@property NSString* width;

@end

@implementation KLPFThumbnail

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
```
Deserialization is performed in exactly the same way:
```objective-c
KLPFNestedObject* object = [KLPDeserializer deserializeWithString:[KLPFNestedObject class] jsonString:json];
```
or 
```objective-c
KLPFNestedObject* object = [KLPDeserializer deserializeWithDictionary:[KLPFNestedObject class] jsonDictionary:dict];
```

## Array parsing
Parsing of arrays is a bit different from parsing of plain objects, since NSArray, as type, doesn't show objects of which
type it contains. So in order to parse arrays you have to explicitly say, which type you expect in array.
Note that arrays, that contains objects of different types are not supported (and most probably will not be supported).
So, lets once again consider following JSON object:
```json
{
     "firstName": "John",
     "lastName": "Smith",
     "age": 25,
     "address":
     {
         "streetAddress": "21 2nd Street",
         "city": "New York",
         "state": "NY",
         "postalCode": "10021"
     },
     "phoneNumber":
     [
         {
           "type": "home",
           "number": "212 555-1234"
         },
         {
           "type": "fax",
           "number": "646 555-4567"
         }
     ]
 }
 ```
 And according to it classes declaration:
 ```objective-c
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
```
As you can see in order to specify type for array you have to implement function called
```objective-c
  + (NSDictionary*) getFieldsToClassMap;
```
which must return NSDictionary that contains classes mapped for fields of the class. If you don't do this - library will 
throw exception.
Deserialization is performed in exactly the same way:
```objective-c
KLPFNestedObject* object = [KLPDeserializer deserializeWithString:[KLPFNestedObject class] jsonString:json];
```
or 
```objective-c
KLPFNestedObject* object = [KLPDeserializer deserializeWithDictionary:[KLPFNestedObject class] jsonDictionary:dict];
```

## Straight array deserialization
Sometimes you want to not object, but array of objects. KlappaDeSerializer let you to do so.
Lets consider following JSON sample:
```json
[
  {
    "Title": "potato jpg",
    "Summary": "Kentang Si bungsu dari keluarga Solanum tuberosum L ini ternyata memiliki khasiat untuk mengurangi kerutan  jerawat  bintik hitam dan kemerahan pada kulit  Gunakan seminggu sekali sebagai",
    "Url": "http://www.mediaindonesia.com/spaw/uploads/images/potato.jpg",
    "ClickUrl": "http://www.mediaindonesia.com/spaw/uploads/images/potato.jpg",
    "RefererUrl": "http://www.mediaindonesia.com/mediaperempuan/index.php?ar_id=Nzkw",
    "FileSize": 22630,
    "FileFormat": "jpeg",
    "Height": "362",
    "Width": "532",
    "Thumbnail": {
      "Url": "http://thm-a01.yimg.com/nimage/557094559c18f16a",
      "Height": "98",
      "Width": "145"
    }
  },
 {
 "Title": "potato jpg",
 "Summary": "Kentang Si bungsu dari keluarga Solanum tuberosum L ini ternyata memiliki khasiat untuk mengurangi kerutan  jerawat  bintik hitam dan kemerahan pada kulit  Gunakan seminggu sekali sebagai",
 "Url": "http://www.mediaindonesia.com/spaw/uploads/images/potato.jpg",
 "ClickUrl": "http://www.mediaindonesia.com/spaw/uploads/images/potato.jpg",
 "RefererUrl": "http://www.mediaindonesia.com/mediaperempuan/index.php?ar_id=Nzkw",
 "FileSize": 22630,
 "FileFormat": "jpeg",
 "Height": "362",
 "Width": "532",
 "Thumbnail": {
 "Url": "http://thm-a01.yimg.com/nimage/557094559c18f16a",
 "Height": "98",
 "Width": "145"
 }
 }
]```
And according class declaration:
```objective-c
@interface KLPFThumbnail : NSObject

@property NSString* url;
@property NSString* height;
@property NSString* width;

@end

@implementation KLPFThumbnail

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
```
You can deserialize array in the following way:
```objective-c
NSArray* objects = [KLPDeserializer deserializeWithArray:[KLPFNestedObject class] array: array];
```
or 
```objective-c
NSArray* objects = [KLPDeserializer deserializeWithString:[KLPFNestedObject class] jsonString:json];
```
  
