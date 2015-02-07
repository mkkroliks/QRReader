//
//  ViewController.h
//  QRReader
//
//  Created by Maciej Krolikowski on 08/11/14.
//  Copyright (c) 2014 Maciej Krolikowski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController : UIViewController <AVCaptureMetadataOutputObjectsDelegate> 

@property (weak, nonatomic) IBOutlet UIView *cameraView;
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *scanButton;

- (IBAction)stopStartScanning:(id)sender;


@end

