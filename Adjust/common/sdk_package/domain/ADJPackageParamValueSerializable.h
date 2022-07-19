//
//  ADJPackageParamValueSerializable.h
//  Adjust
//
//  Created by Aditi Agrawal on 12/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

@import Foundation;

@class ADJNonEmptyString;

@protocol ADJPackageParamValueSerializable <NSObject>

- (nullable ADJNonEmptyString *)toParamValue;

@end
