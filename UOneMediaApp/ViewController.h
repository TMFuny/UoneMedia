//
//  ViewController.h
//  UOneMediaApp
//
//  Created by wuxin on 5/26/16.
//  Copyright © 2016 chiannetcenter. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (nullable, nonatomic, strong) IBOutlet UIButton * deleteButton;
@property (nullable, nonatomic, strong) IBOutlet UIButton * resetButton;
@property (nullable, nonatomic, strong) IBOutlet UIButton * pageButton;

- (IBAction) onReset:(UIButton *)button;
- (IBAction) onDelete:(UIButton *)button;
- (IBAction) onNavigate:(UIButton *)button;
@end

