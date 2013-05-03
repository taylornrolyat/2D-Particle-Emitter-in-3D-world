//
//  Tutorial14ViewController.h
//  Tutorial14
//
//  Created by Mike Daley on 20/03/2011.
//  Copyright 2011 Personal. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <OpenGLES/EAGL.h>

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#import "CommonOpenGL.h"

@class ParticleEmitter;

@interface Tutorial14ViewController : UIViewController {
@private
    EAGLContext *context;
    GLuint program;
    
    BOOL animating;
    NSInteger animationFrameInterval;
    CADisplayLink *displayLink;

    // Angle of rotation
    GLfloat angle;
    
    // Floor Vertices
    SSVertex3D zFloorVertices[81];
    SSVertex3D xFloorVertices[81];
    
    ParticleEmitter *pe;
}

@property (readonly, nonatomic, getter=isAnimating) BOOL animating;
@property (nonatomic) NSInteger animationFrameInterval;

- (void)startAnimation;
- (void)stopAnimation;


@end
