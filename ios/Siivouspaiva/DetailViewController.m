//
//  DetailViewController.m
//  Siivouspaiva
//
//  Created by Fabian on 26.03.13.
//  Copyright (c) 2013 Fabian Häusler. All rights reserved.
//

#import "DetailViewController.h"
#import "WebLinkViewController.h"
#import "eventSpot.h"

@interface DetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *timeLabel1;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel2;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel3;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel4;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel5;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel6;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel7;

@end

@implementation DetailViewController
@synthesize tableView = _tableView;
@synthesize headerView;
@synthesize mapView = _mapView;
@synthesize infoContainer;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [headerView removeFromSuperview];
    self.tableView.tableHeaderView = headerView;
    
    self.mapView.delegate = self;
    
    //infoContainer.height = descriptionLabel.y+descriptionLabel.height+20;
    //headerView.frame.size.height = infoContainer.frame.origin.y+infoContainer.frame.size.height;
    
    
    // star Button
    UIButton *starButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *starButtonImage = [UIImage imageNamed:@"icon-star-line"];
    UIImage *starButtonImagePressed = [UIImage imageNamed:@"icon-star-line-active"];
    [starButton setBackgroundImage:starButtonImage forState:UIControlStateNormal];
    [starButton setBackgroundImage:starButtonImagePressed forState:UIControlStateHighlighted];
    [starButton addTarget:self action:@selector(starringAction) forControlEvents:UIControlEventTouchUpInside]; // add staring function!
    starButton.frame = CGRectMake(0, 0, 45, 44);
    UIView *starButtonView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 45, 44)];
    starButtonView.bounds = CGRectOffset(starButtonView.bounds, -5, 0);
    [starButtonView addSubview:starButton];
    UIBarButtonItem *starButtonItem = [[UIBarButtonItem alloc] initWithCustomView:starButtonView];
    self.navigationItem.rightBarButtonItem = starButtonItem;
     
    
    if (self.detailEvent) {
        // text fields
        titleText.text = self.detailEvent.eventName;
        titleText.font = [UIFont fontWithName:@"colaborate-bold" size:18];
        NSString *addressString = self.detailEvent.eventAddress;
        addressString = [addressString stringByReplacingOccurrencesOfString:@", Suomi"
                                                                 withString:@""];
        addressString = [addressString stringByReplacingOccurrencesOfString:@", Finland"
                                                                 withString:@""];
        addressText.text = addressString;
        addressText.font = [UIFont fontWithName:@"colaborate-regular" size:15];
        
        // Event Discription
        eventDescriptionField.text = self.detailEvent.description;
        eventDescriptionField.font = [UIFont fontWithName:@"colaborate-regular" size:15];
        eventDescriptionField.numberOfLines = 0;
        [eventDescriptionField sizeToFit];
        
        mainNaviagtionTitle.title = @" ";
       
        /*
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 32)];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        self.navigationItem.titleView = titleLabel;
        */
        
        
        // link setting
        if ([self.detailEvent.link.absoluteString isEqual: @""]) {
            [buttonLinkToEvent setEnabled:NO];
        } else {
            [buttonLinkToEvent setEnabled:YES];
        }
        //UIFont* font3 = [UIFont fontWithName:@"colaborate-bold" size:20];
        //UIFont* font4 = [UIFont fontWithName:@"colaborate-regular" size:20];
        NSLog(@"Timeslider.y + height: %f, %f", eventDescriptionField.frame.origin.y, eventDescriptionField.frame.size.height);
        NSLog(@"NewView.y + height: %f, %f", self.timeInfoView.frame.origin.y, self.timeInfoView.frame.size.height);
        
        CGRect frame = self.timeInfoView.frame;
        frame.origin.y += eventDescriptionField.frame.size.height;
        self.timeInfoView.frame = frame;
        
        CGFloat const inMin = 800.0;
        CGFloat const inMax = 2000.0;
        CGFloat const outMin1 = 16.0;
        CGFloat const outMax1 = 304.0;
        CGFloat const outMin2 = 17.0;
        CGFloat const outMax2 = 305.0;
        
        CGFloat inStart = ([self.detailEvent.beginHour floatValue]*100)+
                           [self.detailEvent.beginMinute floatValue];
        CGFloat inEnd = ([self.detailEvent.endHour floatValue]*100)+
                         [self.detailEvent.endMinute floatValue];
        CGFloat newStart = outMin1 + (outMax1 - outMin1) * (inStart - inMin) / (inMax - inMin);
        CGFloat newWidth = (outMin2 + (outMax2 - outMin2) * (inEnd - inMin) / (inMax - inMin))-newStart;
        
        timeSlider.frame = CGRectMake(  newStart, timeSlider.frame.origin.y,
                                        newWidth, timeSlider.frame.size.height);
        
        
        self.timeLabel1.font = [UIFont fontWithName:@"colaborate-regular" size:15];
        self.timeLabel2.font = [UIFont fontWithName:@"colaborate-regular" size:15];
        self.timeLabel3.font = [UIFont fontWithName:@"colaborate-regular" size:15];
        self.timeLabel4.font = [UIFont fontWithName:@"colaborate-regular" size:15];
        self.timeLabel5.font = [UIFont fontWithName:@"colaborate-regular" size:15];
        self.timeLabel6.font = [UIFont fontWithName:@"colaborate-regular" size:15];
        self.timeLabel7.font = [UIFont fontWithName:@"colaborate-regular" size:15];
        
        // Center Map to Event-Location
        CLLocationCoordinate2D eventLocation = CLLocationCoordinate2DMake([self.detailEvent.latitude doubleValue], [self.detailEvent.longitude doubleValue]);
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(eventLocation, 400, 400);
        [self.mapView setRegion:viewRegion animated:NO];
        
        // Add Event Annotation
        eventSpot *annotation = [[eventSpot alloc] initWithName:self.detailEvent.eventName address:nil coordinate:eventLocation identifier:nil];
        [self.mapView addAnnotation:annotation];
        
    }
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)starringAction
{
    NSLog(@"Element starred");
    //add Element to strred list
    // chnage icon image
}



