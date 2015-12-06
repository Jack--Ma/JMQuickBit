/*
 * Copyright (c) 2014 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

@import UIKit;
#import "RWTBitlyHistoryService.h"

@interface RWTBitlyHistoryService ()

@property (strong, nonatomic) NSMutableArray *items;

@end

@implementation RWTBitlyHistoryService

+ (RWTBitlyHistoryService *)sharedService {
    static dispatch_once_t onceToken;
    static RWTBitlyHistoryService *_sharedService;
    dispatch_once(&onceToken, ^{
        _sharedService = [[self alloc] init];
    });
    
    return _sharedService;
}

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    [self loadItemsArray];
    if (!_items) {
        _items = [NSMutableArray array];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(persistItemsArray) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadItemsArray) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    return self;
}

- (void)addItem:(RWTBitlyShortenedUrlModel *)item {
    NSInteger indexOfItem = [_items indexOfObject:item];
    if (indexOfItem != NSNotFound) {
        [_items removeObject:item];
    }
    
    [_items insertObject:item atIndex:0];
}

- (NSArray *)items {
    return [_items copy];
}

- (void)loadItemsArray {
    NSMutableArray *items = nil;
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:[self savedItemsFileUrl].path];
    
    if (fileExists) {
        NSError *loadError;
        NSData *itemsData = [NSData dataWithContentsOfURL:[self savedItemsFileUrl] options:kNilOptions error:&loadError];
        if (loadError) {
            NSLog(@"Error loading history items: %@", loadError);
        } else {
            items = [[NSKeyedUnarchiver unarchiveObjectWithData:itemsData] mutableCopy];
        }
    } else {
        items = [NSMutableArray array];
    }
    
    _items = items;
}

- (void)persistItemsArray {
    NSData *itemsData = [NSKeyedArchiver archivedDataWithRootObject:_items];
    NSError *saveError;
    [itemsData writeToURL:[self savedItemsFileUrl] options:kNilOptions error:&saveError];
    if (saveError) {
        NSLog(@"Error persisting history items: %@", saveError);
    }
}

- (NSURL *)savedItemsFileUrl {
    return [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"RWTBitlyHistoryServiceItems.dat"];
}

- (NSURL *)applicationDocumentsDirectory {
#warning SET TO YOUR APP GROUP ID
    NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.qq100858433.JMQuickBit"];
    return containerURL;
}

@end
