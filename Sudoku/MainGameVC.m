//
//  MainGameVC.m
//  Sudoku
//
//  Created by Allan Luk on 2015-09-08.
//  Copyright (c) 2015 Allan Luk. All rights reserved.
//

#import "MainGameVC.h"

@interface MainGameVC ()

@end

@implementation MainGameVC {
    int baseSudoku[9][9];
    float boardLength, squareLength;
    
    UIView *boardView, *numberPickerView, *hintClickTileView;
}

-(void)loadView {
    [super loadView];
    
    [self setupGraphics];
    [self createSudoku];
}

- (void)setupGraphics {
    
    // Create Background View
    UIView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Game-Background.jpg"]];
    backgroundView.userInteractionEnabled = YES;
    backgroundView.frame = self.view.frame;
    [self.view addSubview:backgroundView];
    [self.view sendSubviewToBack:backgroundView];
    
    // Create Square Board View
    int smallerLength = MIN([UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height);
    const int indent = 19.5;
    boardView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Sudoku-Board.jpg"]];
    boardView.frame = (CGRect){indent, indent, smallerLength-2*indent, smallerLength-2*indent};
    boardView.layer.borderWidth = 2;
    boardView.layer.borderColor = [[UIColor whiteColor] CGColor];
    boardView.userInteractionEnabled = YES;
    [self.view addSubview:boardView];
    
    boardLength = boardView.bounds.size.width;
    squareLength = boardLength/9;
    
    // Create Visible Sudoku Board
    // Create Lines on Board
    for(int i = 1; i < 9; i++){
        UIView *whiteVerticalLineView = [[UIView alloc] initWithFrame:(CGRect){squareLength*i,0,2,boardLength}];
        whiteVerticalLineView.backgroundColor = [UIColor whiteColor];
        [boardView addSubview:whiteVerticalLineView];
        
        UIView *whiteHorizontalLineView = [[UIView alloc] initWithFrame:(CGRect){0, squareLength*i, boardLength, 2}];
        whiteHorizontalLineView.backgroundColor = [UIColor whiteColor];
        [boardView addSubview:whiteHorizontalLineView];
    }
    
    // Drawing Number Picker Board
    numberPickerView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Wooden-Panel.jpg"]];
    numberPickerView.frame = (CGRect){19.5+boardLength+50, [UIScreen mainScreen].bounds.size.height/2, [UIScreen mainScreen].bounds.size.width-19.5-boardLength-100, [UIScreen mainScreen].bounds.size.height/2-19.5};
    numberPickerView.userInteractionEnabled = YES;
    [numberPickerView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectNumber:)]];
    [self.view addSubview:numberPickerView];
    
    for(int i = 0; i < 9; i++){
        UILabel *numberLabel = [UILabel new];
        numberLabel.frame = (CGRect){numberPickerView.bounds.size.width/3*(i%3),numberPickerView.bounds.size.height/3*(i/3), numberPickerView.bounds.size.width/3, numberPickerView.bounds.size.height/3};
        numberLabel.textAlignment = NSTextAlignmentCenter;
        numberLabel.font = [UIFont boldSystemFontOfSize:28];
        numberLabel.text = [NSString stringWithFormat:@"%d", i+1];
        numberLabel.textColor = [UIColor whiteColor];
        [numberPickerView addSubview:numberLabel];
    }
    
    // Drawing Lines on Game Board
    for(int i = 0; i < 4; i++){
        UIView *verticalLineView = [[UIView alloc] initWithFrame:(CGRect){numberPickerView.bounds.size.width/3*i,0,2,numberPickerView.bounds.size.height}];
        verticalLineView.backgroundColor = [UIColor whiteColor];
        [numberPickerView addSubview:verticalLineView];
        
        UIView *horizontalLineView = [[UIView alloc] initWithFrame:(CGRect){0,numberPickerView.bounds.size.height/3*i,numberPickerView.bounds.size.width, 2}];
        horizontalLineView.backgroundColor = [UIColor whiteColor];
        [numberPickerView addSubview:horizontalLineView];
    }
}

- (void)createSudoku {
    
    // Number of iterations
    int numIterations = 30;
    
    // Create the Base Sudoku solution
    for(int i = 0; i < 9; i++) {
        for(int j = 0; j < 9; j++) {
            baseSudoku[i][j] = (int)(i*3 + floor(i/3) + j) % 9 + 1;
        }
    }
    
    // Random shuffle numbers in Base Sudoku
    // Pick two numbers, scan the board for first number and replace with second number; repeat
    // Twenty iterations chosen
    for(int i = 0; i < numIterations; i++){
        int firstNum = (int)(arc4random_uniform(9)+1);
        int secondNum;
        do {
            secondNum = (int)(arc4random_uniform(9)+1);
        } while(firstNum == secondNum);
        
        for(int row = 0; row < 9; row++){
            for(int col = 0; col < 9; col++) {
                if(baseSudoku[row][col] == firstNum)
                    baseSudoku[row][col] = secondNum;
                else if(baseSudoku[row][col] == secondNum)
                    baseSudoku[row][col] = firstNum;
            }
        }
    }
    
    // Random shuffle of corresponding columns from each column of subsquares
    for(int a = 0; a < numIterations; a++){
        int a1 = arc4random_uniform(3);
        int a2 = arc4random_uniform(3);
        
        for(int row = 0; row < 9; row++){
            int temp = baseSudoku[row][a1 * 3 + a % 3];
            baseSudoku[row][a1 * 3 + a % 3] = baseSudoku[row][a2 * 3 + a % 3];
            baseSudoku[row][a2 * 3 + a % 3] = temp;
        }
    }
    
    // Random shuffle of columns within each column of subsquares
    for(int b = 0; b < numIterations; b++){
        int b1 = arc4random_uniform(3);
        int b2 = arc4random_uniform(3);
        
        for(int row = 0; row < 9; row++) {
            int temp = baseSudoku[row][3 * (b % 3) + b1];
            baseSudoku[row][b1 + 3 * (b % 3)] = baseSudoku[row][b2 + 3 * (b % 3)];
            baseSudoku[row][b2 + 3 * (b % 3)] = temp;
        }
    }
    
    // Random shuffle of rows within each row of subsquares
    for(int c = 0; c < numIterations; c++){
        int c1 = arc4random_uniform(3);
        int c2 = arc4random_uniform(3);
        
        for(int col = 0; col < 9; col++){
            int temp = baseSudoku[3 * (c % 3) + c1][col];
            baseSudoku[3 * (c % 3) + c1][col] = baseSudoku[3 * (c % 3) + c2][col];
            baseSudoku[3 * (c % 3) + c2][col] = temp;
        }
    }
    
    // Print sudoku
    NSLog(@"Sudoku:\n");
    
    for(int i = 0; i < 9; i++){
        NSMutableString *sudokuRow = [NSMutableString new];
        for(int j = 0; j < 9; j++){
            [sudokuRow appendString:[NSString stringWithFormat:@"%d", baseSudoku[i][j]]];
        }
        NSLog(@"%@\n", sudokuRow);
    }
}

-(void)selectNumber:(UITapGestureRecognizer*)tapgr{
    
    CGPoint tapPoint = [tapgr locationInView:numberPickerView];
    int x = tapPoint.x/(numberPickerView.bounds.size.width/3);
    int y = tapPoint.y/(numberPickerView.bounds.size.height/3);
    
    // In case user taps very edge
    x = MIN(x,2);
    y = MIN(y,2);
    
    int selectedNumber = y*3+x+1;
    NSLog([NSString stringWithFormat:@"%d", selectedNumber]);
}

@end
