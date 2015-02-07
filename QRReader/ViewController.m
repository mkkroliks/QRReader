//
//  ViewController.m
//  QRReader
//
//  Created by Maciej Krolikowski on 08/11/14.
//  Copyright (c) 2014 Maciej Krolikowski. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) AVCaptureSession *sessionCapture;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

@property (nonatomic) BOOL isScanning;

-(BOOL)startScanning;
-(void)stopScanning;
-(void)loadSound;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self startScanning];
    [self loadSound];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)stopStartScanning:(id)sender {
    if (!_isScanning) {
        if ([self startScanning]) {
            [_resultLabel setText:@"Waiting for a result..."];
            [_scanButton setTitle:@"Stop Scanning"];
        }
    }else{
        [self stopScanning];
        [_scanButton setTitle:@"Start Scanning"];
    }
    
    _isScanning = !_isScanning;
}

- (BOOL) startScanning {
    NSError * error;
    
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    
    if(!input) {
        NSLog(@"%@", [error localizedDescription]);
        return NO;
    }
    
    _sessionCapture = [[AVCaptureSession alloc] init];
    [_sessionCapture addInput:input];
    
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [_sessionCapture addOutput:captureMetadataOutput];
    
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("Queue", NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue]; //gdy klasa captureMetadataOutput rozpozna QRCode to wywoła metodę captureOutput(zdefiniowaną w protokole captureMetadataOuput) zaimplementowaną w naszej klasie przez co zostanie przesłany wynik z klasy captureMetadataOuput do naszej klasy
    [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]]; //dane wykryte z kamerki mają mieć tylko typ QRCode i musi w niej znajdywać się tylko jedene element
    
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_sessionCapture];
    [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [_videoPreviewLayer setFrame:_cameraView.layer.bounds];
    [_cameraView.layer addSublayer:_videoPreviewLayer];
    
    [_sessionCapture startRunning];
    
    return YES;
}

- (void)stopScanning {
    [_sessionCapture stopRunning];
    _sessionCapture = nil;
    
    [_videoPreviewLayer removeFromSuperlayer];
}

- (void)loadSound {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"accept_sound" ofType:@"wav"];
    NSURL *soundURL = [NSURL URLWithString:filePath];
    NSError *error;
    
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:&error];
    if(error) {
        NSLog(@"Can't play sound");
        NSLog(@"%@", [error localizedDescription]);
    }else{
        [_audioPlayer prepareToPlay];
    }
    
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if(metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        if([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            //Before I show all these, just remember that our code is currently running on a secondary thread, so everything must be performed on the main thread for taking place immediately. Here is how:
            //Tym secondary thread jest camerka która działa niezależnie od wszystkiego
            [_resultLabel performSelectorOnMainThread:@selector(setText:) withObject:[metadataObj stringValue] waitUntilDone:NO];
            [self performSelectorOnMainThread:@selector(stopScanning) withObject:nil waitUntilDone:NO];
            [_scanButton performSelectorOnMainThread:@selector(setTitle:) withObject:@"Start scanning" waitUntilDone:NO];
            _isScanning = NO;
            
            if(_audioPlayer) {
                [_audioPlayer play];
            }
        }
        
    }
}
@end
