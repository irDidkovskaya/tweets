//
//  TTDataManager.h
//  TTwitter
//
//  Created by Iryna Didkovska on 6/18/15.
//  Copyright (c) 2015 Iryna Didkovska. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTDataManager : NSObject
+ (instancetype)manager;
- (void)saveInfoToCoreData:(NSArray *)data completionHendler:(void(^)(BOOL willLoadNewContent))completionHendler;
@end
