//
//  VZStacView.m
//  VZ
//
//  Created by Travis on 13-11-20.
//  Copyright (c) 2013年 Plumn LLC. All rights reserved.
//

#import "VZStacView.h"

#define WHRate 0.6
#define TRIGGER_DLT 0.4
@interface VZStacView ()
{
    int count;
    float imageH;
    
    CGRect imgFrame;
    float scrollY;
    
}
@end

@implementation VZStacView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.initFrame=frame;
        imageH=frame.size.width*WHRate;
        imgFrame=CGRectMake(0, frame.size.height-imageH, frame.size.width, imageH);
    }
    return self;
}

-(void)addImage:(UIImage*)img{
    if (self.open) {
        return;
    }
    UIImageView *imgv=[[UIImageView alloc] initWithImage:img];
    imgv.contentMode=UIViewContentModeScaleAspectFill;
    imgv.clipsToBounds=YES;
    imgv.frame=imgFrame;
    
    imgv.tag=count;
    imgv.alpha=0.2;
    count++;
    
    [UIView beginAnimations:@"add" context:nil];
    [UIView setAnimationDuration:0.2];
    [self insertSubview:imgv atIndex:count];
    [self scroll:0];
    [UIView commitAnimations];
}

-(void)scroll:(float)y{
    float dlt=-y/self.initFrame.size.height;
    if (self.open) {
        return;
    }
    
    if (dlt>=TRIGGER_DLT) {
        self.open=YES;
        return;
    }
    dlt=MAX(0.07, dlt);
    [self layoutWithDelta:dlt];
}


-(void)layoutWithDelta:(float)dlt{
    CGRect f=self.frame;
    
    float gapH=imageH*dlt/5.0;
    
    for (UIImageView *imgv in self.subviews) {
        float scale=1.0-(count-imgv.tag-1)*(TRIGGER_DLT-dlt)*0.2;
        imgv.transform=CGAffineTransformScale(CGAffineTransformIdentity, scale, scale);
        
        float y=f.size.height-imageH*(1.0-scale*0.5)-(count-imgv.tag)*gapH;
        imgv.center=CGPointMake(self.initFrame.size.width/2, y);
        imgv.alpha=scale;
    }
}

-(void)setOpen:(BOOL)open{
    _open=open;
    
    [UIView beginAnimations:@"open" context:nil];
    [UIView setAnimationDuration:0.5];
    
    if (open) {
        
        float h=0;
        
        for (UIImageView *imgv in self.subviews) {
            imgv.transform=CGAffineTransformScale(CGAffineTransformIdentity, 1,1);
            imgv.alpha=1;
            
            CGSize size=imgv.image.size;
            
            float r=size.width/size.height;
            
            size.width=self.initFrame.size.width-8;
            size.height=size.width*r;
            
            imgv.frame=CGRectMake(4, h, size.width, size.height);
            
            h+=size.height+4;
        }
        CGRect f=self.initFrame;
        f.size.height=h;
        self.frame=f;
        
        
    }else{
        self.frame=self.initFrame;
        [self layoutWithDelta:0];
    }
    if (self.delegate) {
        [self.delegate stacViewOpenChanged:self];
    }
    [UIView commitAnimations];
    
}

@end
