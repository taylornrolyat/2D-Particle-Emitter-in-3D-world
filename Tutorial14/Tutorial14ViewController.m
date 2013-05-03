//
//  Tutorial14ViewController.m
//  Tutorial14
//
//  Created by Mike Daley on 20/03/2011.
//  Copyright 2011 Personal. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "Tutorial14ViewController.h"
#import "EAGLView.h"

#import "ParticleEmitter.h"


@interface Tutorial14ViewController ()
@property (nonatomic, retain) EAGLContext *context;
@property (nonatomic, assign) CADisplayLink *displayLink;

// Init OpenGL ES ready to render in 3D
- (void)initOpenGLES1;

// Init the game objects and ivars
- (void)initGame;

// Update the scene
- (void)updateWithDelta:(float)aDelta;

// Render the scene
- (void)drawFrame;

// Manages the game loop and as called by the displaylink
- (void)gameLoop;

@end

@implementation Tutorial14ViewController

@synthesize animating, context, displayLink;

- (void)awakeFromNib
{
    EAGLContext *aContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
    
    if (!aContext)
        NSLog(@"Failed to create ES context");
    else if (![EAGLContext setCurrentContext:aContext])
        NSLog(@"Failed to set ES context current");
    
	self.context = aContext;
	[aContext release];
	
    [(EAGLView *)self.view setContext:context];
    [(EAGLView *)self.view setFramebuffer];
    
    animating = FALSE;
    animationFrameInterval = 1;
    self.displayLink = nil;
    
    // Init game
    [self initGame];
    
    ////////////////////////
    // Create a particle emitter instance.
    pe = [[ParticleEmitter alloc] initParticleEmitterWithFile:@"explode.pex"];
}

- (void)dealloc
{
    
    // Tear down context.
    if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];
    
    [context release];
    
    [pe release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewWillAppear:(BOOL)animated
{
    // Init OpenGL ES 1
    [self initOpenGLES1];
    
    [self startAnimation];
        
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self stopAnimation];
    
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
	[super viewDidUnload];

    // Tear down context.
    if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];
	self.context = nil;	
}

- (NSUInteger)application:(UIApplication*)application supportedInterfaceOrientationsForWindow:(UIWindow*)window
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscapeLeft;
}

- (NSInteger)animationFrameInterval
{
    return animationFrameInterval;
}

- (void)setAnimationFrameInterval:(NSInteger)frameInterval
{
    /*
	 Frame interval defines how many display frames must pass between each time the display link fires.
	 The display link will only fire 30 times a second when the frame internal is two on a display that refreshes 60 times a second. The default frame interval setting of one will fire 60 times a second when the display refreshes at 60 times a second. A frame interval setting of less than one results in undefined behavior.
	 */
    if (frameInterval >= 1) {
        animationFrameInterval = frameInterval;
        
        if (animating) {
            [self stopAnimation];
            [self startAnimation];
        }
    }
}

