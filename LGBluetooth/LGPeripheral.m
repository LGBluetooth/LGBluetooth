// The MIT License (MIT)
//
// Created by : l0gg3r
// Copyright (c) 2014 SocialObjects Software. All rights reserved.
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

#import "LGPeripheral.h"

#if TARGET_OS_IPHONE
#import <CoreBluetooth/CoreBluetooth.h>
#elif TARGET_OS_MAC
#import <IOBluetooth/IOBluetooth.h>
#endif
#import "LGCentralManager.h"
#import "LGUtils.h"

// Notifications

NSString * const kLGPeripheralDidConnect    = @"LGPeripheralDidConnect";

NSString * const kLGPeripheralDidDisconnect = @"LGPeripheralDidDisconnect";

// Error Domains
NSString * const kLGPeripheralConnectionErrorDomain = @"LGPeripheralConnectionErrorDomain";

// Error Codes
const NSInteger kConnectionTimeoutErrorCode = 408;
const NSInteger kConnectionMissingErrorCode = 409;

NSString * const kConnectionTimeoutErrorMessage = @"BLE Device can't be connected by given interval";
NSString * const kConnectionMissingErrorMessage = @"BLE Device is not connected";

@interface LGPeripheral ()<CBPeripheralDelegate>

@property (copy, atomic) LGPeripheralConnectionCallback       connectionBlock;
@property (copy, atomic) LGPeripheralConnectionCallback       disconnectBlock;
@property (copy, atomic) LGPeripheralDiscoverServicesCallback discoverServicesBlock;
@property (copy, atomic) LGPeripheralRSSIValueCallback        rssiValueBlock;

@property (readonly, nonatomic, getter = isConnected) BOOL connected;

@end

@implementation LGPeripheral

/*----------------------------------------------------*/
#pragma mark - Getter/Setter -
/*----------------------------------------------------*/

- (BOOL)isConnected
{
    return (self.cbPeripheral.state == CBPeripheralStateConnected);
}

- (NSString *)UUIDString
{
    return [self.cbPeripheral.identifier UUIDString];
}

- (NSString *)name
{
    return [self.cbPeripheral name];
}


/*----------------------------------------------------*/
#pragma mark - Overide Methods -
/*----------------------------------------------------*/

- (NSString *)description
{
    NSString *org = [super description];
    
    return [org stringByAppendingFormat:@" UUIDString: %@", self.UUIDString];
}


/*----------------------------------------------------*/
#pragma mark - Public Methods -
/*----------------------------------------------------*/

- (void)connectWithCompletion:(LGPeripheralConnectionCallback)aCallback
{
    _watchDogRaised = NO;
    self.connectionBlock = aCallback;
    [[LGCentralManager sharedInstance].manager connectPeripheral:self.cbPeripheral
                                                         options:nil];
}

- (void)connectWithTimeout:(NSUInteger)aWatchDogInterval
                completion:(LGPeripheralConnectionCallback)aCallback
{
    [self connectWithCompletion:aCallback];
    [self performSelector:@selector(connectionWatchDogFired)
               withObject:nil
               afterDelay:aWatchDogInterval];
}

- (void)disconnectWithCompletion:(LGPeripheralConnectionCallback)aCallback
{
    self.disconnectBlock = aCallback;
    [[LGCentralManager sharedInstance].manager cancelPeripheralConnection:self.cbPeripheral];
}

- (void)discoverServicesWithCompletion:(LGPeripheralDiscoverServicesCallback)aCallback
{
    [self discoverServices:nil
                completion:aCallback];
}

- (void)discoverServices:(NSArray *)serviceUUIDs
              completion:(LGPeripheralDiscoverServicesCallback)aCallback
{
    self.discoverServicesBlock = aCallback;
    if (self.isConnected) {
        [self.cbPeripheral discoverServices:serviceUUIDs];
    } else if (self.discoverServicesBlock) {
        self.discoverServicesBlock(nil, [self connectionErrorWithCode:kConnectionMissingErrorCode
                                                              message:kConnectionMissingErrorMessage]);
        self.discoverServicesBlock = nil;
    }
}

- (void)readRSSIValueCompletion:(LGPeripheralRSSIValueCallback)aCallback
{
    self.rssiValueBlock = aCallback;
    if (self.isConnected) {
        [self.cbPeripheral readRSSI];
    } else if (self.rssiValueBlock) {
        self.rssiValueBlock(nil, [self connectionErrorWithCode:kConnectionMissingErrorCode
                                                       message:kConnectionMissingErrorMessage]);
        self.rssiValueBlock = nil;
    }
}

