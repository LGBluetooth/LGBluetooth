LGBluetooth
===========

Simple, block-based, lightweight library over CoreBluetooth.

<h2>Steps to start using</h2>

1. Drag and Drop it into your project

2. Import "LGBluetooth.h"

3. You are ready to go!

<h2>Usage</h2>

For example we have a peripheral which has "5ec0" service, with 3 characteristics
<img src="https://raw.github.com/SocialObjects-Software/LGBluetooth/master/Screenshots/1.PNG" width="320" height="480"><br>

* "cef9" characteristic is writable
* "f045" characteristic is readable
* "8fdb" characteristic is readable

<pre>
- (IBAction)testPressed:(UIButton *)sender
{
    [[LGCentralManager sharedInstance] scanForPeripheralsByInterval:4
                                                         completion:^(NSArray *peripherals)
     {
         if (peripherals.count) {
             [self testPeripheral:peripherals[0]];
         }
     }];
}

- (void)testPeripheral:(LGPeripheral *)peripheral
{   
    // First of all, opening connection
    [peripheral connectWithCompletion:^(NSError *error) {
        // Discovering services of peripheral
        [peripheral discoverServicesWithCompletion:^(NSArray *services, NSError *error) {
            // Searching in all services, our - 5ec0 service
            for (LGService *service in services) {
                if ([service.UUIDString isEqualToString:@"5ec0"]) {
                    // Discovering characteristics of 5ec0 service
                    [service discoverCharacteristicsWithCompletion:^(NSArray *characteristics, NSError *error) {
                        __block int i = 0;
                        // Searching writable characteristic - cef9
                        for (LGCharacteristic *charact in characteristics) {
                            if ([charact.UUIDString isEqualToString:@"cef9"]) {
                                [charact writeByte:0xFF completion:^(NSError *error) {
                                    if (++i == 3) {
                                        [peripheral disconnectWithCompletion:nil];
                                    }
                                }];
                            } else {
                                // Otherwise reading value
                                [charact readValueWithBlock:^(NSData *data, NSError *error) {
                                    if (++i == 3) {
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
</pre>

After running code we can see the result.

<img src="https://raw.github.com/SocialObjects-Software/LGBluetooth/master/Screenshots/5.PNG" width="320" height="480"><br>

In this example I'm scanning peripherals for 4 seconds.
After which I am passing first peripheral to test method.

Test method connects to peripheral, discoveres services, discoveres characteristics of "5ec0" service.
After which reads "f045", "8fdb", and writes 0xFF to "cef9" and disconnects from peripheral.

Here is the log from console 
<pre>
Connection with error - (null)
Service discovered - Battery
Service discovered - Current Time
Service discovered - Unknown (5ec0)
Characteristic discovered - Unknown (cef9)
Characteristic discovered - Unknown (f045)
Characteristic discovered - Unknown (8fdb)
Characteristic - Unknown (cef9) wrote with error - (null)
Characteristic - Unknown (f045) value - 1234567890 error - 
Characteristic - Unknown (8fdb) value - 11111111111 error - (null)
Disconnect with error - (null)
</pre>

<h2>Alternative use</h2>

You can make basic read/write via LGUtils class.
Note : This methods do NOT need active connection to peripheral,
they will open a connection if it doesn't exists.

Read example
<pre>
        [LGUtils readDataFromCharactUUID:@"f045"
                             serviceUUID:@"5ec0"
                              peripheral:peripheral
                              completion:^(NSData *data, NSError *error) {
                                  NSLog(@"Data : %s Error : %@", (char *)[data bytes], error);
                              }];
</pre>

Write example
<pre>
        int8_t dataToWrite = 0xFF;
        [LGUtils writeData:[NSData dataWithBytes:&dataToWrite length:sizeof(dataToWrite)]
               charactUUID:@"cef9"
               serviceUUID:@"5ec0"
                peripheral:peripheral completion:^(NSError *error) {
                    NSLog(@"Error : %@", error);
                }];

</pre>

<h2>Reasons of using LGBluetooth</h2>
As we know CoreBluetooth is very hard to use - 
The methods of objects in Core bluetooth are messy

For example connectPeripheral:options: is written in CBCentralManager,
discoverCharacteristics:forService is written in Peripheral,
writeValue:forCharacteristic:type, readValueForCharacteristic are also in Peripheral

This messy code makes CoreBluetooth development really painfull.
For example if you need to read characteristic value, you need to call "connect" on central object, wait for Central delegate callback,
After that call "discover services", wait peripheral delegate callback, "discover characteristic" which you planned and wait for delegate callback, "readValue" and again wait for delegate callback.
What will happen if your program will make 2 connections at once?
Handling such cases makes messy code, and raises hundred of bugs.

Don't worry, now you can forgot about that hell - LGBluetooth uses blocks for callbacks, you can start using modern code and hierarchical calls.


### Installation with CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries installation in your projects.

#### Podfile

```ruby
pod "LGBluetooth", "~> 1.1.2"
```

<h2>LICENSE</h2>
LGBluetooth is under MIT License (see LICENSE file)

