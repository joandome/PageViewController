//
//  PageViewController.m
//
//  Created by Joan Domenech on 22/10/14.
//  Copyright (c) 2014 Joan Domenech. All rights reserved.
//

#import "PageViewController.h"

@interface PageViewController ()
<UIScrollViewDelegate>
{
    NSMutableDictionary *_dicViewControllers;
    BOOL _alreadyDone;
}

@property (nonatomic, strong) UIPageViewController *pageController;
//@property (nonatomic, strong) UIPageControl *pageControl;

@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIView *viewContainer;

@end

@implementation PageViewController

@synthesize pageControl = _pageControl;
@synthesize viewControllers = _viewControllers;

#pragma mark - View Lifecycle

-(instancetype)init
{
    if (self = [super initWithNibName:@"PageViewController" bundle:nil])
    {
        [self initialize];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self initialize];
    }
    return self;
}

-(instancetype)initWithViewController:(NSArray *)viewControllers
{
    self = [self init];
    if (self)
    {
        [self setViewControllers:viewControllers];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self basePageControllerConfigurations];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!_alreadyDone)
    {
        _alreadyDone = YES;
        [self configureViews];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Methods

/**
 *  Añade todos los elementos del array a un NSMutableDictionary, a partir del cúal se gestionan las páginas a mostrar
 *
 *  @param viewControllers NSArray de UIViewControllers para añadir
 */
-(void)addViewControllersToPages:(NSArray*)viewControllers
{
    NSInteger lastKey = [_dicViewControllers count];
    for (UIViewController *vc in viewControllers)
    {
        [_dicViewControllers setObject:vc forKey:@(lastKey)];
        lastKey++;
    }
    
    [self.pageControl setNumberOfPages:[_dicViewControllers count]];

    [self.pageControl setHidden:([_dicViewControllers count] < 2)];
}

/**
 *  Devuelve el UIViewController correspondiente al índice de página detallado
 *
 *  @param index NSInteger correspondiente al índice de la página
 *
 *  @return UIViewController que hace referencia al índice
 */
-(UIViewController *)viewControllerAtIndex:(NSInteger)index
{
    return [_dicViewControllers objectForKey:@(index)];
}

/**
 *  Devuelve el índide de página correspondiente al UIViewController especificado
 *
 *  @param viewController UIViewController a buscar en las páginas
 *
 *  @return NSInteger con el índice correspondiente al UIViewController. Si no se encuentra el UIViewController, devuelve 0.
 */
-(NSInteger)indexOfViewController:(UIViewController*)viewController
{
    NSArray *allKeysObject = [_dicViewControllers allKeysForObject:viewController];
    return [[allKeysObject firstObject] integerValue];
}

/**
 * Añade un UIPageControl en la parte central de la barra de navegación
 */
-(void)showPageControlInNavigationBar
{
    [[[self.navigationItem titleView] subviews] performSelector:@selector(removeFromSuperview)];
    
    [self.pageControl setCurrentPage:0];
    
    UIView *iv = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width/3,32)];
    [iv setBackgroundColor:[UIColor clearColor]];
    
    [self.pageControl setFrame:iv.bounds];
    
    [iv addSubview:self.pageControl];
    self.navigationItem.titleView = iv;
}

#pragma mark - Properties

-(void)setViewControllers:(NSArray *)viewControllers
{
    _viewControllers = viewControllers;
    [_dicViewControllers removeAllObjects];
    [self addViewControllersToPages:viewControllers];
    
    [self.pageController reloadInputViews];
}

-(NSArray *)viewControllers
{
    return _viewControllers;
}

//-(UIPageControl *)pageControl
//{
//    if (!_pageControl)
//    {
//        _pageControl = [[UIPageControl alloc] init];
//    }
//    return _pageControl;
//}

-(NSInteger)currentPage
{
    return self.pageControl.currentPage;
}

-(void)setHiddenPageControl:(BOOL)hidePageControl
{
    _hiddenPageControl = hidePageControl;
    [self.pageControl setHidden:_hiddenPageControl];
}

#pragma mark - Configurations

/**
 * Método inicializador de los diferentes componentes
 */
