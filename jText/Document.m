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
//
//	NSFontPanel *fontPanel = [NSFontPanel sharedFontPanel];
// [fontPanel orderFront:sender];


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
  NSFontManager *fontManager = [NSFontManager sharedFontManager];
  [fontManager setTarget:self];
  NSColorPanel *cp = [NSColorPanel sharedColorPanel];
  [cp setTarget:self];
  [cp setAction:@selector(changeColor:)];
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


-(NSRange)textView:(NSTextView *)textView willChangeSelectionFromCharacterRange:(NSRange)oldSelectedCharRange toCharacterRange:(NSRange)newSelectedCharRange
{
  // get current row
  NSRange selectionRange = newSelectedCharRange;
  unsigned currentRow = 0, length =  (unsigned)selectionRange.location;
  NSString *s = [_txtEdit string];
  NSRange range = NSMakeRange(0,0);
	unsigned end;
	unsigned contentsEnd = 0;
	while (contentsEnd < length)
	{
		[s getLineStart:Nil end:&end contentsEnd:&contentsEnd forRange:range];
		range.location = end;
		range.length = 0;
    currentRow++;
	}
  if (currentRow == 0)
    currentRow = 1;
  
  // get current col
  unsigned int selection = (unsigned)selectionRange.location;
  end = (unsigned)[[_txtEdit string]
                                lineRangeForRange:selectionRange].location-1;
  unsigned currentCol = (selection-end);
  //NSLog(@"Cursor pos: row %d, col %d", currentRow, currentCol);
  [_lblEditPos setStringValue:[NSString stringWithFormat:@"Position: %d, %d   Total lines: %d", currentCol, currentRow, [self getLinesCount]]];
  return newSelectedCharRange;
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
  [super windowControllerDidLoadNib:aController];
  [_txtEdit setTextColor:[NSColor whiteColor]];
  [_txtEdit setString:[zNSAttributedStringObj string]];
  
  //get the saved font
  NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
  NSMutableDictionary *fontDict = [NSMutableDictionary dictionaryWithDictionary:[userDefault objectForKey:@"userFonts"]];
  NSData *oldFontAsData = [fontDict objectForKey:@"smallFontForList"];
  NSFont *oldFont = [NSKeyedUnarchiver unarchiveObjectWithData:oldFontAsData];
  if (!oldFont)
    oldFont =  [NSFont userFixedPitchFontOfSize:[NSFont smallSystemFontSize]];
  [_txtEdit setFont:oldFont];
  [[_txtEdit textStorage] setFont:oldFont];
  
  // get font color
  NSMutableDictionary *colorDict = [NSMutableDictionary dictionaryWithDictionary:[userDefault objectForKey:@"userColor"]];
  NSData *oldColorData = [colorDict objectForKey:@"colorForList"];
  NSColor *oldColor = [NSKeyedUnarchiver unarchiveObjectWithData:oldColorData];
  if (!oldColor)
    oldColor = [NSColor whiteColor];
  [_txtEdit setTextColor:oldColor];
}

+ (BOOL)autosavesInPlace
{
  return NO;
}

- (void) textDidChange: (NSNotification *) notification
{
  zNSAttributedStringObj = [_txtEdit textStorage];
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

- (IBAction)selectFont:(id)sender
{
	NSFontPanel *fontPanel = [NSFontPanel sharedFontPanel];
  [fontPanel orderFront:sender];
}

- (IBAction)selectColor:(id)sender
{
  NSColorPanel *colorPanel = [NSColorPanel sharedColorPanel];
  [colorPanel orderFront:sender];
}

- (IBAction) printShowingPrintPanel:(id)sender
{
  NSTextView *textView = [[NSTextView alloc] initWithFrame:NSMakeRect(0, 0, 468, 648)];
  [textView setString:[_txtEdit string]];
  [textView print:sender];
}

- (void) changeFont:(id)sender
{
  NSFont *font = [[NSFontManager sharedFontManager] selectedFont];
  [_txtEdit setFont:font];
  [[_txtEdit textStorage] setFont:font];
  // save config
  NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
  NSMutableDictionary *fontDict = [NSMutableDictionary dictionaryWithDictionary:[userDefault objectForKey:@"userFonts"]];
  NSData *newFontAsData = [NSKeyedArchiver archivedDataWithRootObject:font];
  [fontDict setObject:newFontAsData forKey:@"smallFontForList"];
  [userDefault setObject:fontDict forKey:@"userFonts"];
  [userDefault synchronize];
}

- (void) changeColor:(id)sender
{
  NSColor *color = [[NSColorPanel sharedColorPanel] color];
  [_txtEdit setTextColor:color];
  // save config
  NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
  NSMutableDictionary *colorDict = [NSMutableDictionary dictionaryWithDictionary:[userDefault objectForKey:@"userColor"]];
  NSData *newColorAsData = [NSKeyedArchiver archivedDataWithRootObject:color];
  [colorDict setObject:newColorAsData forKey:@"colorForList"];
  [userDefault setObject:colorDict forKey:@"userColor"];
  [userDefault synchronize];
}
@end
