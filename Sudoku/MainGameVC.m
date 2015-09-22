//
//  MainGameVC.m
//  Sudoku
//
//  Created by Allan Luk on 2015-09-08.
//  Copyright (c) 2015 Allan Luk. All rights reserved.
//

#import "MainGameVC.h"

// Arbitrary decision to have an easier puzzle; 25 starting numbers
#define REVEALED_TILES 25

@interface MainGameVC ()

@end

@implementation MainGameVC {
    int baseSudoku[9][9], playerSudoku[9][9], xCoord, yCoord, remainingTiles, numMistakes;
    float boardLength, squareLength;
    BOOL tileActive;
    
    UIView *boardView, *numberPickerView, *hintClickTileView, *blinkingTileView;
    NSTimer *blinkTimer;
}

-(void)loadView {
    [super loadView];
    
    [self initializeState];
    [self createSudoku];
    [self setupGraphics];
    [self addStartingNumbers];
}

- (void)initializeState {
    
    // Ensure that no tiles are selected at the beginning.
    tileActive = NO;
    // Ensure user has no mistakes starting off
    numMistakes = 0;
    
    // Ensure that the player's sudoku begins blank (for now).
    for(int i = 0; i < 9; i++) {
        for(int j = 0; j < 9; j++) {
            playerSudoku[i][j] = 0;
        }
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
            [sudokuRow appendString:[NSString stringWithFormat:@"%d", baseSudoku[j][i]]];
        }
        NSLog(@"%@\n", sudokuRow);
    }
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
    numberPickerView.userInteractionEnabled = NO;
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
    
    // Drawing Instructions Board
    hintClickTileView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Wooden-Panel.jpg"]];
    hintClickTileView.frame = (CGRect){0,0,numberPickerView.bounds.size.width+2,numberPickerView.bounds.size.height+2};
    hintClickTileView.layer.borderColor = [[UIColor whiteColor] CGColor];
    hintClickTileView.layer.borderWidth = 2;
    hintClickTileView.userInteractionEnabled = NO;
    [numberPickerView addSubview:hintClickTileView];
    
    UILabel *instructionsLabel = [UILabel new];
    instructionsLabel.numberOfLines = 0;
    instructionsLabel.text = @"Click one of the Sudoku tiles to begin.";
    instructionsLabel.textColor = [UIColor whiteColor];
    instructionsLabel.font = [UIFont boldSystemFontOfSize:24];
    instructionsLabel.textAlignment = NSTextAlignmentCenter;
    instructionsLabel.frame = (CGRect){0,0,hintClickTileView.bounds.size};
    [hintClickTileView addSubview:instructionsLabel];
    
    // Create Clickable Tiles on Game Board
    for(int i = 0; i < 9; i++) {
        for(int j = 0; j < 9; j++) {
            UIView *squareView = [[UIView alloc] initWithFrame:(CGRect){i*squareLength, j*squareLength, squareLength, squareLength}];
            squareView.userInteractionEnabled = YES;
            [squareView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tileChosen:)]];
            [boardView addSubview:squareView];
        }
    }
}

- (void)addStartingNumbers {

    for(int startingSquares = 0; startingSquares < REVEALED_TILES; startingSquares++) {
        int x = arc4random_uniform(9);
        int y = arc4random_uniform(9);
        if(playerSudoku[x][y] == 0) {
            playerSudoku[x][y] = baseSudoku[x][y];
            
            UIView *defaultNumberView = [[UIView alloc] initWithFrame:(CGRect){x*squareLength, y*squareLength, squareLength, squareLength}];
            defaultNumberView.userInteractionEnabled = NO;
            [boardView addSubview:defaultNumberView];
            
            UILabel *numberLabel = [UILabel new];
            numberLabel.text = [NSString stringWithFormat:@"%d", baseSudoku[x][y]];
            numberLabel.textColor = [UIColor whiteColor];
            numberLabel.font = [UIFont boldSystemFontOfSize:20];
            numberLabel.textAlignment = NSTextAlignmentCenter;
            numberLabel.frame = (CGRect){1,1,defaultNumberView.bounds.size.width+1,defaultNumberView.bounds.size.height+1};
            [defaultNumberView addSubview:numberLabel];
        } else {
            startingSquares--;
        }
    }
    
    remainingTiles = 81 - REVEALED_TILES; // 56 tiles to be filled in
}

