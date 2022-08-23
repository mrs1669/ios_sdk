//
//  ViewController.m
//  AdjustExample-ObjC
//
//  Created by Aditi Agrawal on 23/08/22.
//

#import "ViewController.h"

#import "ADJAdjust.h"
#import "ADJAdjustEvent.h"

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
                         @"Event and Session callbacks",
                         @"Deep linking",
                         @"Session Parameters",
                         @"App Tracking Transparency framework",
                         @"Attribution Callbacks",
                         @"Track Ad-Revenue",
                         @"Track subscriptions",
                         @"Set Push Token",
                         @"Set SDK Online",
                         @"Set SDK Offline",
                         @"Enable SDK",
                         @"Disable SDK", nil];
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
            [self trackEventTapped];
            break;
        case 9:
            [self goOnline];
            break;
         case 10:
            [self goOffline];
            break;
        case 11:
           [self reactivateAdjustSDK];
           break;
        case 12:
           [self inactivateAdjustSDK];
           break;
        default :
            NSLog(@"No functionality has been added.");
    }
}

- (void)trackEventTapped {
    ADJAdjustEvent *event = [[ADJAdjustEvent alloc] initWithEventId:@"g3mfiw"];
    [ADJAdjust trackEvent:event];
}

- (void)goOnline {
    [ADJAdjust switchBackToOnlineMode];
}

- (void)goOffline {
    [ADJAdjust switchToOfflineMode];
}

- (void)reactivateAdjustSDK {
    [ADJAdjust reactivateSdk];
}

- (void)inactivateAdjustSDK {
    [ADJAdjust inactivateSdk];
}

@end

