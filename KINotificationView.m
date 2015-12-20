//
//  KINotificationView.m
//  CustomNotification
//
//  Created by Santosh on 28/10/15.
//  Copyright (c) 2015 Santosh. All rights reserved.
//

#import "KINotificationView.h"
#import "KITableCell.h"
#import "NotificationDetail.h"

#define CHAT_PUSH_NOTIFICATION_ROW_HEIGHT_MULTIPLIER       (70.f/320.f)

static NSString *notificationName;
static NSString *notificationMessage;
static NSString *notificationImageUrl;
static NSMutableArray *notificationsArray;
static KINotificationView *notificationView = nil;
static id dataNotification;

@interface KINotificationView ()<UITableViewDataSource,UITableViewDelegate>
{
    NSTimer *notificationTimer;
    BOOL isNewContentAvailabel;
}

@property (strong, nonatomic) IBOutlet UITableView *notificationsTableView;

- (void)addTheNotification;
- (void)showTheNotification;
- (void)removeViewFromScreen;

@end

@implementation KINotificationView

#pragma mark - 
#pragma mark - Compose The Notification
+ (KINotificationView *)showPopUpOnView:(NSString *)senderName message:(NSString *)senderMessage imageUrl:(NSString *)senderImageUrl andDelegate:(id)delegate data:(id)data;
{
    dataNotification = data;
    
    // storing sender name
    notificationName = senderName;
    // storing sender message
    notificationMessage = senderMessage;
    // storing sender image url
    notificationImageUrl = senderImageUrl;
    
    // Checking for notification view instance
    // If not initialized
    if (!notificationView)
    {
        // Initializing the instance and showing the pop up;
        notificationView = [[self alloc]initWithFrame:CGRectMake(0, 20, APPDELEGATE.window.frame.size.width, SCREEN_WIDTH*CHAT_PUSH_NOTIFICATION_ROW_HEIGHT_MULTIPLIER)];
        notificationView.transform = CGAffineTransformMakeTranslation(0, -notificationView.frame.size.height);
        notificationView.delegate=delegate;
        
        [APPDELEGATE.window addSubview:notificationView];
        [APPDELEGATE.window bringSubviewToFront:notificationView];
        
//        notificationView.layer.zPosition = MAXFLOAT;
        
        [UIView transitionWithView:notificationView duration:.2 options:UIViewAnimationOptionCurveLinear animations:^{
            notificationView.transform = CGAffineTransformIdentity;
        } completion:nil];
    }
    else // Else refreshing the old content with new content
    {
        [notificationView showTheNotification];
    }
    return notificationView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
   self = [super initWithFrame:frame];
    if (self)
    {
        
        isNewContentAvailabel = false;
        
        notificationsArray = [[NSMutableArray alloc]init];
        
        [self addTheNotification];
        [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
        [self addSubview:self.view];
        [self.notificationsTableView reloadData];
        notificationTimer = [NSTimer scheduledTimerWithTimeInterval:8 target:self selector:@selector(invalidateTheNotification) userInfo:nil repeats:NO];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(removeViewFromScreen) name:@"removeView" object:nil];
    }
    return self;
}

-(void)drawRect:(CGRect)rect{
    [self.view setFrame:self.bounds];

}

#pragma mark - 
#pragma mark Invalidate View & Fire Delegate
- (void)invalidateTheNotification
{
    if (notificationTimer)
    {
        [notificationTimer invalidate];
        
        [UIView transitionWithView:self duration:.2 options:UIViewAnimationOptionCurveLinear animations:^{
            self.transform = CGAffineTransformMakeTranslation(0, -self.frame.size.height);
        } completion:^(BOOL finished) {
            if (!isNewContentAvailabel)
            {
                [notificationsArray removeAllObjects];
                [notificationView removeFromSuperview],notificationView = nil;
                if (self.delegate && [self.delegate respondsToSelector:@selector(notificationViewDidDismiss)])
                {
                    [self.delegate notificationViewDidDismiss];
                }
            }
            else
            {
                isNewContentAvailabel = false;
                [UIView transitionWithView:notificationView duration:.2 options:UIViewAnimationOptionCurveLinear animations:^{
                    notificationView.transform = CGAffineTransformIdentity;
                } completion:nil];
            }
        }];
    }
}

#pragma mark -
#pragma mark - Add Notification
- (void)addTheNotification
{
    NotificationDetail *notificationDetails = [[NotificationDetail alloc]init];
    notificationDetails.notificationTitle = notificationName;
    notificationDetails.notificationMessage = notificationMessage;
    notificationDetails.notificationImageUrl = notificationImageUrl;
    [notificationsArray addObject:notificationDetails];
}

#pragma mark -
#pragma mark - Replace Notification
- (void)showTheNotification
{
    if (notificationTimer.isValid)
    {
        
    }
    else
    {
        isNewContentAvailabel = true;
    }
    [notificationTimer invalidate];
 
    NotificationDetail *notificationDetails = [[NotificationDetail alloc]init];
    notificationDetails.notificationTitle = notificationName;
    notificationDetails.notificationMessage = notificationMessage;
    notificationDetails.notificationImageUrl = notificationImageUrl;
    [notificationsArray replaceObjectAtIndex:0 withObject:notificationDetails];
    
    [self.notificationsTableView beginUpdates];
    [self.notificationsTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
    [self.notificationsTableView endUpdates];
    
    notificationTimer = [NSTimer scheduledTimerWithTimeInterval:8 target:self selector:@selector(invalidateTheNotification) userInfo:nil repeats:NO];
}

- (void)removeViewFromScreen
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"removeView" object:nil];
    [self invalidateTheNotification];
}

#pragma mark -
#pragma mark - UITableView DataSources & Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return notificationsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KITableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"notificationCell"];
    if (!cell)
    {
        [tableView registerNib:[UINib nibWithNibName:NSStringFromClass([KITableCell class]) bundle:nil] forCellReuseIdentifier:@"notificationCell"];
        cell = [tableView dequeueReusableCellWithIdentifier:@"notificationCell"];
        
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setProfileImageWithRemoteURL:notificationImageUrl];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"data == %@",dataNotification);
    NSDictionary* trueDeepCopyDictionary = [NSKeyedUnarchiver unarchiveObjectWithData:
                                  [NSKeyedArchiver archivedDataWithRootObject: dataNotification]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BokuPushTapNotification object:nil userInfo:trueDeepCopyDictionary];
    [self invalidateTheNotification];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(KITableCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NotificationDetail *notificationDetail = (NotificationDetail *)notificationsArray[indexPath.row];
    cell.senderMessage.text = notificationDetail.notificationMessage;
    cell.senderName.text = notificationDetail.notificationTitle;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CHAT_PUSH_NOTIFICATION_ROW_HEIGHT_MULTIPLIER*SCREEN_WIDTH;
}

@end