- (void)tileChosen:(UITapGestureRecognizer*)tapgr {
    int x = (int)([tapgr locationInView:boardView].x/squareLength);
    int y = (int)([tapgr locationInView:boardView].y/squareLength);
    
    if(playerSudoku[x][y] == 0) {
        xCoord = x;
        yCoord = y;
        //NSLog(@"%d, %d", xCoord, yCoord);
        
        [blinkingTileView removeFromSuperview];
        blinkingTileView = nil;
        [blinkTimer invalidate];
        blinkTimer = nil;
        numberPickerView.userInteractionEnabled = YES;
        hintClickTileView.hidden = YES;
        
        // Add Blinking Tile Effect.
        blinkingTileView = [[UIView alloc] initWithFrame:(CGRect){xCoord*squareLength,yCoord*squareLength, squareLength, squareLength}];
        blinkingTileView.backgroundColor = [UIColor whiteColor];
        blinkingTileView.hidden = NO;
        [boardView addSubview:blinkingTileView];
    
        blinkTimer = [NSTimer scheduledTimerWithTimeInterval:0.75 target:self selector:@selector(chosenTileBlink) userInfo:nil repeats:YES];
    } else {
        NSLog(@"Ignore press.");
    }
}

- (void)chosenTileBlink {
    if(blinkingTileView.hidden == YES)
        blinkingTileView.hidden = NO;
    else
        blinkingTileView.hidden = YES;
}

- (void)selectNumber:(UITapGestureRecognizer*)tapgr{
    
    CGPoint tapPoint = [tapgr locationInView:numberPickerView];
    int x = tapPoint.x/(numberPickerView.bounds.size.width/3);
    int y = tapPoint.y/(numberPickerView.bounds.size.height/3);
    
    // In Case the User Taps the Very Edge.
    x = MIN(x,2);
    y = MIN(y,2);
    
    int selectedNumber = y*3+x+1;
    //NSLog(@"%d", selectedNumber);
    
    if(baseSudoku[xCoord][yCoord] == selectedNumber) {
        numberPickerView.userInteractionEnabled = NO;
        hintClickTileView.hidden = NO;
        [blinkingTileView removeFromSuperview];
        blinkingTileView = nil;
        [blinkTimer invalidate];
        blinkTimer = nil;
        
        UIView *inputNumberView = [[UIView alloc] initWithFrame:(CGRect){xCoord*squareLength, yCoord*squareLength, squareLength, squareLength}];
        inputNumberView.userInteractionEnabled = YES;
        [inputNumberView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tileChosen:)]];
        [boardView addSubview:inputNumberView];
    
        UILabel *numberLabel = [UILabel new];
        numberLabel.text = [NSString stringWithFormat:@"%d", baseSudoku[xCoord][yCoord]];
        numberLabel.textColor = [UIColor whiteColor];
        numberLabel.font = [UIFont boldSystemFontOfSize:20];
        numberLabel.textAlignment = NSTextAlignmentCenter;
        numberLabel.frame = (CGRect){1,1,inputNumberView.bounds.size.width+1,inputNumberView.bounds.size.height+1};
        [inputNumberView addSubview:numberLabel];
        
        playerSudoku[xCoord][yCoord] = baseSudoku[xCoord][yCoord];
        remainingTiles--;
        
        if(remainingTiles == 0) {
            // Drawing Victory Board
            UIView *victoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Wooden-Panel.jpg"]];
            victoryView.frame = numberPickerView.frame;
            victoryView.layer.borderColor = [[UIColor whiteColor] CGColor];
            victoryView.layer.borderWidth = 2;
            victoryView.userInteractionEnabled = NO;
            
            [numberPickerView removeFromSuperview];
            numberPickerView = nil;
            [hintClickTileView removeFromSuperview];
            hintClickTileView = nil;
            
            [self.view addSubview:victoryView];
            
            UILabel *victoryLabel = [UILabel new];
            victoryLabel.numberOfLines = 0;
            victoryLabel.text = [NSString stringWithFormat:@"YOU WIN!\nNumber of Mistakes: %d", numMistakes];
            victoryLabel.textColor = [UIColor whiteColor];
            victoryLabel.font = [UIFont boldSystemFontOfSize:24];
            victoryLabel.textAlignment = NSTextAlignmentCenter;
            victoryLabel.frame = (CGRect){0,0,victoryView.bounds.size};
            [victoryView addSubview:victoryLabel];
        }
    } else {
        NSLog(@"YOU GOOFED.");
        numMistakes++;
    }
}

@end