- (void)startAnimation
{
    if (!animating) {
        CADisplayLink *aDisplayLink = [[UIScreen mainScreen] displayLinkWithTarget:self selector:@selector(gameLoop)];
        [aDisplayLink setFrameInterval:animationFrameInterval];
        [aDisplayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        self.displayLink = aDisplayLink;
        
        animating = TRUE;
    }
}

- (void)stopAnimation
{
    if (animating) {
        [self.displayLink invalidate];
        self.displayLink = nil;
        animating = FALSE;
    }
}

- (void)initGame
{
    // Generate the floors vertices
    GLfloat z = -20.0f;
    for (uint index=0; index < 81; index += 2) {
        zFloorVertices[index].x = -20.0;
        zFloorVertices[index].y = -1;
        zFloorVertices[index].z = z;
        
        zFloorVertices[index+1].x = 20.0;
        zFloorVertices[index+1].y = -1;
        zFloorVertices[index+1].z = z;
        
        z += 2.0f;
    }
    
    GLfloat x = -20.0f;
    for (uint index=0; index < 81; index += 2) {
        xFloorVertices[index].x = x;
        xFloorVertices[index].y = -1;
        xFloorVertices[index].z = -20.0f;
        
        xFloorVertices[index+1].x = x;
        xFloorVertices[index+1].y = -1;
        xFloorVertices[index+1].z = 20;
        
        x += 2.0f;
    }
}

#pragma mark -
#pragma mark Game Loop

#define MAXIMUM_FRAME_RATE 90.0f
#define MINIMUM_FRAME_RATE 30.0f
#define UPDATE_INTERVAL (1.0 / MAXIMUM_FRAME_RATE)
#define MAX_CYCLES_PER_FRAME (MAXIMUM_FRAME_RATE / MINIMUM_FRAME_RATE)

- (void)gameLoop 
{
	static double lastFrameTime = 0.0f;
	static double cyclesLeftOver = 0.0f;
	double currentTime;
	double updateIterations;
	
	// Apple advises to use CACurrentMediaTime() as CFAbsoluteTimeGetCurrent() is synced with the mobile
	// network time and so could change causing hiccups.
	currentTime = CACurrentMediaTime();
	updateIterations = ((currentTime - lastFrameTime) + cyclesLeftOver);
	
	if(updateIterations > (MAX_CYCLES_PER_FRAME * UPDATE_INTERVAL))
		updateIterations = (MAX_CYCLES_PER_FRAME * UPDATE_INTERVAL);
	
	while (updateIterations >= UPDATE_INTERVAL) 
    {
		updateIterations -= UPDATE_INTERVAL;
		
		// Update the game logic passing in the fixed update interval as the delta
		[self updateWithDelta:UPDATE_INTERVAL];		
	}
	
	cyclesLeftOver = updateIterations;
	lastFrameTime = currentTime;
    
    // Render the frame
    [self drawFrame];
}

#pragma mark -
#pragma mark Update

- (void)updateWithDelta:(float)aDelta
{
    angle += 0.5f;
}

- (void)drawFrame
{    
    [(EAGLView *)self.view setFramebuffer];
    
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
/////////////  3D 
    
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    
    CGSize layerSize = self.view.layer.frame.size;
    gluPerspective(45.0f, (GLfloat)layerSize.height / (GLfloat)layerSize.width, 0.1f, 750.0f);
    
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
        
    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_LESS);
    glDepthMask(GL_TRUE);
    
    glDisable(GL_BLEND);
    glDisable(GL_TEXTURE_2D);
    
    static GLfloat z = 0;
    gluLookAt(0, 5, -10, 0, 0, 0, 0, 1, 0);
    z += 0.075f;
    
    // Rotate the scene
    glRotatef(angle, 0, 1, 0);
    
    glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
    glDisableClientState(GL_COLOR_ARRAY);
    glEnableClientState(GL_VERTEX_ARRAY);
    
    glVertexPointer(3, GL_FLOAT, 0, zFloorVertices);
    glDrawArrays(GL_LINES, 0, 42);
    
    glVertexPointer(3, GL_FLOAT, 0, xFloorVertices);
    glDrawArrays(GL_LINES, 0, 42);
    
////////////  2D 
    
    glViewport(0, 0, (GLfloat)layerSize.height, (GLfloat)layerSize.width);
    
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    
    glOrthof(0.0f, (GLfloat)layerSize.height, 0, (GLfloat)layerSize.width, -100.0f, 100.0f);
    
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    
    glDisable(GL_LIGHTING);
    glDisable(GL_DEPTH_TEST);
    glDisable(GL_CULL_FACE);
    
    [pe updateWithDelta:UPDATE_INTERVAL];
    
    // Setup the texture environment and blend functions.
	// This controls how a texture is blended with other textures
	glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_ALPHA);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    // Enable the OpenGL states we are going to be using when rendering
    glEnable(GL_BLEND);
	glEnable(GL_TEXTURE_2D);
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glEnableClientState(GL_COLOR_ARRAY);
    
    [pe renderParticles];
    
    [(EAGLView *)self.view presentFramebuffer];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:touch.view];
    
    CGSize layerSize = self.view.layer.frame.size;
    
    if (pe.active != YES)
    {
        pe.active = YES;
        pe.sourcePosition = Vector2fMake(location.x, (GLfloat)layerSize.width - location.y);
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:touch.view];
    
    CGSize layerSize = self.view.layer.frame.size;

    if (pe.active != YES)
    {
        pe.active = YES;
        pe.sourcePosition = Vector2fMake(location.x, (GLfloat)layerSize.width - location.y);
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    pe.active = NO;
}

- (void)initOpenGLES1
{
    // Set the clear color
    glClearColor(0, 0, 0, 1.0f);
    
    // Projection Matrix config
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    
    CGSize layerSize = self.view.layer.frame.size;
    gluPerspective(45.0f, (GLfloat)layerSize.height / (GLfloat)layerSize.width, 0.1f, 750.0f);
    
    // Modelview Matrix config
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    
    // This next line is not really needed as it is the default for OpenGL ES
    glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glDisable(GL_BLEND);
    
    // Enable depth testing
    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_LESS);
    glDepthMask(GL_TRUE);
    
}
@end