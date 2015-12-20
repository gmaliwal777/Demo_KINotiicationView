//
//  KITableCell.h
//  CustomNotification
//
//  Created by Santosh on 28/10/15.
//  Copyright (c) 2015 Santosh. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AsynImageDownLoad;

@interface KITableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *senderImageView;
@property (weak, nonatomic) IBOutlet UILabel *senderName;
@property (weak, nonatomic) IBOutlet UILabel *senderMessage;
/**
 *  Referencet ot Activity indicator view
 */
@property (nonatomic,weak)  IBOutlet    UIActivityIndicatorView        *activity;


/**
 *  Reference to AsyncImageDownloader context, which download profile image asyncronously
 */
@property (nonatomic,weak)            AsynImageDownLoad          *asyncDownload;

- (IBAction)onCancel:(id)sender;


/**
 *  Used to set up user profile view
 *
 *  @param remoteURL : Remote Profile Pic URL , its cached.
 */
-(void)setProfileImageWithRemoteURL:(NSString *)remoteURL;

@end
