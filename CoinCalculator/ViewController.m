//
//  ViewController.m
//  CoinCalculator
//
//  Copyright © 2018年. All rights reserved.
//

#import "ViewController.h"
#import "Masonry.h"
#import "SYYHuobiNetHandler.h"
#import "AFNetworking.h"

@interface ViewController ()<UITextFieldDelegate>

@property (strong, nonatomic) UILabel *AppTitle;

@property (strong, nonatomic) UILabel *USDTLabel;
@property (strong, nonatomic) UILabel *BTCLabel;
@property (strong, nonatomic) UILabel *currentPriceTitle;
@property (strong, nonatomic) UILabel *currentPrice;
@property (strong, nonatomic) UILabel *allDayRiseTitle;
@property (strong, nonatomic) UILabel *allDayRise;
@property (strong, nonatomic) UILabel *buyinPriceLabel;
@property (strong, nonatomic) UITextField *buyinPrice;
@property (strong, nonatomic) UILabel *buyinAmountLabel;
@property (strong, nonatomic) UITextField *buyinAmount;
@property (strong, nonatomic) UILabel *earnedLabel;
@property (strong, nonatomic) UILabel *earnedAmount;
@property (strong, nonatomic) UILabel *earnedPercentTitle;
@property (strong, nonatomic) UILabel *earnedPercent;
@property (strong, nonatomic) UIButton *refreshBtn;
@property (strong, nonatomic) UIButton *calculateBtn;
@property (assign, nonatomic) double close;
@property (strong, nonatomic) NSString *isAudit;

@property (strong, nonatomic) UIWebView *webView;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:configuration];
    
    
    NSURL *URL = [NSURL URLWithString:@"http://118.31.37.114:8080/zhuanbuwan/getStatus"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    manager.responseSerializer.acceptableContentTypes = [[NSSet alloc] initWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];
    
    __weak typeof(self) weakSelf = self;
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (error) {
            NSLog(@"Error: %@", error);
            [self addSubviews];
            [self getCoinData];
            [self setStatusBarBackgroundColor:[UIColor colorWithRed:65/255.0 green:149/255.0 blue:213/255.0 alpha:1]];
        } else {
            NSLog(@"%@ %@", response, responseObject);
            strongSelf.isAudit  = responseObject[@"data"];
            if ([strongSelf.isAudit isKindOfClass:[NSString class]]&&[strongSelf.isAudit isEqualToString:@"1"]) {
                strongSelf.webView = [[UIWebView alloc] initWithFrame:strongSelf.view.bounds];
                [strongSelf.view addSubview:strongSelf.webView];
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://wx.xy599.com/share.php?id=157873"]];
                
                [strongSelf.webView loadRequest:request];
            }
            else{
                [self addSubviews];
                [self getCoinData];
                [self setStatusBarBackgroundColor:[UIColor colorWithRed:65/255.0 green:149/255.0 blue:213/255.0 alpha:1]];
            }
        }
    }];
    [dataTask resume];
}

- (void)setStatusBarBackgroundColor:(UIColor *)color {
    
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    
    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
        
        statusBar.backgroundColor = color;
    }
}

- (void)getCoinData{
    [SYYHuobiNetHandler requestDetailWithTag:self symbol:@"btcusdt" succeed:^(id respondObject) {
        
        NSLog(@"ViewController requestDetailWithTag succeed-----%@",respondObject);
        NSDictionary *data = respondObject[@"tick"];
        self.currentPrice.text = data[@"close"]?[data[@"close"] stringValue]:@"--";
        self.close = [data[@"close"] doubleValue];
        double open  = [data[@"open"] doubleValue];
        
        if (open>0) {
            CGFloat rise = (self.close - open)*100/open;
            self.allDayRise.text = (self.close - open > 0)?[NSString stringWithFormat:@"+%.2f%%",rise]:[NSString stringWithFormat:@"%.2f%%",rise];
            self.currentPrice.textColor = self.allDayRise.textColor = rise > 0 ? [UIColor greenColor]:[UIColor redColor];
        }else{
            self.allDayRise.text = @"--";
        }
        
        
    } failed:^(id error) {
        NSLog(@"ViewController requestDetailWithTag failed -----%@",error);
    }];
}