// set custom annotation image
- (MKAnnotationView *)mapView:(MKMapView *)newMapView viewForAnnotation:(id )newAnnotation {
    MKAnnotationView *a = [ [ MKAnnotationView alloc ] initWithAnnotation:newAnnotation reuseIdentifier:@"currentloc"];
    if ( a == nil )
        a = [ [ MKAnnotationView alloc ] initWithAnnotation:newAnnotation reuseIdentifier: @"currentloc" ];
    a.image = [ UIImage imageNamed:@"map-marker.png" ];
    return a;
}

// share sheet
- (IBAction)sendPost:(id)sender
{
    NSArray *activityItems;
    NSString *shareText = [NSString stringWithFormat:@"Join the Siivouspäivä event: %@ in %@", self.detailEvent.eventName, self.detailEvent.eventAddress];
    UIImage *shareImage = [UIImage imageNamed:@"siivouspaiva-logo.png"];
    activityItems = @[shareText, shareImage];
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    activityController.excludedActivityTypes = @[UIActivityTypePostToWeibo, UIActivityTypePrint, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll];
    [self presentViewController:activityController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.tableView) {
        CGFloat mapViewBaselineY = -(self.mapView.frame.size.height-150)/2+500;
        CGFloat y = mapViewBaselineY + scrollView.contentOffset.y/2;
        self.mapView.frame = CGRectMake(0, y, self.mapView.frame.size.width, self.mapView.frame.size.height);
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return nil;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return ([self tableView:tableView titleForHeaderInSection:section] != nil) ? 20 : 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *header = [[UIView alloc] init];
    
    return header;
}


 

#pragma mark - Seque

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"goToWebView"]) {
        ((WebLinkViewController*)segue.destinationViewController).eventWithLink = self.detailEvent;
    }
}


@end
