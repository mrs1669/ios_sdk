//
//  ViewController.m
//  AdjustTestApp
//
//  Created by Pedro Silva on 27.07.22.
//

#import "ViewController.h"

#import <AdjustTestLibrary/ATLTestLibrary.h>
#import <ADJAdjustInternal.h>>
#import "ATA5AdjustCommandExecutor.h"

// simulator
static NSString * baseUrl = @"http://127.0.0.1:8080";
static NSString * controlUrl = @"ws://127.0.0.1:1987";
// device
// static NSString * baseUrl = @"http://192.168.86.37:8080";
// static NSString * gdprUrl = @"http://192.168.86.37:8080";
// static NSString * subscriptionUrl = @"http://192.168.86.37:8080";
// static NSString * controlUrl = @"ws://192.168.86.37:1987";


@interface ViewController ()

@property (nonatomic, strong) ATLTestLibrary *testLibrary;
//@property (nonatomic, strong) ATAAdjustCommandExecutor *adjustCommandExecutor;
@property (nonatomic, strong) ATA5AdjustCommandExecutor *adjustV5CommandExecutor;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self v5TestSession];
}

- (void)v5TestSession {
    self.testLibrary = [[ATLTestLibrary alloc] initWithBaseUrl:baseUrl
                                                    controlUrl:controlUrl];

    self.adjustV5CommandExecutor =
        [[ATA5AdjustCommandExecutor alloc] initWithUrl:baseUrl
                                           testLibrary:self.testLibrary];

    self.testLibrary.dictionaryParametersDelegate = self.adjustV5CommandExecutor;

    //[self.testLibrary addTest:@"Test_GlobalParameters_clear"];
    //[self.testLibrary addTestDirectory:@"gdpr"];
}

- (IBAction)clickv5StartTestSession:(UIButton *)sender {
    [self.testLibrary startTestSession:[ADJAdjustInternal sdkVersion]];
}


@end
