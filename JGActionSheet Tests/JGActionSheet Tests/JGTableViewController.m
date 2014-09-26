//
//  JGTableViewController.m
//  JGActionSheet Tests
//
//  Created by Jonas Gessner on 29.07.14.
//  Copyright (c) 2014 Jonas Gessner. All rights reserved.
//

#import "JGTableViewController.h"

#import "JGActionSheet.h"

@interface JGTableViewController () <JGActionSheetDelegate> {
    JGActionSheet *_currentAnchoredActionSheet;
    UIView *_anchorView;
    BOOL _anchorLeft;
    JGActionSheet *_simple;
    JGActionSheet *_bookmarks;
    
    JGActionSheet   *_activeSheet;
    UITextField     *_activeTextField;
    CGRect          saveRect;
    
    BOOL            registerDone;
}

@end

@implementation JGTableViewController

#ifndef kCFCoreFoundationVersionNumber_iOS_7_0
#define kCFCoreFoundationVersionNumber_iOS_7_0 838.00
#endif

#define iOS7 (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_7_0)
#define iPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#pragma mark - JGActionSheetDelegate

- (void)actionSheetWillPresent:(JGActionSheet *)actionSheet {
    NSLog(@"Action sheet %p will present", actionSheet);
}

- (void)actionSheetDidPresent:(JGActionSheet *)actionSheet {
    NSLog(@"Action sheet %p did present", actionSheet);
}

- (void)actionSheetWillDismiss:(JGActionSheet *)actionSheet {
    NSLog(@"Action sheet %p will dismiss", actionSheet);
    _currentAnchoredActionSheet = nil;
}

- (void)actionSheetDidDismiss:(JGActionSheet *)actionSheet {
    NSLog(@"Action sheet %p did dismiss", actionSheet);
}

#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"JGActionSheet";
    
    if ([self.tableView respondsToSelector:@selector(registerClass:forCellReuseIdentifier:)]) {
        [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    }
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Action" style:UIBarButtonItemStyleBordered target:self action:@selector(showFromBarButtonItem:withEvent:)];
}