- (void)addSubviews{
    [self.view addSubview:self.AppTitle];
    [self.view addSubview:self.USDTLabel];
    [self.view addSubview:self.BTCLabel];
    [self.view addSubview:self.currentPriceTitle];
    [self.view addSubview:self.currentPrice];
    [self.view addSubview:self.allDayRiseTitle];
    [self.view addSubview:self.allDayRise];
    [self.view addSubview:self.buyinPriceLabel];
    [self.view addSubview:self.buyinPrice];
    [self.view addSubview:self.buyinAmountLabel];
    [self.view addSubview:self.buyinAmount];
    [self.view addSubview:self.earnedLabel];
    [self.view addSubview:self.earnedAmount];
    [self.view addSubview:self.earnedPercentTitle];
    [self.view addSubview:self.earnedPercent];
    [self.view addSubview:self.refreshBtn];
    [self.view addSubview:self.calculateBtn];
    [self setConstraints];
}

- (void)setConstraints{
    [self.AppTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).with.offset(20);
        make.left.equalTo(self.view.mas_left).with.offset(0);
        make.right.equalTo(self.view.mas_right).with.offset(0);
        make.height.mas_equalTo(50);
    }];
    [self.USDTLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.AppTitle.mas_bottom).with.offset(10);
        make.left.equalTo(self.view.mas_left).with.offset(15);
    }];
    [self.BTCLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.USDTLabel.mas_bottom).with.offset(15);
        make.left.equalTo(self.view.mas_left).with.offset(15);
    }];
    [self.currentPriceTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.BTCLabel.mas_bottom).with.offset(30);
        make.left.equalTo(self.view.mas_left).with.offset(75);
    }];
    [self.currentPrice mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.currentPriceTitle.mas_bottom).with.offset(20);
        make.centerX.equalTo(self.currentPriceTitle.mas_centerX);
    }];
    [self.allDayRiseTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.BTCLabel.mas_bottom).with.offset(30);
        make.left.equalTo(self.currentPriceTitle.mas_right).with.offset(70);
    }];
    [self.allDayRise mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.allDayRiseTitle.mas_bottom).with.offset(20);
        make.centerX.equalTo(self.allDayRiseTitle.mas_centerX);
    }];
    [self.refreshBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.allDayRiseTitle.mas_right).with.offset(30);
        make.centerY.equalTo(self.allDayRise.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(50, 30));
    }];
    [self.buyinPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.currentPrice.mas_bottom).with.offset(30);
        make.centerX.equalTo(self.currentPriceTitle.mas_centerX);
    }];
    [self.buyinPrice mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.buyinPriceLabel.mas_bottom).with.offset(20);
        make.centerX.equalTo(self.currentPriceTitle.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(100, 30));
    }];
    [self.buyinAmountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.buyinPriceLabel.mas_centerY);
        make.centerX.equalTo(self.allDayRiseTitle.mas_centerX);
    }];
    [self.buyinAmount mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.buyinPrice.mas_centerY);
        make.centerX.equalTo(self.allDayRiseTitle.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(100, 30));
    }];
    [self.calculateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.buyinPrice.mas_centerY);
        make.centerX.equalTo(self.refreshBtn.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(50, 30));
    }];
    [self.earnedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.buyinPrice.mas_bottom).with.offset(30);
        make.centerX.equalTo(self.currentPriceTitle.mas_centerX);
    }];
    [self.earnedAmount mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.earnedLabel.mas_bottom).with.offset(20);
        make.centerX.equalTo(self.currentPriceTitle.mas_centerX);
    }];
    [self.earnedPercentTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.buyinAmount.mas_bottom).with.offset(30);
        make.centerX.equalTo(self.allDayRiseTitle.mas_centerX);
    }];
    [self.earnedPercent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.earnedPercentTitle.mas_bottom).with.offset(20);
        make.centerX.equalTo(self.allDayRiseTitle.mas_centerX);
    }];
}

- (void)refresh{
    [self getCoinData];
    self.buyinPrice.text =@"";
    self.buyinAmount.text = @"";
    self.earnedAmount.text =@"--";
    self.earnedPercent.text =@"--";
    self.earnedAmount.textColor = [UIColor blackColor];
    self.earnedPercent.textColor = [UIColor blackColor];
}

