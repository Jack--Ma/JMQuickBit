//
//  ActionRequestHandler.m
//  JMQuickBit Action
//
//  Created by JackMa on 15/12/5.
//  Copyright © 2015年 JackMa. All rights reserved.
//

#import "ActionRequestHandler.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "RWTBitlyService.h"
#import "RWTBitlyShortenedUrlModel.h"
#import "RWTBitlyHistoryService.h"

@interface ActionRequestHandler ()

@property (nonatomic, strong) NSExtensionContext *extensionContext;

@end

@implementation ActionRequestHandler

//由Host App传入context参数
- (void)beginRequestWithExtensionContext:(NSExtensionContext *)context {
  //在不使用interface情况下，不要调用super
  self.extensionContext = context;
  
  //从inputItems中获取第一个对象
  NSExtensionItem *extensionItem = context.inputItems.firstObject;
  if (!extensionItem) {
    [self doneWithResults:nil];
    return;
  }

  //从extensionItem中获取第一个对象
  NSItemProvider *itemProvider = extensionItem.attachments.firstObject;
  if (!itemProvider) {
    [self doneWithResults:nil];
    return;
  }
  
  //检查标识符是否为kUTTypePropertyList，如果是进行下一步处理
  if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypePropertyList]) {
    [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypePropertyList options:nil completionHandler:^(id<NSSecureCoding>  _Nullable item, NSError * _Null_unspecified error) {
      NSDictionary *dictionary = (NSDictionary *)item;
      [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        //拆包，取出字典中NSExtensionJavaScriptPreprocessingResultsKey的值，Safari将用到这个JS对象
        //在这里使用主队列十分必要，因为itemLoadCompletedWithPreprocessingResults方法是异步进行的
        [self itemLoadCompletedWithPreprocessingResults:dictionary[NSExtensionJavaScriptPreprocessingResultsKey]];
      }];
    }];
  } else {
    [self doneWithResults:nil];
  }
}

- (void)itemLoadCompletedWithPreprocessingResults:(NSDictionary *)javaScriptPreprocessingResults {
  //在这里接受你从Action.js中的run函数传来的参数
  NSString *currentURLString = javaScriptPreprocessingResults[@"currentURL"];
  
#warning SET TO YOUR ACCESS TOKEN
  RWTBitlyService *bitlyService = [[RWTBitlyService alloc] initWithOAuthAccessToken:@"fcc98e0289365e2c4f333a9bc1f336513ebf8aff"];
  
  //调用shortenUrl:方法对链接进行处理
  NSURL *longURL = [NSURL URLWithString:currentURLString];
  [bitlyService shortenUrl:longURL domain:@"bit.ly" completion:^(RWTBitlyShortenedUrlModel *shortUrl, NSError *error) {
    if (!error) {
      NSURL *shortURL = shortUrl.shortUrl;
      [UIPasteboard generalPasteboard].URL = shortURL;
      [[RWTBitlyHistoryService sharedService] addItem:shortUrl];
      //通过这一步将数据保存在AppGroup下，在主程序中也可以获取到这个共享的数据
      [[RWTBitlyHistoryService sharedService] persistItemsArray];
      
      NSDictionary *dic = @{@"shortURL": shortURL.absoluteString};
      [self doneWithResults:dic];
    }
  }];

}

//此方法将所得JS数据，返回给Host App，之后调用Action.js中的finalize函数
- (void)doneWithResults:(NSDictionary *)resultsForJavaScriptFinalize {
  if (resultsForJavaScriptFinalize) {
    //打包
    NSDictionary *resultsDictionary = @{ NSExtensionJavaScriptFinalizeArgumentKey: resultsForJavaScriptFinalize };
    
    //初始化NSExtensionItem对象，并把它传到Host App
    //顺序与beginRequestWithExtensionContext相反即可
    NSItemProvider *resultsProvider = [[NSItemProvider alloc] initWithItem:resultsDictionary typeIdentifier:(NSString *)kUTTypePropertyList];
    NSExtensionItem *resultsItem = [[NSExtensionItem alloc] init];
    resultsItem.attachments = @[resultsProvider];
  
    [self.extensionContext completeRequestReturningItems:@[resultsItem] completionHandler:nil];
  } else {
    [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
  }

  self.extensionContext = nil;
}

@end
