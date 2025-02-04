# KlappaDeSerializer
JSON mapper library for iOS written in Objective-C for Objective-C.

# Description
Framework for automatic JSON deserialization. The main purpose is too allow developer to transform JSON to objects in an easy 
and robust way.

# Installation
Add:
```
    pod 'KlappaDeSerializer'
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

# Important notes
## Overriding "allocate" function
It's quite important to provide an implementation for "allocate" function to support bridging to Swift 4. Examples are provided below. 

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
@interface KLPFSimpleObject : KLPAncestor
@property NSString* name;
@property NSDecimalNumber* price;

+ (id<KLPDeserializable>) allocate;
@end

@implementation KLPFSimpleObject
+ (id<KLPDeserializable>) allocate {
    return [[KLPFSimpleObject alloc] init];
}
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
@interface KLPFThumbnail : KLPAncestor

@property NSString* url;
@property NSString* height;
@property NSString* width;

+ (id<KLPDeserializable>) allocate;
@end

@implementation KLPFThumbnail
+ (id<KLPDeserializable>) allocate {
    return [[KLPFThumbnail alloc] init];
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

+ (id<KLPDeserializable>) allocate;
@end

@implementation KLPFNestedObject
+ (id<KLPDeserializable>) allocate {
    return [[KLPFNestedObject alloc] init];
}
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
 @interface KLPFAddress : KLPAncestor

@property NSString* streetAddress;
@property NSString* city;
@property NSString* state;
@property NSString* postalCode;

+ (id<KLPDeserializable>) allocate;
@end

@implementation KLPFAddress
+ (id<KLPDeserializable>) allocate {
    return [[KLPFAddress alloc] init];
}
@end

@interface KLPFPhone : KLPAncestor

@property NSString* type;
@property NSString* number;

+ (id<KLPDeserializable>) allocate;
@end

@implementation KLPFPhone
+ (id<KLPDeserializable>) allocate {
    return [[KLPFPhone alloc] init];
}
@end

@interface KLPFNestedObjectWithArray : KLPAncestor

@property NSString* firstName;
@property NSString* lastName;
@property NSUInteger age;
@property KLPFAddress* address;
@property NSArray* phoneNumber;

+ (id<KLPDeserializable>) allocate;
+ (NSDictionary*) getFieldsToClassMap;
@end

@implementation KLPFNestedObjectWithArray
+ (id<KLPDeserializable>) allocate {
    return [[KLPFNestedObjectWithArray alloc] init];
}

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
]
```
And according class declaration:
```objective-c
@interface KLPFThumbnail : KLPAncestor

@property NSString* url;
@property NSString* height;
@property NSString* width;

+ (id<KLPDeserializable>) allocate;
@end

@implementation KLPFThumbnail
+ (id<KLPDeserializable>) allocate {
    return [[KLPFThumbnail alloc] init];
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

+ (id<KLPDeserializable>) allocate;
@end

@implementation KLPFNestedObject
+ (id<KLPDeserializable>) allocate {
    return [[KLPFNestedObject alloc] init];
}
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
# Custom fields mapping
## Naming strategies
Naming strategy - is a class that decides how the name of field from class should be translated to the name in a JSON. 
KlappaDeSerializer provides two strategies out of the box: KLPDefaultNamingStrategy and KLPExplicitNamingStrategy.
Explicit naming strategy is translates field from class one-to-one. For example, if you have field named "awesome_field" it will be translated to field "awesme_field" in the JSON. 
Default naming strategy translates camelCase to snake_case, i.e. if you have field "awesomeField" in your class, library will search for field "awesome_field" in a JSON.
Currently possibility of swapping global strategy on the fly is not supported - it's supposed to be added in next releases.

## Class-local fields mapping
Sometimes you want to set custom mapping for one or two fields for one class and don't set it globally, as with naming strategies. In KlappaInjector you can achieve it in two ways - by implementing function:
```objective-c
+ (NSDictionary*) getCustomFieldsMapping;
```
or by implementing function:
```objective-c
+ (id<KLPNamingStrategy>) getNamingStrategy;
```

In getCustomFieldsMapping function you define how one field will be translated to another. So lets assume you have field "url" in your class and in JSON it corresponds to "super_puper_awesome_url". In such case you can implement function in following way:
```objective-c
+ (NSDictionary*) getCustomFieldsMapping {
    return @{@"url": @"super_puper_awesome_url"};
}
```
However, this will let you to translate fields one by one. If you want to set different naming strategy for class (i.e. one entity in API for some reason have different naming strategy), you should implement getNamingStrategy instead. That fucntion should define strategy of converting class' fields to JSON fields for this particular class.

# Required properties
It's quite common that in your network model you have some fields that are necessary for application to work and you don't want to pass objects that doesn't have those fields. KlappaInjector allows you to specify such required fields. In order to do so, you must implement function:
```objective-c
+ (NSArray*) getRequiredFields;
```
Basically, let consider that you have field "id" in your model class and you want it to be present all the time. In such case, you should implement this function in a following way:
```objective-c
+ (NSArray*) getRequiredFields {
    return @[@"id"];
}
```
So, in this particular case, if KlappaInjector meet JSON that doesn't have "id" in it - it will return nil, even if the rest of fields is here.

# Warnings and restrictions
Note that all classes to which you want to deserialize JSON must conform to KLPDeserializable protocol. 
Please, **DO NOT** make extension on NSObject to conform to this protocol, inherit your classes from KLPAncestor instead.

# Contributing
All contributions and feedback are very appreciated and welcomed. If you have some issues or questions how KlappaDeSerializer works - you always can ask it in issues section or provide fix as Pull Request.
