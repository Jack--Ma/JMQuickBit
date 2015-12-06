//
//  MainViewController.m
//  JMQuickBit
//
//  Created by JackMa on 15/12/4.
//  Copyright © 2015年 JackMa. All rights reserved.
//

#import "MainViewController.h"
#import "RWTBitlyService.h"
#import "RWTBitlyShortenedUrlModel.h"
#import "RWTBitlyHistoryService.h"

typedef NS_ENUM(NSInteger, RWTMainViewControllerActionButtonState) {
  RWTMainViewControllerActionButtonStateShortenUrl,
  RWTMainViewControllerActionButtonStateCopyUrl
};

@interface MainViewController ()

@property (nonatomic, weak) IBOutlet UITextField *textField;
@property (nonatomic, weak) IBOutlet UISegmentedControl *segmentedController;
@property (nonatomic, weak) IBOutlet UIButton *button;
@property (nonatomic, weak) IBOutlet UILabel *label;

@property (nonatomic, strong) RWTBitlyService *bitlyService;
@property (nonatomic, strong) RWTBitlyShortenedUrlModel *shortURL;
@property (nonatomic, assign) RWTMainViewControllerActionButtonState actionButtonState;

@end

@implementation MainViewController

- (IBAction)buttonPressed:(id)sender {
  switch (self.actionButtonState) {
    case RWTMainViewControllerActionButtonStateShortenUrl:
      [self shortenURL];
      break;
    case RWTMainViewControllerActionButtonStateCopyUrl:
      [UIPasteboard generalPasteboard].URL = self.shortURL.shortUrl;
      self.label.hidden = NO;
      break;
    default:
      break;
  }
}
- (IBAction)textfieldChanged:(id)sender {
  self.actionButtonState = RWTMainViewControllerActionButtonStateShortenUrl;
  [self.button setTitle:@"Shorten" forState:UIControlStateNormal];
  self.label.hidden = YES;
}
#pragma mark - 私有方法
- (void)shortenURL {
  NSString *domain = nil;
  [self.view endEditing:YES];
  switch (self.segmentedController.selectedSegmentIndex) {
    case 0:
      domain = @"bit.ly";
      break;
    case 1:
      domain = @"j.mp";
      break;
    case 2:
      domain = @"bitly.com";
      break;
    default:
      domain = @"bit.ly"; // no reason we should hit this case, but default to bit.ly
      break;
  }
  NSURL *longURL = [NSURL URLWithString:self.textField.text];
  if (longURL) {
    [self.bitlyService shortenUrl:longURL domain:domain completion:^(RWTBitlyShortenedUrlModel *shortUrl, NSError *error) {
      dispatch_async(dispatch_get_main_queue(), ^{
        if (error) {
          [self presentError];
        } else {
          self.shortURL = shortUrl;
          [self.button setTitle:shortUrl.shortUrl.absoluteString forState:UIControlStateNormal];
          self.actionButtonState = RWTMainViewControllerActionButtonStateCopyUrl;
          [[RWTBitlyHistoryService sharedService] addItem:shortUrl];
        }
      });
    }];
  }
}

- (void)presentError {
  UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Unable to Shorten" message:@"Check your entered URL's format and try again." preferredStyle:UIAlertControllerStyleAlert];
  UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    [alert dismissViewControllerAnimated:YES completion:nil];
  }];
  
  [alert addAction:okAction];
  [self presentViewController:alert animated:YES completion:nil];
}

//恢复初始状态
- (void)resetView {
  self.textField.text = @"";
  self.actionButtonState = RWTMainViewControllerActionButtonStateShortenUrl;
  [self.button setTitle:@"Shorten" forState:UIControlStateNormal];
  self.label.hidden = YES;
}

//从后台进入App时，询问是否将剪贴板的内容拷贝到textField内
- (void)askToUseCilpboardIfUrlPresent {
  UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
  NSString *pasteboardString = pasteboard.string;
  NSURL *pasteboardURL = pasteboard.URL;
  if (!pasteboardURL) {
    pasteboardURL = [NSURL URLWithString:pasteboardString];
  }
  if (pasteboardURL) {
    if (![pasteboardURL.host isEqualToString:@"bit.ly"] &&
        ![pasteboardURL.host isEqualToString:@"j.mp"] &&
        ![pasteboardURL.host isEqualToString:@"bitly.com"]) { // don't ask to shorten already shortened urls
      UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Shorten clipboard item?" message:pasteboardURL.absoluteString preferredStyle:UIAlertControllerStyleAlert];
      UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self addPasteboardUrlToLongUrlTextField];
        [self dismissViewControllerAnimated:YES completion:nil];
      }];
      
      UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [self dismissViewControllerAnimated:YES completion:nil];
      }];
      
      [alert addAction:yesAction];
      [alert addAction:noAction];
      
      [self presentViewController:alert animated:YES completion:nil];
    }
  }
}

- (void)addPasteboardUrlToLongUrlTextField {
  UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
  NSString *pasteboardString = pasteboard.string;
  NSURL *pasteboardURL = pasteboard.URL;
  if (!pasteboardURL) {
    pasteboardURL = [NSURL URLWithString:pasteboardString];
  }
  if (pasteboard) {
    self.textField.text = pasteboardURL.absoluteString;
  }
}

- (void)respondToUIApplicationDidBecomeActiveNotification {
  [self resetView];
  [self askToUseCilpboardIfUrlPresent];
}

#pragma mark - 初始化
- (void)viewWillAppear:(BOOL)animated {
  [self.navigationController setNavigationBarHidden:YES animated:animated];
  [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
  [self.navigationController setNavigationBarHidden:NO animated:animated];
  [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
  [super viewDidLoad];
#warning SET TO YOUR ACCESS TOKEN
  self.bitlyService = [[RWTBitlyService alloc] initWithOAuthAccessToken:@"fcc98e0289365e2c4f333a9bc1f336513ebf8aff"];
  
  //设置button格式
  self.actionButtonState = RWTMainViewControllerActionButtonStateCopyUrl;
  self.button.layer.borderColor = [UIColor whiteColor].CGColor;
  self.button.layer.borderWidth = 1.0/[UIScreen mainScreen].scale;
  self.button.layer.cornerRadius = 15.0;
  
  //设置placeholder和白色横线
  NSAttributedString *placeholderString = [[NSAttributedString alloc] initWithString:@"URL" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor] }];
  self.textField.attributedPlaceholder = placeholderString;
  CALayer *bottonBorder = [CALayer layer];
  bottonBorder.frame = CGRectMake(0.0, self.textField.frame.size.height-2.0, self.textField.frame.size.width, 2.0);
  bottonBorder.backgroundColor = [UIColor whiteColor].CGColor;
  [self.textField.layer addSublayer:bottonBorder];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToUIApplicationDidBecomeActiveNotification) name:UIApplicationDidBecomeActiveNotification object:nil];
  
  [self resetView];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}
@end