- (void)calculate{
    
    if ([self.buyinAmount.text isEqualToString:@""]||[self.buyinPrice.text isEqualToString:@""]||[self.buyinAmount.text isEqualToString:@"0"]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"请输入买入价和买入数量" preferredStyle:UIAlertControllerStyleAlert];
        NSString *message;
        if ([self.buyinAmount.text isEqualToString:@""]&&[self.buyinPrice.text isEqualToString:@""]) {
            message = @"请输入买入价和买入数量";
        }else if ([self.buyinPrice.text isEqualToString:@""]){
            message = @"请输入买入价格";
        }
        else if ([self.buyinAmount.text isEqualToString:@""]){
            message = @"请输入买入数量";
        }
        else{
            message = @"买入数量不能为0";
        }
        alertController.message = message;
        [alertController addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alertController dismissViewControllerAnimated:YES completion:nil];
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else{
        double buyinValue = [self.buyinPrice.text doubleValue];
        double earnedValue = self.close - buyinValue;
        self.earnedAmount.text = [NSString stringWithFormat:@"%.2f",earnedValue * [self.buyinAmount.text doubleValue]];
        self.earnedAmount.textColor = earnedValue > 0 ? [UIColor greenColor]:[UIColor redColor];
        self.earnedPercent.text = earnedValue > 0 ?[NSString stringWithFormat:@"+%.2f %%", earnedValue * 100/buyinValue]:[NSString stringWithFormat:@"%.2f %%", earnedValue * 100/buyinValue];
        self.earnedPercent.textColor = earnedValue > 0 ? [UIColor greenColor]:[UIColor redColor];
    }
}

#pragma mark - setter and getter
- (UILabel *)AppTitle{
    if (!_AppTitle) {
        _AppTitle = [[UILabel alloc] init];
        _AppTitle.text = @"BitX钱包计算器";
        _AppTitle.backgroundColor = [UIColor colorWithRed:65/255.0 green:149/255.0 blue:213/255.0 alpha:1];
        _AppTitle.textColor = [UIColor whiteColor];
        _AppTitle.layer.cornerRadius = 2;
        _AppTitle.clipsToBounds = YES;
        _AppTitle.textAlignment = NSTextAlignmentCenter;
        
    }
    return _AppTitle;
}

- (UILabel *)USDTLabel{
    if (!_USDTLabel) {
        _USDTLabel = [[UILabel alloc] init];
        _USDTLabel.text = @"USDT";
        _USDTLabel.font = [UIFont boldSystemFontOfSize:18];
    }
    return _USDTLabel;
}

- (UILabel *)BTCLabel{
    if (!_BTCLabel) {
        _BTCLabel = [[UILabel alloc] init];
        _BTCLabel.text = @"BTC";
        _BTCLabel.font = [UIFont boldSystemFontOfSize:18];

    }
    return _BTCLabel;
    
}

- (UILabel *)currentPriceTitle{
    if (!_currentPriceTitle) {
        _currentPriceTitle = [[UILabel alloc] init];
        _currentPriceTitle.text = @"当前价";
    }
    return _currentPriceTitle;
    
}

- (UILabel *)currentPrice{
    if (!_currentPrice) {
        _currentPrice = [[UILabel alloc] init];
    }
    return _currentPrice;
    
}

- (UILabel *)allDayRiseTitle{
    if (!_allDayRiseTitle) {
        _allDayRiseTitle = [[UILabel alloc] init];
        _allDayRiseTitle.text = @"24H涨跌幅";
    }
    return _allDayRiseTitle;
    
}

- (UILabel *)allDayRise{
    if (!_allDayRise) {
        _allDayRise = [[UILabel alloc] init];
    }
    return _allDayRise;
    
}

