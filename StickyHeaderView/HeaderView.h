//
//  HeaderView.h
//  StickyHeaderView
//
//  Created by Bastian Kohlbauer on 15.03.14.
//  Copyright (c) 2014 Bastian Kohlbauer. All rights reserved.
//

#import <UIKit/UIKit.h>

#define HEADER_HEIGHT 180.0f
#define HEADER_INIT_FRAME CGRectMake(0, 0, self.view.frame.size.width, HEADER_HEIGHT)

@protocol HeaderViewDelegate <NSObject>

@optional
- (void)toggleExpandedHeaderView;
@end

/* Example of usage toggleHeaderViewFrame
#pragma mark - Header View Delegate Method
- (void)toggleHeaderViewFrame
{
    [UIView animateWithDuration:0.8
                     animations:^{
                         
                         self.headerView.isExpanded = !self.headerView.isExpanded;
                         [self.headerView updateFrame:self.headerView.isExpanded ? [self.view frame] : HEADER_INIT_FRAME];
                         
                     } completion:^(BOOL finished){
                         
                         [self.tableView setScrollEnabled:!self.headerView.isExpanded];
                         
                     }];
    
}
*/

@interface HeaderView : UIView <UIScrollViewDelegate>

@property (nonatomic, weak) id <HeaderViewDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *viewControllers;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic) BOOL isExpanded; //default is NO
@property (nonatomic) BOOL pageControlUsed;

//designated initializer
- (instancetype)initWithFrame:(CGRect)frame withImages:(NSArray *)images;

- (void)updateFrame:(CGRect)rect;

@end
