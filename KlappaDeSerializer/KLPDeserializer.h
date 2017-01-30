//
//  KLPDeserializer.h
//  KlappaDeSerializer
//
//  Created by Ilja Kosynkin on 1/22/17.
//  Copyright © 2017 Ilja Kosynkin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KLPNamingStrategy.h"

@protocol KLPDeserializer <NSObject>
- (void) setGlobalNamingStrategy:(id<KLPNamingStrategy>) strategy;
- (id) deserialize:(Class) classToDeserialize json:(NSDictionary*) jsonToDeserialize;
@end
