//
//  MenuVC.m
//  Sudoku
//
//  Created by Allan Luk on 2015-09-08.
//  Copyright (c) 2015 Allan Luk. All rights reserved.
//

#import "MenuVC.h"
#import "MainGameVC.h"

@interface MenuVC ()

@end

@implementation MenuVC

- (void)loadView {
    
    [super loadView];
    
    self.view.backgroundColor = [UIColor orangeColor];
    
    UILabel *startLabel = [UILabel new];
    startLabel.backgroundColor = [UIColor whiteColor];
    startLabel.text = @"Start";
    startLabel.textAlignment = NSTextAlignmentCenter;
    startLabel.textColor = [UIColor blackColor];
    startLabel.userInteractionEnabled = YES;
    [startLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchToMainGame:)]];
    startLabel.frame = (CGRect){(self.view.bounds.size.width-200)/2,(self.view.bounds.size.height-75)/2,200,75};
    
    [self.view addSubview:startLabel];
    
}

-(void)switchToMainGame:(UITapGestureRecognizer*)tgr {
    MainGameVC *mainGameVC = [MainGameVC new];
    [self presentViewController:mainGameVC animated:YES completion:nil];
}

@end
