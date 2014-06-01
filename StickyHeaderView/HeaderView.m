//
//  HeaderView.m
//  StickyHeaderView
//
//  Created by Bastian Kohlbauer on 15.03.14.
//  Refactored and expanded by Kyle Adams on 1 - 06 - 2014
//  Copyright (c) 2014 Bastian Kohlbauer. All rights reserved.
//

#import "HeaderView.h"

@interface HeaderView ()

@property (nonatomic, strong) NSArray *imageNames;
@property (nonatomic, strong) UITapGestureRecognizer *singleTap;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end

@implementation HeaderView

- (instancetype)initWithFrame:(CGRect)frame withImages:(NSArray *)images;
{
    self = [super initWithFrame:frame];
    if (self) {
        _imageNames = images;
        [self setupViews];
    }
    return self;
}

- (void)setupViews
{
    //setup viewcontroller placeholders
    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    for (unsigned i = 0; i < [_imageNames count]; i++) {
        [controllers addObject:[NSNull null]];
    }
    self.viewControllers = controllers;
    
    [self addSubview:self.scrollView];
    if ([_imageNames count] > 1) [self addSubview:self.pageControl];
    [self.scrollView addGestureRecognizer:self.singleTap];
    [self loadScrollViewWithPage:0];
    [self loadScrollViewWithPage:1];
}

- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width * [_imageNames count], _scrollView.frame.size.height);
        _scrollView.backgroundColor = [UIColor whiteColor];
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.scrollsToTop = NO;
        _scrollView.autoresizesSubviews = YES;
        _scrollView.delegate = self;
    }
    return _scrollView;
}

- (UIPageControl *)pageControl
{
    if (!_pageControl) {
        CGRect frame = CGRectMake(0, self.frame.size.height-10, self.frame.size.width, 10);
        _pageControl = [[UIPageControl alloc] initWithFrame:frame];
        _pageControl.numberOfPages = [_imageNames count];
        _pageControl.backgroundColor = [UIColor clearColor];
        _pageControl.userInteractionEnabled = NO;
        _pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
        _pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
    }
    return _pageControl;
}

- (UITapGestureRecognizer *)singleTap
{
    if (!_singleTap) {
        _singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap)];
        _singleTap.numberOfTapsRequired = 1;
    }
    return _singleTap;
}

- (UIActivityIndicatorView *)activityIndicator
{
    if (!_activityIndicator) {
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    return _activityIndicator;
}

#pragma mark - Private Mehods
- (void)updateFrame:(CGRect)rect
{
    self.frame = rect;
    self.scrollView.frame = rect;
    
    float y = self.frame.size.height + _scrollView.frame.origin.y - 10.0f;
    self.pageControl.frame = CGRectMake(0.0f, y, self.frame.size.width, 10.0f);
}

#pragma mark - UITapGestureRecognizer
- (void)didTap
{
    if ([self.delegate respondsToSelector:@selector(toggleExpandedHeaderView)]) [self.delegate performSelector:@selector(toggleExpandedHeaderView)];
}

- (void)loadScrollViewWithPage:(int)page
{
    if (page < 0 || !(page >= [self.imageNames count])) {
        [self loadViewForScrollViewAtIndex:page];
    }
}

- (void)loadViewForScrollViewAtIndex:(int)pageIndex
{
    // replace the placeholder if necessary
    UIImageView *controller = [self.viewControllers objectAtIndex:pageIndex];
    if ((NSNull *)controller == [NSNull null]) {
        controller = [[UIImageView alloc] init];
        CGRect frame = self.scrollView.frame;
        frame.origin.x = frame.size.width * pageIndex;
        frame.origin.y = 0;
        controller.frame = frame;
        controller.contentMode = UIViewContentModeScaleAspectFill;
        controller.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        controller.layer.masksToBounds = YES;
        [self.scrollView addSubview:controller];
        
        [self.activityIndicator setCenter:CGPointMake(controller.center.x, controller.center.y)];
        [self.activityIndicator startAnimating];
        [controller addSubview:self.activityIndicator];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            for (int i = 0; i < [self.imageNames count]; i++) {
                if (pageIndex == i) {
                    //set up each page
                    [self.viewControllers replaceObjectAtIndex:pageIndex withObject:controller];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [controller setImage:[self.imageNames objectAtIndex:i]];
                        [self.activityIndicator stopAnimating];
                        [self.activityIndicator removeFromSuperview];
                        return;
                    });
                }
            }
            
        });
    }
}

#pragma mark - ScrollView Methods
- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    if (_pageControlUsed) return;
    
    CGFloat pageWidth = _scrollView.frame.size.width;
    int page = floor((_scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    _pageControl.currentPage = page;
    
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
    // A possible optimization would be to unload the views+controllers which are no longer visible
}

// At the begin of scroll dragging, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _pageControlUsed = YES;
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset
{
    _pageControlUsed = NO;
}

@end