/*----------------------------------------------------*/
#pragma mark - Handler Methods -
/*----------------------------------------------------*/

- (void)handleConnectionWithError:(NSError *)anError
{
    // Connection was made, canceling watchdog
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(connectionWatchDogFired)
                                               object:nil];
    LGLog(@"Connection with error - %@", anError);
    if (self.connectionBlock) {
        self.connectionBlock(anError);
    }
    self.connectionBlock = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:kLGPeripheralDidConnect
                                                        object:self
                                                      userInfo:@{@"error" : anError ? : [NSNull null]}];
}

- (void)handleDisconnectWithError:(NSError *)anError
{
    LGLog(@"Disconnect with error - %@", anError);
    if (self.disconnectBlock) {
        self.disconnectBlock(anError);
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:kLGPeripheralDidDisconnect
                                                            object:self
                                                          userInfo:@{@"error" : anError ? : [NSNull null]}];
    }
    self.disconnectBlock = nil;
}

/*----------------------------------------------------*/
#pragma mark - Error Generators -
/*----------------------------------------------------*/

- (NSError *)connectionErrorWithCode:(NSInteger)aCode message:(NSString *)aMsg
{
    return [NSError errorWithDomain:kLGPeripheralConnectionErrorDomain
                               code:aCode
                           userInfo:@{kLGErrorMessageKey : aMsg}];
}

/*----------------------------------------------------*/
#pragma mark - Private Methods -
/*----------------------------------------------------*/

- (void)connectionWatchDogFired
{
    _watchDogRaised = YES;
    __weak LGPeripheral *weakSelf = self;
    [self disconnectWithCompletion:^(NSError *error) {
        __strong LGPeripheral *strongSelf = weakSelf;
        if (strongSelf.connectionBlock) {
            // Delivering connection timeout
            strongSelf.connectionBlock([self connectionErrorWithCode:kConnectionTimeoutErrorCode
                                                             message:kConnectionTimeoutErrorMessage]);
        }
        self.connectionBlock = nil;
    }];
}

- (void)updateServiceWrappers
{
    NSMutableArray *updatedServices = [NSMutableArray new];
    for (CBService *service in self.cbPeripheral.services) {
        [updatedServices addObject:[[LGService alloc] initWithService:service]];
    }
    _services = updatedServices;
}

- (LGService *)wrapperByService:(CBService *)aService
{
    LGService *wrapper = nil;
    for (LGService *discovered in self.services) {
        if (discovered.cbService == aService) {
            wrapper = discovered;
            break;
        }
    }
    return wrapper;
}

/*----------------------------------------------------*/
#pragma mark - CBPeripheral Delegate -
/*----------------------------------------------------*/

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateServiceWrappers];

#if LG_ENABLE_BLE_LOGGING != 0
        for (LGService *aService in self.services) {
            LGLog(@"Service discovered - %@", aService.cbService.UUID);
        }
#endif
        
        if (self.discoverServicesBlock) {
            self.discoverServicesBlock(self.services, error);
        }
        self.discoverServicesBlock = nil;
    });
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service
             error:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self wrapperByService:service] handleDiscoveredCharacteristics:service.characteristics
                                                                   error:error];
    });
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error
{
    NSData *value = [characteristic.value copy];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[[self wrapperByService:characteristic.service]
          wrapperByCharacteristic:characteristic]
         handleReadValue:value error:error];
    });
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[[self wrapperByService:characteristic.service]
          wrapperByCharacteristic:characteristic]
         handleSetNotifiedWithError:error];
    });
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[[self wrapperByService:characteristic.service]
          wrapperByCharacteristic:characteristic]
         handleWrittenValueWithError:error];
    });
}

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.rssiValueBlock) {
            self.rssiValueBlock(peripheral.RSSI, error);
        }
        self.rssiValueBlock = nil;
    });
}

/*----------------------------------------------------*/
#pragma mark - Lifecycle -
/*----------------------------------------------------*/

- (instancetype)initWithPeripheral:(CBPeripheral *)aPeripheral
{
    if (self = [super init]) {
        _cbPeripheral = aPeripheral;
        _cbPeripheral.delegate = self;
    }
    return self;
}

@end
