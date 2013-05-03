//
//  Document.h
//  jText
//
//  Created by Petr Jodas on 27.04.13.
//  Copyright (c) 2013 Petr Jodas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class NoodleLineNumberView;

@interface Document : NSDocument <NSTextViewDelegate>
{
  NSAttributedString * zNSAttributedStringObj;
  NoodleLineNumberView	*lineNumberView;
}
@property (unsafe_unretained) IBOutlet NSTextView *txtEdit;
@property (weak) IBOutlet NSScrollView *scrollView;


@end
