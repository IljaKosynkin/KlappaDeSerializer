//
//  KLPArrayTypeExtractor.h
//  KlappaDeSerializer
//
//  Created by Ilja Kosynkin on 2/5/17.
//  Copyright © 2017 Ilja Kosynkin. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol KLPArrayTypeExtractor <NSObject>
- (Class) getType:(id<KLPDeserializable>) object forField:(NSString*) fieldName;
@end
