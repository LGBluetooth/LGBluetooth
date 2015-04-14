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

@class CBCharacteristic;

@interface LGCharacteristic : NSObject

typedef void (^LGCharacteristicReadCallback)  (NSData *data, NSError *error);
typedef void (^LGCharacteristicNotifyCallback)(NSError *error);
typedef void (^LGCharacteristicWriteCallback) (NSError *error);

/**
 * Core Bluetooth's CBCharacteristic instance
 */
@property (strong, nonatomic, readonly) CBCharacteristic *cbCharacteristic;

/**
 * NSString representation of 16/128 bit CBUUID
 */
@property (weak, nonatomic, readonly) NSString *UUIDString;

/**
 * Enables or disables notifications/indications for the characteristic 
 * value of characteristic.
 * @param notifyValue Enable/Disable notifications
 * @param aCallback Will be called after successfull/failure ble-operation
 */
- (void)setNotifyValue:(BOOL)notifyValue
            completion:(LGCharacteristicNotifyCallback)aCallback;

/**
 * Enables or disables notifications/indications for the characteristic
 * value of characteristic.
 * @param notifyValue Enable/Disable notifications
 * @param aCallback Will be called after successfull/failure ble-operation
 * @param uCallback Will be called after every new successful update
 */
- (void)setNotifyValue:(BOOL)notifyValue
            completion:(LGCharacteristicNotifyCallback)aCallback
              onUpdate:(LGCharacteristicReadCallback)uCallback;

/**
 * Writes input data to characteristic
 * @param data NSData object representing bytes that needs to be written
 * @param aCallback Will be called after successfull/failure ble-operation
 */
- (void)writeValue:(NSData *)data
        completion:(LGCharacteristicWriteCallback)aCallback;

/**
 * Writes input byte to characteristic
 * @param aByte byte that needs to be written
 * @param aCallback Will be called after successfull/failure ble-operation
 */
- (void)writeByte:(int8_t)aByte
       completion:(LGCharacteristicWriteCallback)aCallback;

/**
 * Reads characteristic value
 * @param aCallback Will be called after successfull/failure 
 * ble-operation with response
 */
- (void)readValueWithBlock:(LGCharacteristicReadCallback)aCallback;


// ----- Used for input events -----/

- (void)handleSetNotifiedWithError:(NSError *)anError;

- (void)handleReadValue:(NSData *)aValue error:(NSError *)anError;

- (void)handleWrittenValueWithError:(NSError *)anError;


/**
 * @return Wrapper object over Core Bluetooth's CBCharacteristic
 */
- (instancetype)initWithCharacteristic:(CBCharacteristic *)aCharacteristic;

@end
