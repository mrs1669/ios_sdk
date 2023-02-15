//
//  ViewController.m
//  AdjustTestApp
//
//  Created by Genady Buchatsky on 27.07.22.
//

#import "ViewController.h"

#import "ATLTestLibrary.h"
#import "ADJAdjustInternal.h"
#import "ATAAdjustCommandExecutor.h"

// simulator
static NSString * baseUrl = @"http://127.0.0.1:8080";
static NSString * controlUrl = @"ws://127.0.0.1:1987";
// device
// static NSString * baseUrl = @"http://192.168.86.37:8080";
// static NSString * gdprUrl = @"http://192.168.86.37:8080";
// static NSString * subscriptionUrl = @"http://192.168.86.37:8080";
// static NSString * controlUrl = @"ws://192.168.86.37:1987";


@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *btnStartTestSession;
@property (nonatomic, strong) ATLTestLibrary *testLibrary;
@property (nonatomic, strong) ATAAdjustCommandExecutor *adjustCommandExecutor;

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

    self.adjustCommandExecutor =
    [[ATAAdjustCommandExecutor alloc] initWithUrl:baseUrl
                                      testLibrary:self.testLibrary];

    self.testLibrary.dictionaryParametersDelegate = self.adjustCommandExecutor;

    [self.testLibrary addTestDirectory:@"ad-revenue"];
    [self.testLibrary addTestDirectory:@"attribution"];
    [self.testLibrary addTestDirectory:@"attribution-callback"];
    [self.testLibrary addTestDirectory:@"background-tracking"];
    [self.testLibrary addTestDirectory:@"certificate"];
    [self.testLibrary addTestDirectory:@"continue-in"];
    [self.testLibrary addTestDirectory:@"coppa"];
    [self.testLibrary addTestDirectory:@"deeplink"];
    [self.testLibrary addTestDirectory:@"default-tracker"];
    [self.testLibrary addTestDirectory:@"disable-third-party-sharing"];
    [self.testLibrary addTestDirectory:@"event-tracking"];
    [self.testLibrary addTestDirectory:@"gdpr"];
    [self.testLibrary addTestDirectory:@"global-parameters"];
    [self.testLibrary addTestDirectory:@"init-malformed"];
    [self.testLibrary addTestDirectory:@"measurement-consent"];
    [self.testLibrary addTestDirectory:@"migration"];
    [self.testLibrary addTestDirectory:@"offline-mode"];
    [self.testLibrary addTestDirectory:@"push-token"];
    [self.testLibrary addTest:@"Test_PushToken_de_duplication"];
    [self.testLibrary addTestDirectory:@"retry-in"];
    [self.testLibrary addTestDirectory:@"session-tracking"];
    [self.testLibrary addTestDirectory:@"stop-restart"];
    [self.testLibrary addTestDirectory:@"third-party-sharing"];

}

- (IBAction)onBtnStartTestSessionPressDidReceive:(UIButton *)sender {
    [self.testLibrary startTestSession:[ADJAdjustInternal sdkVersion]];
}

@end

