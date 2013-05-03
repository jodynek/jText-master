//
//  Document.m
//  Test
//
//  Created by Jodynek on 25.04.13.
//  Copyright (c) 2013 Jodynek. All rights reserved.
//

// novy dokument - programove
//  NSError *zError = nil;
//  [[NSDocumentController sharedDocumentController] openUntitledDocumentAndDisplay:YES error:&zError];
//  NSLog(@"Error: %@",[zError localizedDescription]);


#import "Document.h"
#import "NoodleLineNumberView.h"
#import "NoodleLineNumberMarker.h"
#import "MarkerLineNumberView.h"

@implementation Document

- (void)awakeFromNib
{
  lineNumberView = [[MarkerLineNumberView alloc] initWithScrollView:_scrollView];
  [_scrollView setVerticalRulerView:lineNumberView];
  [_scrollView setHasHorizontalRuler:NO];
  [_scrollView setHasVerticalRuler:YES];
  [_scrollView setRulersVisible:YES];  
}

- (id)init
{
  self = [super init];
  if (self)
  {
    zNSAttributedStringObj=[[NSAttributedString alloc]initWithString:@""];
  }
  return self;
}

- (NSString *)windowNibName
{
  return @"Document";
}

- (int)getLinesCount
{
  NSString *s = [_txtEdit string];
  NSRange range = NSMakeRange(0,0);
	unsigned start, end;
	unsigned contentsEnd = 0;
  unsigned iLines = 0;
	while (contentsEnd < [s length])
	{
		[s getLineStart:&start end:&end contentsEnd:&contentsEnd forRange:range];
		range.location = end;
		range.length = 0;
    iLines++;
	}
  
  return iLines;
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
  [super windowControllerDidLoadNib:aController];
  [_txtEdit setTextColor:[NSColor whiteColor]];
  [_txtEdit setString:[zNSAttributedStringObj string]];
  // default font
  NSFont *font =  [NSFont userFixedPitchFontOfSize:[NSFont smallSystemFontSize]];
  //NSFont *font = [NSFont fontWithName:@"Andale Mono" size:14];
  [_txtEdit setFont:font];
  [[_txtEdit textStorage] setFont:font];
}

+ (BOOL)autosavesInPlace
{
  return NO;
}

- (void) textDidChange: (NSNotification *) notification
{
  zNSAttributedStringObj = [_txtEdit textStorage];
  NSLog(@"Lines count: %d", [self getLinesCount]);
  NSInteger insertionPoint = [[[_txtEdit selectedRanges] objectAtIndex:0] rangeValue].location;
  NSLog(@"Current position: %d", insertionPoint);
}

- (BOOL)readFromData:(NSData *)pData
              ofType:(NSString *)pTypeName
               error:(NSError **)pOutError {
  
  if ([pTypeName compare:@"TextFile"] != NSOrderedSame) {
    NSLog(@"** ERROR ** readFromData pTypeName=%@",pTypeName);
    *pOutError = [NSError errorWithDomain:NSOSStatusErrorDomain
                                     code:unimpErr
                                 userInfo:NULL];
    return NO;
  } // end if
  
  NSDictionary *zDict = [NSDictionary dictionaryWithObjectsAndKeys:
                         NSPlainTextDocumentType,
                         NSDocumentTypeDocumentAttribute,
                         nil];
  NSDictionary *zDictDocAttributes;
  NSError *zError = nil;
  zNSAttributedStringObj = [[NSAttributedString alloc]initWithData:pData
                                                           options:zDict
                                                documentAttributes:&zDictDocAttributes
                                                             error:&zError];
  if ( zError != NULL ) {
    NSLog(@"Error readFromData: %@",[zError localizedDescription]);
    return NO;
  } // end if
  //NSLog(@"%@",[zNSAttributedStringObj string]);
  return YES;
  
} // end readFromData

- (NSData *)dataOfType:(NSString *)pTypeName error:(NSError **)pOutError
{
  NSDictionary * zDict;
  
  if ([pTypeName compare:@"TextFile"] == NSOrderedSame ) {
    zDict = [NSDictionary dictionaryWithObjectsAndKeys:
             NSPlainTextDocumentType,
             NSDocumentTypeDocumentAttribute,nil];
  } else {
    NSLog(@"ERROR: dataOfType pTypeName=%@",pTypeName);
    *pOutError = [NSError errorWithDomain:NSOSStatusErrorDomain
                                     code:unimpErr
                                 userInfo:NULL];
    return NULL;
  } // end if
  NSString * zString = [[_txtEdit textStorage] string];
  NSData * zData = [zString dataUsingEncoding:NSUTF8StringEncoding];
  return zData;
} // end dataOfType

@end
