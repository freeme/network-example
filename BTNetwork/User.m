// User.m
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

#import "User.h"


@implementation User 


@synthesize userID = _userID;
@synthesize username = _username;
@synthesize avatarImageURL = _avatarImageURL;
@synthesize avatarImage = _avatarImage;
@synthesize tempData = _tempData;
@synthesize coverImageSize = _coverImageSize;

- (void)dealloc {
  [_username release];
  [_avatarImageURL release];
  [_coverImageURL release];
  [_avatarImage release];
  [_tempData release];
  [super dealloc];
}

- (id)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _userID = [[attributes valueForKeyPath:@"id"] integerValue];
    _username = [[attributes valueForKeyPath:@"username"] copy];
    _avatarImageURL = [[attributes valueForKeyPath:@"avatar_image.url"] copy];
    _coverImageURL = [[attributes valueForKeyPath:@"cover_image.url"] copy];
  NSInteger coverHeight = [[attributes valueForKeyPath:@"cover_image.height"] integerValue];
  NSInteger coverWidth = [[attributes valueForKeyPath:@"cover_image.width"] integerValue];
    _coverImageSize = CGSizeMake(coverWidth, coverHeight);
    return self;
}



@end