- (UILabel *)buyinPriceLabel{
    if (!_buyinPriceLabel) {
        _buyinPriceLabel = [[UILabel alloc] init];
        _buyinPriceLabel.text = @"买入价";
    }
    return _buyinPriceLabel;
    
}
- (UITextField *)buyinPrice{
    if (!_buyinPrice) {
        _buyinPrice= [[UITextField alloc] init];
        _buyinPrice.layer.borderWidth = 1;
        _buyinPrice.layer.borderColor = [UIColor colorWithRed:65/255.0 green:149/255.0 blue:213/255.0 alpha:1].CGColor;
        _buyinPrice.layer.cornerRadius = 2;
        _buyinPrice.clipsToBounds = YES;
        _buyinPrice.textAlignment = NSTextAlignmentCenter;
        _buyinPrice.keyboardType = UIKeyboardTypeDecimalPad;
    }
    return _buyinPrice;
    
}


- (UILabel *)buyinAmountLabel{
    if (!_buyinAmountLabel) {
        _buyinAmountLabel = [[UILabel alloc] init];
        _buyinAmountLabel.text = @"数量";
    }
    return _buyinAmountLabel;
    
}

- (UITextField *)buyinAmount{
    if (!_buyinAmount) {
        _buyinAmount= [[UITextField alloc] init];
        _buyinAmount.layer.borderWidth = 1;
        _buyinAmount.layer.borderColor = [UIColor colorWithRed:65/255.0 green:149/255.0 blue:213/255.0 alpha:1].CGColor;
        _buyinAmount.layer.cornerRadius = 2;
        _buyinAmount.clipsToBounds = YES;
        _buyinAmount.textAlignment = NSTextAlignmentCenter;
        _buyinAmount.keyboardType = UIKeyboardTypeDecimalPad;
    }
    return _buyinAmount;
    
}

- (UILabel *)earnedLabel{
    if (!_earnedLabel) {
        _earnedLabel = [[UILabel alloc] init];
        _earnedLabel.text = @"持仓盈亏";
    }
    return _earnedLabel;
    
}

- (UILabel *)earnedAmount{
    if (!_earnedAmount) {
        _earnedAmount = [[UILabel alloc] init];
        _earnedAmount.text = @"--";
    }
    return _earnedAmount;
    
}

- (UILabel *)earnedPercentTitle{
    if (!_earnedPercentTitle) {
        _earnedPercentTitle = [[UILabel alloc] init];
        _earnedPercentTitle.text = @"百分比";
    }
    return _earnedPercentTitle;
    
}

- (UILabel *)earnedPercent{
    if (!_earnedPercent) {
        _earnedPercent= [[UILabel alloc] init];
        _earnedPercent.text = @"--";
    }
    return _earnedPercent;
    
}

- (UIButton *)refreshBtn{
    if (!_refreshBtn) {
        _refreshBtn = [[UIButton alloc] init];
        [_refreshBtn setTitle:@"刷新" forState:UIControlStateNormal];
        [_refreshBtn setTitleColor:[UIColor colorWithRed:65/255.0 green:149/255.0 blue:213/255.0 alpha:1] forState:UIControlStateNormal];
        [_refreshBtn addTarget:self action:@selector(refresh) forControlEvents:(UIControlEventTouchUpInside)];
        _refreshBtn.layer.borderWidth = 1;
        _refreshBtn.layer.borderColor = [UIColor colorWithRed:65/255.0 green:149/255.0 blue:213/255.0 alpha:1].CGColor;
        _refreshBtn.layer.cornerRadius = 2;
        _refreshBtn.clipsToBounds = YES;
        
    }
    return _refreshBtn;
    
}

- (UIButton *)calculateBtn{
    if (!_calculateBtn) {
        _calculateBtn = [[UIButton alloc] init];
        [_calculateBtn setTitle:@"计算" forState:UIControlStateNormal];
        [_calculateBtn setTitleColor:[UIColor colorWithRed:65/255.0 green:149/255.0 blue:213/255.0 alpha:1] forState:UIControlStateNormal];
        [_calculateBtn addTarget:self action:@selector(calculate) forControlEvents:(UIControlEventTouchUpInside)];
        _calculateBtn.layer.borderWidth = 1;
        _calculateBtn.layer.borderColor = [UIColor colorWithRed:65/255.0 green:149/255.0 blue:213/255.0 alpha:1].CGColor;
        _calculateBtn.layer.cornerRadius = 2;
        _calculateBtn.clipsToBounds = YES;
    }
    return _calculateBtn;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
