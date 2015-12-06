//
//  JMHistoryViewController.m
//  JMQuickBit
//
//  Created by JackMa on 15/12/4.
//  Copyright © 2015年 JackMa. All rights reserved.
//

#import "JMHistoryViewController.h"
#import "RWTBitlyHistoryService.h"
#import "RWTBitlyShortenedUrlModel.h"

@interface JMHistoryViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *historyTableView;

@end

@implementation JMHistoryViewController

- (void)viewDidLoad {
  [super viewDidLoad];
    
  self.title = @"History";
  self.historyTableView.delegate = self;
  self.historyTableView.dataSource = self;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [[RWTBitlyHistoryService sharedService] items].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  RWTBitlyShortenedUrlModel *shortUrl = [[RWTBitlyHistoryService sharedService] items][indexPath.row];
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Item"];
  cell.textLabel.text = shortUrl.shortUrl.absoluteString;
  cell.detailTextLabel.text = shortUrl.longUrl.absoluteString;
  
  return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  RWTBitlyShortenedUrlModel *shortUrl = [[RWTBitlyHistoryService sharedService] items][indexPath.row];
  
  UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Copy Link to Clipboard" message:@"Choose which link you want to copy to your clipboard." preferredStyle:UIAlertControllerStyleActionSheet];
  UIAlertAction *copyShortLinkAction = [UIAlertAction actionWithTitle:@"Short Link" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    [UIPasteboard generalPasteboard].URL = shortUrl.shortUrl;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
  }];
  UIAlertAction *copyLongLinkAction = [UIAlertAction actionWithTitle:@"Long Link" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    [UIPasteboard generalPasteboard].URL = shortUrl.longUrl;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
  }];
  UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
  }];
  
  [alertController addAction:copyShortLinkAction];
  [alertController addAction:copyLongLinkAction];
  [alertController addAction:cancelAction];
  
  [self presentViewController:alertController animated:YES completion:nil];
}

@end
