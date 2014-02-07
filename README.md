LGBluetooth
===========

Simple, block-based, lightweight library over CoreBluetooth.

<h2>Steps to start using</h2>

1. Drag and Drop it into your project

2. Import "LGBluetooth.h"

3. You are ready to go!

<h2>Usage - </h2>

For example we have a peripheral which has "5ec0" service, with 3 characteristics
<img src="https://raw2.github.com/DavidSahakyan/LGBluetooth/master/Screenshots/1.PNG" width="320" height="480"><br>

"cef9" characteristic is writable
"f045" characteristic is readable
"8fdb" characteristic is readable

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
    [peripheral connectWithCompletion:^(NSError *error) {
        [peripheral discoverServicesWithCompletion:^(NSArray *services, NSError *error) {
            for (LGService *service in services) {
                if ([service.UUIDString isEqualToString:@"5ec0"]) {
                    [service discoverCharacteristicsWithCompletion:^(NSArray *characteristics, NSError *error) {
                        __block int i = 0;
                        for (LGCharacteristic *charact in characteristics) {
                            if ([charact.UUIDString isEqualToString:@"cef9"]) {
                                [charact writeByte:0xFF completion:^(NSError *error) {
                                    if (++i == 3) {
                                        [peripheral disconnectWithCompletion:nil];
                                    }
                                }];
                            } else {
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

<img src="https://raw2.github.com/DavidSahakyan/LGBluetooth/master/Screenshots/5.PNG" width="320" height="480"><br>

In this example I'm scanning peripherals for 4 seconds.
After which I am passing first peripheral to test method.

Test method connects to peripheral, discoveres services, discoveres characteristics of "5ec0" service.
Aftter which reads "f045", "8fdb", and writes 0xFF to "cef9" and disconnects from peripheral.

<h2>LICENSE</h2>
LGBluetooth is under MIT License (see LICENSEE file)

