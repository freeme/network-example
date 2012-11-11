// TweetTableViewCell.m
//
// Copyright (c) 2012 Mattt Thompson (http://mattt.me/)
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "PostTableViewCell.h"

#import "Post.h"
#import "User.h"


@implementation PostTableViewCell 


@synthesize post = _post;

- (void)dealloc {
  [_post release];
  [_netImageView release];
  [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) {
        return nil;
    }
    
    self.textLabel.adjustsFontSizeToFitWidth = YES;
    self.textLabel.textColor = [UIColor darkGrayColor];
    self.detailTextLabel.font = [UIFont systemFontOfSize:12.0f];
    self.detailTextLabel.numberOfLines = 0;
    self.selectionStyle = UITableViewCellSelectionStyleGray;
    _netImageView = [[TTNetImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
  [self.contentView addSubview:_netImageView];
    return self;
}

- (void)setPost:(Post *)post {
  if (_post != post) {
    [_post release];
    _post = [post retain];
    
    self.textLabel.text = _post.user.username;
    _netImageView.defaultImage = [UIImage imageNamed:@"profile-image-placeholder.png"];
    _netImageView.urlPath = _post.user.avatarImageURL;
  }
}

- (void) layoutSubviews {
  [super layoutSubviews];
  CGRect labelFrame = self.textLabel.frame;
  labelFrame.origin.x = _netImageView.frame.size.width + 10;
  labelFrame.size.width -= labelFrame.origin.x;
  self.textLabel.frame = labelFrame;
}
@end
