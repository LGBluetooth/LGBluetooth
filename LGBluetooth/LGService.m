// The MIT License (MIT)
//
// Created by : l0gg3r
// Copyright (c) 2014 l0gg3r. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in
// the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
// the Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "LGService.h"

#import "CBUUID+StringExtraction.h"
#if TARGET_OS_IPHONE
#import <CoreBluetooth/CoreBluetooth.h>
#elif TARGET_OS_MAC
#import <IOBluetooth/IOBluetooth.h>
#endif
#import "LGCharacteristic.h"
#import "LGUtils.h"

@interface LGService ()

@property (copy, nonatomic) LGServiceDiscoverCharacterisitcsCallback discoverCharBlock;

@end

@implementation LGService

/*----------------------------------------------------*/
#pragma mark - Getter/Setter -
/*----------------------------------------------------*/

- (NSString *)UUIDString
{
    return [self.cbService.UUID representativeString];
}

/*----------------------------------------------------*/
#pragma mark - Public Methods -
/*----------------------------------------------------*/

- (void)discoverCharacteristicsWithCompletion:(LGServiceDiscoverCharacterisitcsCallback)aCallback
{
    [self discoverCharacteristicsWithUUIDs:nil
                                completion:aCallback];
}

- (void)discoverCharacteristicsWithUUIDs:(NSArray *)uuids
                              completion:(LGServiceDiscoverCharacterisitcsCallback)aCallback
{
    self.discoverCharBlock = aCallback;
    _discoveringCharacteristics = YES;
    [self.cbService.peripheral discoverCharacteristics:uuids
                                            forService:self.cbService];
}

- (LGCharacteristic *)wrapperByCharacteristic:(CBCharacteristic *)aChar
{
    LGCharacteristic *wrapper = nil;
    for (LGCharacteristic *discovered in self.characteristics) {
        if (discovered.cbCharacteristic == aChar) {
            wrapper = discovered;
            break;
        }
    }
    return wrapper;
}

/*----------------------------------------------------*/
#pragma mark - Private Methods -
/*----------------------------------------------------*/

- (void)updateCharacteristicWrappers
{
    NSMutableArray *updatedCharacteristics = [NSMutableArray new];
    for (CBCharacteristic *characteristic in self.cbService.characteristics) {
        [updatedCharacteristics addObject:[[LGCharacteristic alloc] initWithCharacteristic:characteristic]];
    }
    _characteristics = updatedCharacteristics;
}


/*----------------------------------------------------*/
#pragma mark - Handler Methods -
/*----------------------------------------------------*/

- (void)handleDiscoveredCharacteristics:(NSArray *)aCharacteristics error:(NSError *)aError
{
    _discoveringCharacteristics = NO;
    [self updateCharacteristicWrappers];
#if LG_ENABLE_BLE_LOGGING != 0
    for (LGCharacteristic *aChar in self.characteristics) {
        LGLog(@"Characteristic discovered - %@", aChar.cbCharacteristic.UUID);
    }
#endif
    if (self.discoverCharBlock) {
        self.discoverCharBlock(self.characteristics, aError);
    }
    self.discoverCharBlock = nil;
}

/*----------------------------------------------------*/
#pragma mark - Lifecycle -
/*----------------------------------------------------*/

- (instancetype)initWithService:(CBService *)aService
{
    if (self = [super init]) {
        _cbService = aService;
    }
    return self;
}

@end
