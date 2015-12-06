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

#import "RWTBitlyShortenedUrlModel.h"

@implementation RWTBitlyShortenedUrlModel

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _globalHash = dictionary[@"global_hash"];
    _privateHash = dictionary[@"hash"];
    _longUrl = [NSURL URLWithString:dictionary[@"long_url"]];
    _shortUrl = [NSURL URLWithString:dictionary[@"url"]];
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _globalHash = [aDecoder decodeObjectForKey:@"globalHash"];
    _privateHash = [aDecoder decodeObjectForKey:@"hash"];
    _longUrl = [aDecoder decodeObjectForKey:@"longUrl"];
    _shortUrl = [aDecoder decodeObjectForKey:@"shortUrl"];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.globalHash forKey:@"globalHash"];
    [aCoder encodeObject:self.privateHash forKey:@"hash"];
    [aCoder encodeObject:self.longUrl forKey:@"longUrl"];
    [aCoder encodeObject:self.shortUrl forKey:@"shortUrl"];
}

- (BOOL)isEqual:(RWTBitlyShortenedUrlModel *)object {
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    if (![self.globalHash isEqualToString:object.globalHash]) {
        return NO;
    }
    
    if (![self.privateHash isEqualToString:object.privateHash]) {
        return NO;
    }
    
    if (![self.longUrl.absoluteString isEqualToString:object.longUrl.absoluteString]) {
        return NO;
    }
    
    if (![self.shortUrl.absoluteString isEqualToString:object.shortUrl.absoluteString]) {
        return NO;
    }
    
    return YES;
}

- (NSUInteger)hash {
    return self.globalHash.hash | self.privateHash.hash | self.longUrl.hash | self.shortUrl.hash;
}

@end
