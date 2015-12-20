//
//  KINotificationView.h
//  CustomNotification
//
//  Created by Santosh on 28/10/15.
//  Copyright (c) 2015 Santosh. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol KINotificationViewDelegate;

@interface KINotificationView : UIView{
    
}

+ (KINotificationView *)showPopUpOnView:(NSString *)senderName message:(NSString *)senderMessage imageUrl:(NSString *)senderImageUrl andDelegate:(id)delegate data:(id)data;

@property(nonatomic,weak)id<KINotificationViewDelegate>delegate;

@property (nonatomic , strong ) IBOutlet UIView  *view;
@property (nonatomic, strong)   IBOutlet    UITableView *tableViewChatPush;


@end


@protocol KINotificationViewDelegate <NSObject>

- (void)notificationViewDidDismiss;




@end