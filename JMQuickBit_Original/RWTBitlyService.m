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

#import "RWTBitlyService.h"
#import "RWTBitlyShortenedUrlModel.h"


@interface RWTBitlyService ()

@property (strong, nonatomic) NSString *accessToken;
@property (strong, nonatomic) NSURLSession *session;

@end

NSString * const kRWTBitlyServiceBaseURLString = @"https://api-ssl.bitly.com/";

@implementation RWTBitlyService

- (instancetype)initWithOAuthAccessToken:(NSString *)accessToken {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _accessToken = accessToken;
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    _session = [NSURLSession sessionWithConfiguration:configuration];
    
    return self;
}

- (void)shortenUrl:(NSURL *)longUrl
            domain:(NSString *)domain
        completion:(RWTBitlyShortenUrlCompletion)completion {
    
    NSURLComponents *urlComponents = [NSURLComponents componentsWithString:kRWTBitlyServiceBaseURLString];
    urlComponents.path = @"/v3/shorten";
    
    NSURLQueryItem *accessTokenItem = [NSURLQueryItem queryItemWithName:@"access_token" value:self.accessToken];
    NSURLQueryItem *longUrlItem = [NSURLQueryItem queryItemWithName:@"longUrl" value:longUrl.absoluteString];
    NSURLQueryItem *domainItem = [NSURLQueryItem queryItemWithName:@"domain" value:domain];
    
    urlComponents.queryItems = @[accessTokenItem, longUrlItem, domainItem];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:urlComponents.URL];
    
    
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error) {
            completion(nil, error);
        } else {
            NSError *jsonError = nil;
            NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
            if (jsonError) {
                completion(nil, jsonError);
            } else {
                NSInteger statusCode = [responseDict[@"status_code"]  integerValue];
                if (statusCode == 200) {
                    RWTBitlyShortenedUrlModel *shortenedUrl = [[RWTBitlyShortenedUrlModel alloc] initWithDictionary:responseDict[@"data"]];
                    completion(shortenedUrl, nil);
                } else {
                    NSError *requestError = [NSError errorWithDomain:@"com.raywenderlich.bitlykit" code:5001 userInfo:nil];
                    completion(nil, requestError);
                }
                
            }
        }
    }];
    
    [dataTask resume];
}

@end
