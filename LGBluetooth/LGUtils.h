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

#ifndef LG_BLE_SILENCE
#ifdef DEBUG
#define LG_ENABLE_BLE_LOGGING 1
#else
#define LG_ENABLE_BLE_LOGGING 0
#endif
#endif

#if LG_ENABLE_BLE_LOGGING != 0
#ifdef LOG_VERBOSE
#define LGLog(...) DDLogInfo(__VA_ARGS__)
#define LGLogError(...) DDLogError(__VA_ARGS__)
#else
#define LGLog(...) NSLog(@"%s(%p) %@", __PRETTY_FUNCTION__, self, [NSString stringWithFormat:__VA_ARGS__])
#define LGLogError(...) NSLog(@"%s(%p) %@", __PRETTY_FUNCTION__, self, [NSString stringWithFormat:__VA_ARGS__])
#endif
#else
#define LGLog(...) ((void)0)
#define LGLogError(...) ((void)0)
#endif

@interface LGUtils : NSObject

@end
