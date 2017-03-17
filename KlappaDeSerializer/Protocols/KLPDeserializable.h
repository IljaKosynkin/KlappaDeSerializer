//
//  KLPDeserializable.h
//  KlappaDeSerializer
//
//  Created by Ilja Kosynkin on 1/25/17.
//  Copyright © 2017 Ilja Kosynkin. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol KLPDeserializable
+ (id) alloc;
- (id) init;

+ (NSDictionary*) getFieldsToClassMap;
+ (NSDictionary*) getCustomFieldsMapping;
+ (NSArray*) getRequiredFields;
@end

@interface NSObject(KLPDeserializableCategory) <KLPDeserializable>

@end

@implementation NSObject(KLPDeserializableCategory)
+ (NSDictionary*) getFieldsToClassMap {
    return nil;
}

+ (NSDictionary*) getCustomFieldsMapping {
    return nil;
}


+ (NSArray*) getRequiredFields {
    return nil;
}
@end
