//
//  ViewController.m
//  AdjustExample-ObjC
//
//  Created by Aditi Agrawal on 23/08/22.
//

#import "ViewController.h"

#import "ADJAdjust.h"
#import "ADJAdjustInstance.h"
#import "ADJAdjustEvent.h"
#import "ADJAdjustAdRevenue.h"
#import "ADJAdjustPushToken.h"

NSString * _Nonnull cellReuseIdentifier = @"featureCell";

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *featuresTableView;
@property (nonatomic, strong) NSMutableArray *featuresList;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self setupUI];
    [self loadData];
}

#pragma mark - Load Data

- (void)setupUI {
    self.featuresTableView.delegate = self;
    self.featuresTableView.dataSource = self;
}

- (void)loadData {
    self.featuresList = [[NSMutableArray alloc] initWithObjects:@"Event Tracking",
                         @"Track Ad-Revenue",
                         @"Set SDK Online",
                         @"Set SDK Offline",
                         @"Enable SDK",
                         @"Disable SDK",
                         @"Add Global Callback Parameters",
                         @"Remove Global Callback Parameters",
                         @"Clear All Global Callback Parameters",
                         @"Add Global Partner Parameters",
                         @"Remove Global Partner Parameters",
                         @"Clear All Global Partner Parameters",
                         @"Track Push Token",
                         @"Activate Measurement Consent",
                         @"Inactivate Measurement Consent",
                         nil];
}


#pragma mark - Table view Delegate and Data Source

// number of rows in table view
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.featuresList.count;
}

// create a cell for each table view row
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // create a new cell if needed or reuse an old one
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];

    // set the text from the data model
    cell.textLabel.text = self.featuresList[indexPath.row];

    return cell;
}

// method to run when table view cell is tapped
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"You tapped cell number %ld.", (long)indexPath.row);

    switch(indexPath.row){
        case 0:
            [self trackEvent];
            break;
        case 1:
            [self trackAdRevenue];
            break;
        case 2:
            [self goOnline];
            break;
        case 3:
            [self goOffline];
            break;
        case 4:
            [self reactivateAdjustSDK];
            break;
        case 5:
            [self inactivateAdjustSDK];
            break;
        case 6:
            [self addGlobalCallbackParameters];
            break;
        case 7:
            [self removeGlobalCallbackParameters];
            break;
        case 8:
            [self clearAllGlobalCallbackParameters];
            break;
        case 9:
            [self addGlobalPartnerParameters];
            break;
        case 10:
            [self removeGlobalPartnerParameters];
            break;
        case 11:
            [self clearAllGlobalPartnerParameters];
            break;
        case 12:
            [self trackPushToken];
            break;
        case 13:
            [self activateMasurementConsent];
            break;
        case 14:
            [self inactivateMasurementConsent];
            break;
        default :
            NSLog(@"No functionality has been added.");
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)trackEvent {
    ADJAdjustEvent *event = [[ADJAdjustEvent alloc] initWithEventId:@"g3mfiw"];
    [event addCallbackParameterWithKey:@"partner" value:@"partnerValue"];
    [event addCallbackParameterWithKey:@"callback" value:@"callbackValue"];
    [[ADJAdjust instance] trackEvent:event];
}

- (void)trackAdRevenue {
    // initilise ADJAdRevenue instance with appropriate ad revenue source
    ADJAdjustAdRevenue *adRevenue = [[ADJAdjustAdRevenue alloc] initWithSource: ADJAdRevenueSourceMopub];
    // pass revenue and currency values
    [adRevenue setRevenueWithDouble:3.0 currency:@"USD"];

    // pass optional parameters
    //    [adRevenue setAdImpressionsCountWithInteger:3];
    //    [adRevenue setAdRevenueUnit:adRevenueUnit];
    //    [adRevenue setAdRevenuePlacement:adRevenuePlacement];
    //    [adRevenue setAdRevenueNetwork:adRevenueNetwork];
    // attach callback and/or partner parameter if needed
    [adRevenue addPartnerParameterWithKey:@"partner" value:@"partnerValue"];
    [adRevenue addCallbackParameterWithKey:@"callback" value:@"callbackValue"];

    // track ad revenue
    [[ADJAdjust instance] trackAdRevenue:adRevenue];
}

- (void)goOnline {
    [[ADJAdjust instance] switchBackToOnlineMode];
}

- (void)goOffline {
    [[ADJAdjust instance] switchToOfflineMode];
}

- (void)reactivateAdjustSDK {
    [[ADJAdjust instance] reactivateSdk];
}

- (void)inactivateAdjustSDK {
    [[ADJAdjust instance] inactivateSdk];
}

- (void)addGlobalCallbackParameters {
    [[ADJAdjust instance] addGlobalCallbackParameterWithKey:@"foo" value:@"bar"];
}

- (void)removeGlobalCallbackParameters {
    [[ADJAdjust instance] removeGlobalCallbackParameterByKey:@"foo"];
}

- (void)clearAllGlobalCallbackParameters {
    [[ADJAdjust instance] clearAllGlobalCallbackParameters];
}

- (void)addGlobalPartnerParameters {
    [[ADJAdjust instance] addGlobalPartnerParameterWithKey:@"foo" value:@"bar"];
}

- (void)removeGlobalPartnerParameters {
    [[ADJAdjust instance] removeGlobalPartnerParameterByKey:@"foo"];
}

- (void)clearAllGlobalPartnerParameters {
    [[ADJAdjust instance] clearAllGlobalPartnerParameters];
}

- (void)trackPushToken {
    ADJAdjustPushToken *_Nonnull adjustPushToken = [[ADJAdjustPushToken alloc]
                                                    initWithStringPushToken:@"965b251c6cb1926de3cb366fdfb16ddde6b9086a 8a3cac9e5f857679376eab7C"];
    [[ADJAdjust instance] trackPushToken:adjustPushToken];
}

- (void)activateMasurementConsent {
    [[ADJAdjust instance] activateMeasurementConsent];
}

- (void)inactivateMasurementConsent {
    [[ADJAdjust instance] inactivateMeasurementConsent];
}

@end

