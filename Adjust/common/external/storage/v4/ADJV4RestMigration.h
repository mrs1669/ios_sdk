//
//  ADJV4RestMigration.h
//  Adjust
//
//  Created by Aditi Agrawal on 19/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJCommonBase.h"
#import "ADJV4FilesData.h"
#import "ADJV4UserDefaultsData.h"

@interface ADJV4RestMigration : ADJCommonBase

- (nonnull instancetype)
    initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory;

- (void)
    migrateFromV4WithV4FilesData:(nonnull ADJV4FilesData *)v4FilesData
    v4UserDefaultsData:(nonnull ADJV4UserDefaultsData *)v4UserDefaultsData;

@end
