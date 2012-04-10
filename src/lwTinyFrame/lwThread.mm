#include "lwThread.h"

@interface ThreadObj : NSObject{
    lw::Thread* _pThread;
}
@end

@implementation ThreadObj
-(id)initWithTread:(lw::Thread*)pThread{
    if (self = [super init])
    {
        _pThread = pThread;
    }
    return self;
}

-(void)main:(id)arg{
    _pThread->vThreadMain();
}

@end

namespace lw {
    struct Thread::Data{
        NSThread* nsThread;
        ThreadObj* thradObj;
    };
    
    Thread::Thread(){
        _pd = new Data;
        
        _pd->thradObj = [[ThreadObj alloc] initWithTread:this];
        _pd->nsThread = [[NSThread alloc] initWithTarget:_pd->thradObj
                                                     selector:@selector(main:)
                                                       object:nil];
    }
    
    Thread::~Thread(){
        [_pd->thradObj release];
        [_pd->nsThread release];
        delete _pd;
    }
    
    void Thread::startThread(){
        [_pd->nsThread start];
    }
}
