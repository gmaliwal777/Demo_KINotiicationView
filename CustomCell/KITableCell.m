//
//  KITableCell.m
//  CustomNotification
//
//  Created by Santosh on 28/10/15.
//  Copyright (c) 2015 Santosh. All rights reserved.
//

#import "KITableCell.h"
#import "AsynImageDownLoad.h"

@implementation KITableCell

- (void)awakeFromNib {
    // Initialization code
    self.backgroundColor = [UIColor colorWithRed:38/255.0 green:183/255.0 blue:237/255.0 alpha:1];
    
    _senderImageView.layer.cornerRadius = _senderImageView.frame.size.width/2;
    _senderImageView.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)onCancel:(id)sender {
    [[NSNotificationCenter defaultCenter]postNotificationName:@"removeView" object:nil];
}

/**
 *  Used to set up user profile view
 *
 *  @param remoteURL : Remote Profile Pic URL , its cached.
 */
-(void)setProfileImageWithRemoteURL:(NSString *)remoteURL{
    if (remoteURL.length>0 &&
        [[[remoteURL componentsSeparatedByString:@"/"] lastObject] componentsSeparatedByString:@"."].count>1) {
        
        NSString *profileImageName = [[remoteURL componentsSeparatedByString:@"/"] lastObject];
        NSArray *arrPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cachePath = [arrPaths objectAtIndex:0];
        NSString *localProfileImagePath = [cachePath stringByAppendingPathComponent:profileImageName];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if(remoteURL && [fileManager fileExistsAtPath:localProfileImagePath]){
            _senderImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfFile:localProfileImagePath]];
            [_activity stopAnimating];
        }else if(remoteURL && [CommonFunctions networkConnectionAvailability]){
            
            AsynImageDownLoad *asynImageDownLoad = [[AsynImageDownLoad alloc] init];
            self.asyncDownload = asynImageDownLoad;
            [asynImageDownLoad downLoadingAsynImage:_senderImageView imagePath:remoteURL backgroundQueue:NULL imageObj:nil];
        }else{
            [_activity stopAnimating];
            self.senderImageView.image = [UIImage imageNamed:@"userPlaceholder"];
        }
        
    }else{
        
        [_activity stopAnimating];
        self.senderImageView.image = [UIImage imageNamed:@"userPlaceholder"];
    }
}

@end
