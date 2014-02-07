//
//  LGViewController.m
//  LGBluetoothExample
//
//  Created by David Sahakyan on 2/7/14.
//  Copyright (c) 2014 David Sahakyan. All rights reserved.
//

#import "LGViewController.h"

#import "LGBluetooth.h"

@implementation LGViewController

- (IBAction)testPressed:(UIButton *)sender
{
    // Scaning 4 seconds for peripherals
    [[LGCentralManager sharedInstance] scanForPeripheralsByInterval:4
                                                         completion:^(NSArray *peripherals)
     {
         // If we found any peripherals sending to test
         if (peripherals.count) {
             [self testPeripheral:peripherals[0]];
         }
     }];
}

- (void)testPeripheral:(LGPeripheral *)peripheral
{
    // First of all connecting to peripheral
    [peripheral connectWithCompletion:^(NSError *error) {
        // Discovering services of peripheral
        [peripheral discoverServicesWithCompletion:^(NSArray *services, NSError *error) {
            for (LGService *service in services) {
                // Finding out our service
                if ([service.UUIDString isEqualToString:@"5ec0"]) {
                    // Discovering characteristics of our service
                    [service discoverCharacteristicsWithCompletion:^(NSArray *characteristics, NSError *error) {
                        // We need to count down completed operations for disconnecting
                        __block int i = 0;
                        for (LGCharacteristic *charact in characteristics) {
                            // cef9 is a writabble characteristic, lets test writting
                            if ([charact.UUIDString isEqualToString:@"cef9"]) {
                                [charact writeByte:0xFF completion:^(NSError *error) {
                                    if (++i == 3) {
                                        // finnally disconnecting
                                        [peripheral disconnectWithCompletion:nil];
                                    }
                                }];
                            } else {
                                // Other characteristics are readonly, testing read
                                [charact readValueWithBlock:^(NSData *data, NSError *error) {
                                    if (++i == 3) {
                                        // finnally disconnecting
                                        [peripheral disconnectWithCompletion:nil];
                                    }
                                }];
                            }
                        }
                    }];
                }
            }
        }];
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Initialization of CentralManager
    [LGCentralManager sharedInstance];
}

@end
