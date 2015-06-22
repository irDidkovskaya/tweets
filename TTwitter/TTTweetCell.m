//
//  TTTweetCell.m
//  TTwitter
//
//  Created by Iryna Didkovska on 6/20/15.
//  Copyright (c) 2015 Iryna Didkovska. All rights reserved.
//

#import "TTTweetCell.h"
@interface TTTweetCell()
@property (nonatomic, strong) IBOutlet UILabel *titleLable;
@property (nonatomic, strong) IBOutlet UILabel *descLablel;
@end

@implementation TTTweetCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)setTitle:(NSString *)title
{
    _title = title;
    self.titleLable.text = _title;
}


- (void)setDesc:(NSString *)desc
{
    _desc = desc;
    self.descLablel.text = _desc;
}


@end
