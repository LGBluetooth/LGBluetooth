// The MIT License (MIT)
//
// Copyright (c) 2013 l0gg3r
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

#import "LGUtils.h"

#import <CoreBluetooth/CoreBluetooth.h>
#import "LGBluetooth.h"

/**
 * Error domain for Write errors
 */
NSString * const kLGUtilsWriteErrorDomain = @"LGUtilsWriteErrorDomain";

/**
 * Global key for providing errors of LGBluetooth
 */
NSString * const kLGErrorMessageKey = @"msg";

/**
 * Error code for write operation
 * Service was not found on peripheral
 */
const NSInteger kLGUtilsMissingServiceErrorCode = 410;

/**
 * Error code for write operation
 * Characteristic was not found on peripheral
 */
const NSInteger kLGUtilsMissingCharacteristicErrorCode = 411;

/**
 * Error message for write operation
 * Service was not found on peripheral
 */
NSString * const kLGUtilsMissingServiceErrorMessage = @"Provided service UUID doesn't exist in provided pheripheral";

/**
 * Error message for write operation
 * Characteristic was not found on peripheral
 */
NSString * const kLGUtilsMissingCharacteristicErrorMessage = @"Provided characteristic doesn't exist in provided service";;

@implementation LGUtils

/*----------------------------------------------------*/
#pragma mark - Public Methods -
/*----------------------------------------------------*/

+ (void)writeData:(NSData *)aData
      charactUUID:(NSString *)aCharacteristic
       seriveUUID:(NSString *)aService
       peripheral:(LGPeripheral *)aPeripheral
       completion:(LGCharacteristicWriteCallback)aCallback
{
    if (aPeripheral.cbPeripheral.state == CBPeripheralStateConnected) {
        [self writeData:aData
            charactUUID:aCharacteristic
             seriveUUID:aService
        readyPeripheral:aPeripheral
             completion:aCallback];
    } else {
        [aPeripheral connectWithTimeout:30 completion:^(NSError *error) {
            [self writeData:aData
                charactUUID:aCharacteristic
                 seriveUUID:aService
            readyPeripheral:aPeripheral
                 completion:aCallback];
        }];
    }
}

+ (void)readDataFromCharactUUID:(NSString *)aCharacteristic
                     seriveUUID:(NSString *)aService
                     peripheral:(LGPeripheral *)aPeripheral
                     completion:(LGCharacteristicReadCallback)aCallback
{
    if (aPeripheral.cbPeripheral.state == CBPeripheralStateConnected) {
        [self readDataFromCharactUUID:aCharacteristic
                           seriveUUID:aService
                      readyPeripheral:aPeripheral
                           completion:aCallback];
    } else {
        [aPeripheral connectWithTimeout:30 completion:^(NSError *error) {
            [self readDataFromCharactUUID:aCharacteristic
                               seriveUUID:aService
                          readyPeripheral:aPeripheral
                               completion:aCallback];
        }];
    }
}

/*----------------------------------------------------*/
#pragma mark - Private Methods -
/*----------------------------------------------------*/

+ (void)writeData:(NSData *)aData
      charactUUID:(NSString *)aCharacteristic
       seriveUUID:(NSString *)aService
  readyPeripheral:(LGPeripheral *)aPeripheral
       completion:(LGCharacteristicWriteCallback)aCallback;
{
    [aPeripheral discoverServices:@[[CBUUID UUIDWithString:aService]] completion:^(NSArray *services, NSError *error) {
        if (services.count && !error) {
            LGService *service = services[0];
            [service discoverCharacteristicsWithUUIDs:@[[CBUUID UUIDWithString:aCharacteristic]] completion:^(NSArray *characteristics, NSError *error) {
                if (characteristics.count) {
                    LGCharacteristic *characteristic = characteristics[0];
                    [characteristic writeValue:aData completion:aCallback];
                } else {
                    if (aCallback) {
                        if (!error) {
                            aCallback([LGUtils writeErrorWithCode:kLGUtilsMissingCharacteristicErrorCode
                                                          message:kLGUtilsMissingCharacteristicErrorMessage]);
                        } else {
                            aCallback(error);
                        }
                    }
                }
            }];
        } else {
            if (aCallback) {
                if (!error) {
                    aCallback([LGUtils writeErrorWithCode:kLGUtilsMissingServiceErrorCode
                                                  message:kLGUtilsMissingServiceErrorMessage]);
                } else {
                    aCallback(error);
                }
            }
        }
    }];
}

+ (void)readDataFromCharactUUID:(NSString *)aCharacteristic
                     seriveUUID:(NSString *)aService
                readyPeripheral:(LGPeripheral *)aPeripheral
                     completion:(LGCharacteristicReadCallback)aCallback;
{
    [aPeripheral discoverServices:@[[CBUUID UUIDWithString:aService]] completion:^(NSArray *services, NSError *error) {
        if (services.count && !error) {
            LGService *service = services[0];
            [service discoverCharacteristicsWithUUIDs:@[[CBUUID UUIDWithString:aCharacteristic]] completion:^(NSArray *characteristics, NSError *error) {
                if (characteristics.count) {
                    LGCharacteristic *characteristic = characteristics[0];
                    [characteristic readValueWithBlock:aCallback];
                } else {
                    if (aCallback) {
                        if (!error) {
                            aCallback(nil, [LGUtils writeErrorWithCode:kLGUtilsMissingCharacteristicErrorCode
                                                               message:kLGUtilsMissingCharacteristicErrorMessage]);
                        } else {
                            aCallback(nil, error);
                        }
                    }
                }
            }];
        } else {
            if (aCallback) {
                if (!error) {
                    aCallback(nil, [LGUtils writeErrorWithCode:kLGUtilsMissingServiceErrorCode
                                                       message:kLGUtilsMissingServiceErrorMessage]);
                } else {
                    aCallback(nil, error);
                }
            }
        }
    }];
}

/*----------------------------------------------------*/
#pragma mark - Error Generators -
/*----------------------------------------------------*/

+ (NSError *)writeErrorWithCode:(NSInteger)aCode message:(NSString *)aMsg
{
    return [NSError errorWithDomain:kLGUtilsWriteErrorDomain
                               code:aCode
                           userInfo:@{kLGErrorMessageKey : aMsg}];
}



@end
