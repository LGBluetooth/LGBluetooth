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

@class CBPeripheral;

typedef void(^LGPeripheralConnectionCallback)(NSError *error);
typedef void(^LGPeripheralDiscoverServicesCallback)(NSArray *services, NSError *error);
typedef void(^LGPeripheralRSSIValueCallback)(NSNumber *RSSI, NSError *error);

@interface LGPeripheral : NSObject

/**
 * Core Bluetooth's CBPeripheral instance
 */
@property (strong, nonatomic, readonly) CBPeripheral *cbPeripheral;

/**
 * Available services for this service,
 * will be updated after calling discoverServicesWithCompletion:
 */
@property (strong, nonatomic, readonly) NSArray *services;

/**
 * Indicates if latest disconect was made by watchdog
 * note : that watchdog works only by calling connectWithTimeout:completion:
 */
@property (assign, nonatomic, readonly) BOOL watchDogRaised;

/**
 * Signal strength of peripheral
 */
@property (assign, nonatomic) NSInteger RSSI;

/**
 * The advertisement data that was tracked from peripheral
 */
@property (strong, nonatomic) NSDictionary *advertisingData;

/**
 * Opens connection WITHOUT timeout to this peripheral
 * @param aCallback Will be called after successfull/failure connection
 */
- (void)connectWithCompletion:(LGPeripheralConnectionCallback)aCallback;

/**
 * Opens connection WITH timeout to this peripheral
 * @param aWatchDogInterval timeout after which, connection will be closed (if it was in stage isConnecting)
 * @param aCallback Will be called after successfull/failure connection
 */
- (void)connectWithTimeout:(NSUInteger)aWatchDogInterval
                completion:(LGPeripheralConnectionCallback)aCallback;

/**
 * Disconnects from peripheral peripheral
 * @param aCallback Will be called after successfull/failure disconnect
 */
- (void)disconnectWithCompletion:(LGPeripheralConnectionCallback)aCallback;

/**
 * Discoveres All services of this peripheral
 * @param aCallback Will be called after successfull/failure discovery
 */
- (void)discoverServicesWithCompletion:(LGPeripheralDiscoverServicesCallback)aCallback;

/**
 * Discoveres Input services of this peripheral
 * @param serviceUUIDs Array of CBUUID's that contain service UUIDs which
 * we need to discover
 * @param aCallback Will be called after successfull/failure ble-operation
 */
- (void)discoverServices:(NSArray *)serviceUUIDs
              completion:(LGPeripheralDiscoverServicesCallback)aCallback;


/**
 * Reads current RSSI of this peripheral, (note : requires active connection to peripheral)
 * @param aCallback Will be called after successfull/failure ble-operation
 */
- (void)readRSSIValueCompletion:(LGPeripheralRSSIValueCallback)aCallback;


// ----- Used for input events -----/

- (void)handleConnectionWithError:(NSError *)anError;

- (void)handleDisconnectWithError:(NSError *)anError;


/**
 * @return Wrapper object over Core Bluetooth's CBPeripheral
 */
- (instancetype)initWithPeripheral:(CBPeripheral *)aPeripheral;

@end