- (void)showFromBarButtonItem:(UIBarButtonItem *)barButtonItem withEvent:(UIEvent *)event {
    UIView *view = [event.allTouches.anyObject view];
    
    JGActionSheetSection *section = [JGActionSheetSection sectionWithTitle:@"A Nice Title" message:@"Some message" buttonTitles:@[@"Destructive Button", @"Normal Button", @"Some Button"] buttonStyle:JGActionSheetButtonStyleDefault];
    
    [section setButtonStyle:JGActionSheetButtonStyleRed forButtonAtIndex:0];
    
    NSArray *sections = (iPad ? @[section] : @[section, [JGActionSheetSection sectionWithTitle:nil message:nil buttonTitles:@[@"Cancel"] buttonStyle:JGActionSheetButtonStyleCancel]]);
    
    JGActionSheet *sheet = [[JGActionSheet alloc] initWithSections:sections];
    
    sheet.delegate = self;
    
    [sheet setButtonPressedBlock:^(JGActionSheet *sheet, NSIndexPath *indexPath) {
        [sheet dismissAnimated:YES];
    }];
    
    if (iPad) {
        [sheet setOutsidePressBlock:^(JGActionSheet *sheet) {
            [sheet dismissAnimated:YES];
        }];
        
        CGPoint point = (CGPoint){CGRectGetMidX(view.bounds), CGRectGetMaxY(view.bounds)};
        
        point = [self.navigationController.view convertPoint:point fromView:view];
        
        _currentAnchoredActionSheet = sheet;
        _anchorView = view;
        _anchorLeft = NO;
        
        [sheet showFromPoint:point inView:self.navigationController.view arrowDirection:JGActionSheetArrowDirectionTop animated:YES];
    }
    else {
        [sheet showInView:self.navigationController.view animated:YES];
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (!iOS7) {
        //Use this on iOS < 7 to prevent the UINavigationBar from overlapping your action sheet!
        [self.navigationController.view.superview bringSubviewToFront:self.navigationController.view];
    }
    
    if (_currentAnchoredActionSheet) {
        UIView *view = _anchorView;
        
        CGPoint point = (_anchorLeft ? (CGPoint){-5.0f, CGRectGetMidY(view.bounds)} : (CGPoint){CGRectGetMidX(view.bounds), CGRectGetMaxY(view.bounds)});
        
        point = [self.navigationController.view convertPoint:point fromView:view];
        
        [_currentAnchoredActionSheet moveToPoint:point arrowDirection:(_anchorLeft ? JGActionSheetArrowDirectionRight : JGActionSheetArrowDirectionTop) animated:NO];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    if (!cell.accessoryView) {
        UIButton *accessory = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [accessory addTarget:self action:@selector(accessoryTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.accessoryView = accessory;
    }
    
    cell.accessoryView.tag = indexPath.row;
    
    if (indexPath.row == 0) {
        cell.textLabel.text = @"Simple Action Sheet";
    }
    else if (indexPath.row == 1) {
        cell.textLabel.text = @"Multiple Sections";
    }
    else if (indexPath.row == 2)  {
        cell.textLabel.text = @"Multiple Sections & Content View";
    }
    else if (indexPath.row == 3)  {
        cell.textLabel.text = @"Bookmarks";
    }
    else if (indexPath.row == 4)  {
        cell.textLabel.text = @"Bookmarks Big";
    }
	else {
		cell.textLabel.text = @"Edit Content";
	}
	
    return cell;
}

- (void)accessoryTapped:(UIButton *)button {
    if (button.tag == 0) {
        [self showSimple:button];
    }
    else if (button.tag == 1) {
        [self multipleSections:button];
    }
	else if (button.tag == 2) {
		[self multipleAndContentView:button];
	}
    else if (button.tag == 3) {
        [self bookmarksView:button big: NO];
    }
    else if (button.tag == 4) {
        [self bookmarksView:button big: NO];
    }
	else {
		[self multipleAndContentViewEdit:button ];
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        [self showSimple:nil];
    }
    else if (indexPath.row == 1) {
        [self multipleSections:nil];
    }
	else if (indexPath.row == 2) {
		[self multipleAndContentView:nil];
	}
    else if (indexPath.row == 3) {
        [self bookmarksView:nil big: NO];
    }
    else if (indexPath.row == 4) {
        [self bookmarksView:nil big: NO];
    }
    else {
        [self multipleAndContentViewEdit:nil ];
    }
}

- (void)multipleAndContentViewEdit:(UIView *)anchor {
    
//    UISlider *c = [[UISlider alloc] init];
//    c.frame = (CGRect){CGPointZero, {290.0f, c.frame.size.height}};
    UITextField *textField = [[UITextField alloc] init];
    textField.frame = (CGRect){CGPointZero, {290.0f, 45}};
    
    textField.delegate = self;
    textField.borderStyle = UITextBorderStyleLine;
    textField.clearButtonMode = UITextFieldViewModeUnlessEditing;
    textField.text = @"Some text";
    textField.returnKeyType = UIReturnKeyDone;
    
    _activeTextField = textField;
    
    JGActionSheetSection *s3 = [JGActionSheetSection sectionWithTitle:nil message:nil contentView:textField];
    
    JGActionSheetSection *s4 = [JGActionSheetSection sectionWithTitle:nil message:nil buttonTitles:@[@"Add Bookmark", @"Cancel"] buttonStyle:JGActionSheetButtonStyleDefault];
    
    JGActionSheet *sheet = [JGActionSheet actionSheetWithSections:@[s4, s3]];
    
    sheet.delegate = self;
    
    sheet.insets = UIEdgeInsetsMake(20.0f, 0.0f, 0.0f, 0.0f);
    
    if (anchor && iPad) {
        _anchorView = anchor;
        _anchorLeft = YES;
        _currentAnchoredActionSheet = sheet;
        
        CGPoint p = (CGPoint){-5.0f, CGRectGetMidY(anchor.bounds)};
        
        p = [self.navigationController.view convertPoint:p fromView:anchor];
        
        [sheet showFromPoint:p inView:self.navigationController.view arrowDirection:JGActionSheetArrowDirectionRight animated:YES];
    }
    else {
        [sheet showInView:self.navigationController.view animated:YES];
    }
    
    //if (iPad)
    {
        [sheet setOutsidePressBlock:^(JGActionSheet *sheet) {
            [sheet dismissAnimated:NO];
        }];
    }
    
    [sheet setButtonPressedBlock:^(JGActionSheet *sheet, NSIndexPath *indexPath) {
        [sheet dismissAnimated:NO];
    }];
    
    _activeSheet = sheet;
    
    [self registerForKeyboardNotifications];
}

// ------------------------------------------------------------------------------------
// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications
{
    if (registerDone) return;
    registerDone = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGRect kbRect = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    
    NSLog(@"keyboardWasShown kbRect=%@", NSStringFromCGRect(kbRect));
   
    // convertRect:fromWindow:

    CGRect windowRect = [self.view.window convertRect:kbRect fromWindow:nil];
    CGRect kbRect2    = [self.view        convertRect:windowRect fromView:nil];

    NSLog(@"keyboardWasShown kbRect2=%@", NSStringFromCGRect(kbRect2));

    //NSLog(@"keyboardWasShown _activeSheet.frame=%@", NSStringFromCGRect(_activeSheet.frame));
    //NSLog(@"keyboardWasShown _activeSheet.bounds=%@", NSStringFromCGRect(_activeSheet.bounds));
    //NSLog(@"keyboardWasShown _activeTextField.frame=%@", NSStringFromCGRect(_activeTextField.frame));
    //NSLog(@"keyboardWasShown _activeTextField.bounds=%@", NSStringFromCGRect(_activeTextField.bounds));
    
    //NSLog(@"keyboardWasShown _activeSheet.scrollView=%@", _activeSheet.scrollView);
    //NSLog(@"keyboardWasShown _activeSheet.scrollView.frame=%@", NSStringFromCGRect(_activeSheet.scrollView.frame));
    NSLog(@"keyboardWasShown _activeSheet.scrollView.superview.frame=%@", NSStringFromCGRect(_activeSheet.scrollView.superview.frame));
 
    CGSize kbSize = kbRect2.size;

    CGRect  theRect = _activeSheet.scrollView.superview.frame;
    saveRect = theRect;
    theRect.origin.y -= kbSize.height;
    _activeSheet.scrollView.superview.frame = theRect;

    NSLog(@"keyboardWasShown theRect=%@", NSStringFromCGRect(theRect));

#if 0
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    _activeSheet.scrollView.contentInset = contentInsets;
    _activeSheet.scrollView.scrollIndicatorInsets = contentInsets;
    {
        CGRect bkgndRect = _activeTextField.superview.frame;
        bkgndRect.size.height += kbSize.height;
        [_activeTextField.superview setFrame:bkgndRect];
        [_activeSheet.scrollView setContentOffset:CGPointMake(0.0, _activeTextField.frame.origin.y-kbSize.height) animated:YES];
    
    }
#endif
#if 0
    {
        // If active text field is hidden by keyboard, scroll it so it's visible
        // Your app might not need or want this behavior.
        CGRect aRect = self.view.frame;

        NSLog(@"keyboardWasShown aRect=%@ _activeTextField.frame.origin=%@", NSStringFromCGRect(aRect), NSStringFromCGPoint(_activeTextField.frame.origin));

        aRect.size.height -= kbSize.height;
        //if (!CGRectContainsPoint(aRect, _activeTextField.frame.origin) )
        {
            [_activeSheet.scrollView scrollRectToVisible:_activeTextField.frame animated:YES];
        }
    }
#endif
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    NSLog(@"keyboardWillBeHidden theRect=%@", NSStringFromCGRect(saveRect));
    _activeSheet.scrollView.superview.frame = saveRect;
#if 0
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    _activeSheet.scrollView.contentInset = contentInsets;
    _activeSheet.scrollView.scrollIndicatorInsets = contentInsets;
#endif
}

// ------------------------------------------------------------------------------------
#pragma mark -
#pragma mark <UITextFieldDelegate> Methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    //NSLog(@"EP_ConfirmBasicTextCtl textFieldShouldBeginEditing textField=%p", textField);
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    //NSLog(@"EP_ConfirmBasicTextCtl textFieldDidBeginEditing textField=%p", textField);
    
}

// ------------------------------------------------------------------------------------
- (void)textFieldDidEndEditing:(UITextField *)textField
{
   // NSLog(@"EP_ConfirmBasicTextCtl textFieldDidEndEditing textField=%p", textField);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSLog(@"EP_ConfirmBasicTextCtl textFieldShouldReturn textField=%p ", textField);
    [textField resignFirstResponder];
    
    [_activeSheet dismissAnimated:NO];
    
    return YES;
}

// ------------------------------------------------------------------------------------

- (void) bookmarksView: (UIView *)anchor big: (BOOL) big
{
	//This is am example of an action sheet that is reused!
	//if (!_bookmarks)
	{
//		_bookmarks = [JGActionSheet actionSheetWithSections:@[[JGActionSheetSection sectionWithTitle:@"Title" message:@"Message" buttonTitles:@[@"Yes", @"No"] buttonStyle:JGActionSheetButtonStyleDefault], [JGActionSheetSection sectionWithTitle:nil message:nil buttonTitles:@[@"Cancel"] buttonStyle:JGActionSheetButtonStyleCancel]]];

		NSMutableArray *marks = [NSMutableArray arrayWithCapacity: 100];
		int count = big? 55: 5;
		NSArray *fmts_big = @[@"Button Name Button %d",
							  @"Ant Hills Button Name Button %d",
							  @"Beach Bum Button %d",
							  @"A Very Long ButtonVery Long ButtonVery Long Button Name Button %d"];
		NSArray *fmts_reg = @[@"Button %d",
							  @"Button Button %d",
							  @"Button Button Button %d",
							  @"Button Button Button Button %d"];
		
		NSArray *fmts = big? fmts_big: fmts_reg;
		
		for (int index = 0; index < count; index++)
		{
			NSString *fmt = fmts[ index % [fmts count]];
			[marks addObject: [NSString stringWithFormat:fmt, index]];
		}

		_bookmarks = [JGActionSheet actionSheetWithSections: @[
	[JGActionSheetSection sectionWithTitle:nil message:nil
							  buttonTitles:@[@"Add Bookmark", @"Show Bookmarks"]
							   buttonStyle:JGActionSheetButtonStyleBlue],
	[JGActionSheetSection sectionWithTitle:nil message:nil
							  buttonTitles: marks
							   buttonStyle:JGActionSheetButtonStyleDefault]
	]];

		_bookmarks.delegate = self;
		
		_bookmarks.insets = UIEdgeInsetsMake(20.0f, 0.0f, 0.0f, 0.0f);
		
		if (iPad) {
			[_bookmarks setOutsidePressBlock:^(JGActionSheet *sheet) {
				[sheet dismissAnimated:YES];
			}];
		}
		
		[_bookmarks setButtonPressedBlock:^(JGActionSheet *sheet, NSIndexPath *indexPath) {
			[sheet dismissAnimated:YES];
		}];
	}
	
	if (anchor && iPad) {
		_anchorView = anchor;
		_anchorLeft = YES;
		_currentAnchoredActionSheet = _bookmarks;
		
		CGPoint p = (CGPoint){-5.0f, CGRectGetMidY(anchor.bounds)};
		
        UIView *theView = self.navigationController.view;
		p = [theView convertPoint:p fromView:anchor];
		
		[_bookmarks showFromPoint:p inView:theView arrowDirection:JGActionSheetArrowDirectionRight animated:YES];
	}
	else {
		[_bookmarks showInView:self.navigationController.view animated:YES];
	}
}

- (void)showSimple:(UIView *)anchor {
    //This is am example of an action sheet that is reused!
    if (!_simple) {
        _simple = [JGActionSheet actionSheetWithSections:@[[JGActionSheetSection sectionWithTitle:@"Title" message:@"Message" buttonTitles:@[@"Yes", @"No"] buttonStyle:JGActionSheetButtonStyleDefault], [JGActionSheetSection sectionWithTitle:nil message:nil buttonTitles:@[@"Cancel"] buttonStyle:JGActionSheetButtonStyleCancel]]];
        
        _simple.delegate = self;
        
        _simple.insets = UIEdgeInsetsMake(20.0f, 0.0f, 0.0f, 0.0f);
        
        if (iPad) {
            [_simple setOutsidePressBlock:^(JGActionSheet *sheet) {
                [sheet dismissAnimated:YES];
            }];
        }
        
        [_simple setButtonPressedBlock:^(JGActionSheet *sheet, NSIndexPath *indexPath) {
            [sheet dismissAnimated:YES];
        }];
    }
    
    if (anchor && iPad) {
        _anchorView = anchor;
        _anchorLeft = YES;
        _currentAnchoredActionSheet = _simple;
        
        CGPoint p = (CGPoint){-5.0f, CGRectGetMidY(anchor.bounds)};
        
        UIView *theView = self.navigationController.view;
        
        p = [theView convertPoint:p fromView:anchor];
        
        //[_simple showFromPoint:p inView:[[UIApplication sharedApplication] keyWindow] arrowDirection:JGActionSheetArrowDirectionRight animated:YES];
        [_simple showFromPoint:p inView:theView arrowDirection:JGActionSheetArrowDirectionRight animated:YES];
    }
    else {
        [_simple showInView:self.navigationController.view animated:YES];
    }
}

- (void)multipleSections:(UIView *)anchor {
    JGActionSheetSection *s1 = [JGActionSheetSection sectionWithTitle:@"A Title" message:@"A short message" buttonTitles:@[@"Button 1", @"Button 2", @"Button 3"] buttonStyle:JGActionSheetButtonStyleDefault];
    
    JGActionSheetSection *s2 = [JGActionSheetSection sectionWithTitle:@"Another Title" message:@"A long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long, very long message!" buttonTitles:@[@"Red Button", @"Green Button", @"Blue Button"] buttonStyle:JGActionSheetButtonStyleDefault];
    
    [s2 setButtonStyle:JGActionSheetButtonStyleRed forButtonAtIndex:0];
    [s2 setButtonStyle:JGActionSheetButtonStyleGreen forButtonAtIndex:1];
    [s2 setButtonStyle:JGActionSheetButtonStyleBlue forButtonAtIndex:2];
    
    JGActionSheet *sheet = [JGActionSheet actionSheetWithSections:@[s1, s2, [JGActionSheetSection sectionWithTitle:nil message:nil buttonTitles:@[@"Cancel"] buttonStyle:JGActionSheetButtonStyleCancel]]];
    
    sheet.delegate = self;
    
    sheet.insets = UIEdgeInsetsMake(20.0f, 0.0f, 0.0f, 0.0f);
    
    if (anchor && iPad) {
        _anchorView = anchor;
        _anchorLeft = YES;
        _currentAnchoredActionSheet = sheet;
        
        CGPoint p = (CGPoint){-5.0f, CGRectGetMidY(anchor.bounds)};
        
        p = [self.navigationController.view convertPoint:p fromView:anchor];
        
        [sheet showFromPoint:p inView:self.navigationController.view arrowDirection:JGActionSheetArrowDirectionRight animated:YES];
    }
    else {
        [sheet showInView:self.navigationController.view animated:YES];
    }
    
    if (iPad) {
        [sheet setOutsidePressBlock:^(JGActionSheet *sheet) {
            [sheet dismissAnimated:YES];
        }];
    }
    
    [sheet setButtonPressedBlock:^(JGActionSheet *sheet, NSIndexPath *indexPath) {
        [sheet dismissAnimated:YES];
    }];
}

- (void)multipleAndContentView:(UIView *)anchor {
    JGActionSheetSection *s1 = [JGActionSheetSection sectionWithTitle:@"A Title" message:@"A short message" buttonTitles:@[@"Button 1", @"Button 2", @"Button 3"] buttonStyle:JGActionSheetButtonStyleDefault];
    
    JGActionSheetSection *s2 = [JGActionSheetSection sectionWithTitle:@"Another Title" message:@"A message!" buttonTitles:@[@"Red Button", @"Green Button", @"Blue Button"] buttonStyle:JGActionSheetButtonStyleDefault];
    
    UISlider *c = [[UISlider alloc] init];
    c.frame = (CGRect){CGPointZero, {290.0f, c.frame.size.height}};
    
    JGActionSheetSection *s3 = [JGActionSheetSection sectionWithTitle:@"Content View Section" message:nil contentView:c];
    
    [s2 setButtonStyle:JGActionSheetButtonStyleRed forButtonAtIndex:0];
    [s2 setButtonStyle:JGActionSheetButtonStyleGreen forButtonAtIndex:1];
    [s2 setButtonStyle:JGActionSheetButtonStyleBlue forButtonAtIndex:2];
    
    JGActionSheet *sheet = [JGActionSheet actionSheetWithSections:@[s1, s2, s3, [JGActionSheetSection sectionWithTitle:nil message:nil buttonTitles:@[@"Cancel"] buttonStyle:JGActionSheetButtonStyleCancel]]];
    
    sheet.delegate = self;
    
    sheet.insets = UIEdgeInsetsMake(20.0f, 0.0f, 0.0f, 0.0f);
    
    if (anchor && iPad) {
        _anchorView = anchor;
        _anchorLeft = YES;
        _currentAnchoredActionSheet = sheet;
        
        CGPoint p = (CGPoint){-5.0f, CGRectGetMidY(anchor.bounds)};
        
        p = [self.navigationController.view convertPoint:p fromView:anchor];
        
        [sheet showFromPoint:p inView:self.navigationController.view arrowDirection:JGActionSheetArrowDirectionRight animated:YES];
    }
    else {
        [sheet showInView:self.navigationController.view animated:YES];
    }
    
    if (iPad) {
        [sheet setOutsidePressBlock:^(JGActionSheet *sheet) {
            [sheet dismissAnimated:YES];
        }];
    }
    
    [sheet setButtonPressedBlock:^(JGActionSheet *sheet, NSIndexPath *indexPath) {
        [sheet dismissAnimated:YES];
    }];
}

@end
