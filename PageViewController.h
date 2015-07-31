//
//  PageViewController.h
//
//  Created by Joan Domenech on 22/10/14.
//  Copyright (c) 2014 Joan Domenech. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * Clase contenedor de tipo UIPageViewController.
 */
@interface PageViewController : UIViewController
<UIPageViewControllerDataSource, UIPageViewControllerDelegate>

/**
 *  Método init customizado para inicializar a la vez la propiedad 'viewControllers'
 *
 *  @param viewControllers NSArray de UIViewControllers para añadir
 *
 *  @return nueva instancia de la clase
 */
-(instancetype)initWithViewController:(NSArray *)viewControllers;

/**
 * Colección de UIViewControllers que se muestran en cómo páginas
 */
@property (nonatomic, strong) NSArray *viewControllers;

/**
 * Determina si se habilita o no el 'bounce'. Por defecto no se habilita.
 */
@property (nonatomic) BOOL enableBounce;

/**
 * Determina si se visualiza o no el 'PageControl'. Por defecto se visualiza.
 */
@property (nonatomic) BOOL hiddenPageControl;

/**
 * Devuelve la página actual que se muestra
 */
@property (nonatomic, readonly) NSInteger currentPage;


/**
 *  Añade un UIViewController cómo una nueva página
 *
 *  @param viewController UIViewController que se quiere añadir al contenedor de páginas
 */
-(void)addViewControllerPage:(UIViewController*)viewController;

/**
 *  Muestra el UIViewController según su página de ubicación
 *
 *  @param page NSInteger con el número de página correspondiente al UIViewController que se desea mostrar
 */
-(void)showViewControllerPageAtIndex:(NSInteger)page;

@end







