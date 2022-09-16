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

        [self.testLibrary addTest:@"Test_AttributionCallback_ask_in_once"];
    //    [self.testLibrary addTest:@"Test_PushToken_before_install"];
//    [self.testLibrary addTest:@"Test_PushToken_after_install"];
    //    [self.testLibrary addTest:@"Test_Deeplink_after_start"];
    //    [self.testLibrary addTestDirectory:@"gdpr"];
    //    [self.testLibrary addTestDirectory:@"session-tracking"];
    //    [self.testLibrary addTestDirectory:@"event-tracking"];
    //    [self.testLibrary addTestDirectory:@"global-parameters"];
    //    [self.testLibrary addTestDirectory:@"push-token"];
    //    [self.testLibrary addTestDirectory:@"ad-revenue"];
    //    [self.testLibrary addTestDirectory:@"deeplink"];
    //    [self.testLibrary addTestDirectory:@"stop-restart"];
    //    [self.testLibrary addTest:@"Test_GlobalParameters_add"];
    //    [self.testLibrary addTest:@"Test_GlobalParameters_clear"];
    //    [self.testLibrary addTest:@"Test_GlobalParameters_overwrite"];
    //    [self.testLibrary addTest:@"Test_GlobalParameters_remove"];
    //    [self.testLibrary addTest:@"Test_GlobalParameters_synchronicity"];
    //    [self.testLibrary addTest:@"Test_GlobalParameters_clear"];
    //    [self.testLibrary addTestDirectory:@"gdpr"];
//        [self.testLibrary addTestDirectory:@"attribution"];
//    [self.testLibrary addTestDirectory:@"attribution-callback"];

    //    [self.testLibrary addTestDirectory:@"event-tracking"];
    //    [self.testLibrary addTestDirectory:@"global-parameters"];
    //    [self.testLibrary addTestDirectory:@"ad-revenue"];
    //    [self.testLibrary addTestDirectory:@"stop-restart"];
    //    [self.testLibrary addTest:@"Test_GlobalParameters_synchronicity"];

}

- (IBAction)onBtnStartTestSessionPressDidReceive:(UIButton *)sender {
    [self.testLibrary startTestSession:[ADJAdjustInternal sdkVersion]];
}

@end
