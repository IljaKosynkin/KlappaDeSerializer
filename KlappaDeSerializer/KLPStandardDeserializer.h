//
//  KLPStandardDeserializer.h
//  KlappaDeSerializer
//
//  Created by Ilja Kosynkin on 1/22/17.
//  Copyright © 2017 Ilja Kosynkin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KLPDeserializer.h"
#import "KLPDeserializable.h"
#import "KLPValueConverter.h"
#import "KLPConvertedTypes.h"

@interface KLPStandardDeserializer : NSObject<KLPDeserializer>
- (void) setGlobalNamingStrategy:(id<KLPNamingStrategy>) strategy;
- (id) deserialize:(Class<KLPDeserializable>) classToDeserialize json:(NSDictionary*) jsonToDeserialize;
- (void) addValueConverter:(id<KLPValueConverter>) converter forField:(NSString*) fieldName forInputType:(Type) type forOutputClass:(Class*) output;
- (void) addValueConverterForCustomClass:(id<KLPValueConverter>) converter forField:(NSString*) fieldName forCustomClass:(Class*) type forOutputClass:(Class*) output;
@end
