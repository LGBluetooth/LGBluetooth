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

#import "LGBluetooth.h"

@class LGPeripheral;
@class CBCentralManager;

typedef void (^LGCentralManagerDiscoverPeripheralsCallback) (NSArray *peripherals);
typedef void (^LGCentralManagerDiscoverPeripheralsChangesCallback) (LGPeripheral *peripheral);

/**
 * Wrapper class which implments common central role
 * over Core Bluetooth's CBCentralManager instance
 */
@interface LGCentralManager : NSObject

/**
 * Indicates if CBCentralManager is scanning for peripherals
 */
@property (nonatomic, getter = isScanning) BOOL scanning;

/**
 * Indicates if central manager is ready for core bluetooth tasks. KVO observable.
 */
@property (assign, nonatomic, readonly, getter = isCentralReady) BOOL centralReady;

/**
 * Threshould to stop scanning for peripherals.
 * When the number of discovered peripherals exceeds this value, scanning will be
 * stopped even before the scan-interval.
 */
@property (assign, nonatomic) NSUInteger peripheralsCountToStop;

/**
 * Human readable property that indicates why central manager is not ready. KVO observable.
 */
@property (weak, nonatomic, readonly) NSString *centralNotReadyReason;

/**
 * Peripherals that are nearby (sorted descending by RSSI values)
 */
@property (weak, nonatomic, readonly) NSArray *peripherals;

/**
 * Core bluetooth's Central manager, for implementing central role
 */
@property (strong, nonatomic, readonly) CBCentralManager *manager;

/**
 * KVO for centralReady and centralNotReadyReason
 */
+ (NSSet *)keyPathsForValuesAffectingCentralReady;

+ (NSSet *)keyPathsForValuesAffectingCentralNotReadyReason;


/**
 * Scans for nearby peripherals
 * and fills the - NSArray *peripherals
 * @param aChangesCallback block which will be called on each peripheral update
 */
- (void)scanForPeripheralsWithChanges:(LGCentralManagerDiscoverPeripheralsChangesCallback)aChangesCallback;


/**
 * Scans for nearby peripherals
 * and fills the - NSArray *peripherals
 */
- (void)scanForPeripherals;


/**
 * Makes scan for peripherals with criterias,
 * fills - NSArray *peripherals
 * @param serviceUUIDs An array of CBUUID objects that the app is interested in.
 * In this case, each CBUUID object represents the UUID of a service that
 * a peripheral is advertising.
 * @param options An optional dictionary specifying options to customize the scan.
 */
- (void)scanForPeripheralsWithServices:(NSArray *)serviceUUIDs
                               options:(NSDictionary *)options;

/**
 * Scans for nearby peripherals
 * and fills the - NSArray *peripherals.
 * Scan will be stoped after input interaval.
 * @param aScanInterval interval by which scan will be stoped
 * @param aChangesCallback block which will be called on each peripheral update
 * @param aCallback completion block will be called after
 * <i>aScanInterval</i> with nearby peripherals
 */
- (void)scanForPeripheralsByInterval:(NSUInteger)aScanInterval
                             changes:(LGCentralManagerDiscoverPeripheralsChangesCallback)aChangesCallback
                          completion:(LGCentralManagerDiscoverPeripheralsCallback)aCallback;

/**
 * Scans for nearby peripherals
 * and fills the - NSArray *peripherals.
 * Scan will be stoped after input interaval.
 * @param aScanInterval interval by which scan will be stoped
 * @param aCallback completion block will be called after
 * <i>aScanInterval</i> with nearby peripherals
 */
- (void)scanForPeripheralsByInterval:(NSUInteger)aScanInterval
                          completion:(LGCentralManagerDiscoverPeripheralsCallback)aCallback;

/**
 * Scans for nearby peripherals with criterias,
 * fills the - NSArray *peripherals.
 * Scan will be stoped after input interaval
 * @param aScanInterval interval by which scan will be stoped
 * @param serviceUUIDs An array of CBUUID objects that the app is interested in.
 * In this case, each CBUUID object represents the UUID of a service that
 * a peripheral is advertising.
 * @param options An optional dictionary specifying options to customize the scan.
 * @param aCallback completion block will be called after
 * <i>aScanInterval</i> with nearby peripherals
 */
- (void)scanForPeripheralsByInterval:(NSUInteger)aScanInterval
                            services:(NSArray *)serviceUUIDs
                             options:(NSDictionary *)options
                          completion:(LGCentralManagerDiscoverPeripheralsCallback)aCallback;

/**
 * Stops ongoing scan proccess
 */
- (void)stopScanForPeripherals;

/**
 * Returns a list of known peripherals by their identifiers.
 * @param identifiers A list of peripheral identifiers (represented by NSUUID objects)
 * from which LGperipheral objects can be retrieved.
 * @return A list of peripherals that the central manager is able to match to the provided identifiers.
 */
- (NSArray *)retrievePeripheralsWithIdentifiers:(NSArray *)identifiers;

/**
 * Returns a list of the peripherals (containing any of the specified services) currently connected to the system.
 * The list of connected peripherals can include those that are connected by other apps
 * and that will need to be connected locally using the connectPeripheral:options: method before they can be used.
 * @param serviceUUIDs A list of service UUIDs (represented by CBUUID objects).
 * @return A list of the LGPeripherals that are currently connected to
 * the system and that contain any of the services specified in the serviceUUID parameter.
 */
- (NSArray *)retrieveConnectedPeripheralsWithServices:(NSArray *)serviceUUIDS;

/**
 * @return Singleton instance of Central manager
 */
+ (LGCentralManager *)sharedInstance;

/**
 * Clean Singleton instance of Central manager
 */
+ (void) selfDestruct;

@end
