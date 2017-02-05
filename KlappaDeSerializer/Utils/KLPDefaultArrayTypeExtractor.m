//
//  KLPArrayTypeExtractor.m
//  KlappaDeSerializer
//
//  Created by Ilja Kosynkin on 2/5/17.
//  Copyright © 2017 Ilja Kosynkin. All rights reserved.
//

#import "KLPDefaultArrayTypeExtractor.h"

@implementation KLPDefaultArrayTypeExtractor
- (Class) getType:(NSObject<KLPDeserializable>*) object forField:(NSString*) fieldName {
    NSDictionary* dictionary = [[object class] getFieldsToClassMap];
    return dictionary[fieldName];
}
@end