-(void)initialize
{
    _dicViewControllers = [[NSMutableDictionary alloc] init];
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    self.pageController.dataSource = self;
    self.pageController.delegate = self;
    self.enableBounce = NO;
    self.hiddenPageControl = NO;
    
    for (UIView *view in self.pageController.view.subviews)
    {
        if ([view isKindOfClass:[UIScrollView class]])
        {
            UIScrollView *scroll = (UIScrollView *)view;
            [scroll setDelegate:self];
        }
    }
}

/**
 * Configuración básica de la clase
 */
-(void)basePageControllerConfigurations
{
    [self.pageControl setNumberOfPages:[_dicViewControllers count]];
    [self.pageControl setHidden:_hiddenPageControl];

    [[self.pageController view] setFrame:[[self viewContainer] bounds]];

    UIViewController *initialViewController = [self viewControllerAtIndex:0];
    
    if (initialViewController)
    {
        NSArray *initViewController = [NSArray arrayWithObject:initialViewController];
        
        [self.pageController setViewControllers:initViewController direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    }
    
    [self addChildViewController:self.pageController];
    [[self viewContainer] addSubview:[self.pageController view]];
    [self.pageController didMoveToParentViewController:self];
}

/**
 * Configuración a nivel de vistas
 */
-(void)configureViews
{
    [[self.pageController view] setFrame:[[self viewContainer] bounds]];

    
    UIViewController *viewController = [self viewControllerAtIndex:self.currentPage];
    
    if (viewController)
    {
        self.title = [viewController title];
    }

//    [self showPageControlInNavigationBar];
}

#pragma mark - Public Methods

-(void)addViewControllerPage:(UIViewController *)viewController
{
    [self addViewControllersToPages:[NSArray arrayWithObject:viewController]];
    
    [self.pageController reloadInputViews];
}

-(void)showViewControllerPageAtIndex:(NSInteger)page
{
    UIViewController *viewController = [self viewControllerAtIndex:page];
    
    if (viewController)
    {
        self.title = [viewController title];
        
        NSArray *initViewController = [NSArray arrayWithObject:viewController];
        
        [self.pageController setViewControllers:initViewController direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
        
        self.pageControl.currentPage = page;
    }
}

#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSInteger index = [self indexOfViewController:viewController];
    
    if (index == 0)
        return nil;
    
    index--;
    
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSInteger index = [self indexOfViewController:viewController];
    
    if (index == [_dicViewControllers count]-1)
        return nil;

    index++;
    
    return [self viewControllerAtIndex:index];
}

#pragma mark - UIPageViewControllerDelegate

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if (!completed)
        return;
    
    UIViewController *currentViewController = [self.pageController.viewControllers lastObject];
    NSUInteger index = [self indexOfViewController:currentViewController];
    
    self.pageControl.currentPage = index;
    self.title = [currentViewController title];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!self.enableBounce)
    {
        if (self.currentPage == 0 && scrollView.contentOffset.x < scrollView.bounds.size.width)
        {
            scrollView.contentOffset = CGPointMake(scrollView.bounds.size.width, 0);
        }
        if (self.currentPage == [_dicViewControllers count]-1 && scrollView.contentOffset.x > scrollView.bounds.size.width)
        {
            scrollView.contentOffset = CGPointMake(scrollView.bounds.size.width, 0);
        }
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (!self.enableBounce)
    {
        if (self.currentPage == 0 && scrollView.contentOffset.x <= scrollView.bounds.size.width)
        {
            velocity = CGPointZero;
            *targetContentOffset = CGPointMake(scrollView.bounds.size.width, 0);
        }
        if (self.currentPage == [_dicViewControllers count]-1 && scrollView.contentOffset.x >= scrollView.bounds.size.width)
        {
            velocity = CGPointZero;
            *targetContentOffset = CGPointMake(scrollView.bounds.size.width, 0);
        }
    }
}

#pragma mark - iOS 8 Rotation

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [self.pageController setDataSource:UIInterfaceOrientationIsLandscape((UIInterfaceOrientation)[[UIDevice currentDevice]orientation]) ? nil : self];
}

#pragma mark - iOS 7 Rotation

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.pageController setDataSource:UIInterfaceOrientationIsLandscape((UIInterfaceOrientation)[[UIDevice currentDevice]orientation]) ? nil : self];
}

@end
















