
#include "lwHTTPClient.h"

@interface HTTPDelegate : NSObject<NSURLConnectionDelegate> {
    lw::HTTPMsg *pMsg;
    bool dead;
}
- (id)initWithMsg:(lw::HTTPMsg*)p;
- (void)die;
@end

namespace lw{
    HTTPErrorCallback _pHTTPErrorCallback = NULL;
    HTTPErrorCallback _pHTTPOKCallback = NULL;
    
    void setHTTPErrorCallback(HTTPErrorCallback pCallback){
        _pHTTPErrorCallback = pCallback;
    }
    
    void setHTTPOKCallback(HTTPOKCallback pCallback){
        _pHTTPOKCallback = pCallback;
    }
    
	HTTPMsg::HTTPMsg(const char* route, HTTPClient* pClient, bool useHTTPS)
	:_pClient(pClient), _useHTTPS(useHTTPS){
		lwassert(route);
		_buff = route;
    }

	HTTPMsg::~HTTPMsg(){
        [(HTTPDelegate*)_pDelegate die];
		[(HTTPDelegate*)_pDelegate release];
	}

	void HTTPMsg::send(){
		std::stringstream ss;
        if ( _useHTTPS && _pClient->isHTTPSEnabled() ){
            ss << "https://" << _pClient->getHost() << _buff.c_str();
        }else{
            ss << "http://" << _pClient->getHost() << _buff.c_str();
        }
        NSString* urlString=[[NSString alloc] initWithUTF8String:ss.str().c_str()];
        NSURL* url=[[NSURL alloc] initWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSURLRequest *theRequest=[NSURLRequest requestWithURL:url
                                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                              timeoutInterval:60.0];
        [urlString release];
        [url release];
        HTTPDelegate* pCallback = [[HTTPDelegate alloc] initWithMsg:this];
        NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:pCallback];
        if (!theConnection) {
            onRespond(LWHTTPERR_CONNECTION);
            delete this;
        }
	}
    
    void HTTPMsg::addParam(const char* param){
        _buff.append(param);
    }
    
    HTTPClient::HTTPClient(const char* host, bool enableHTTPS)
    :_httpsEnable(enableHTTPS){
		_strHost = host;
	}

	HTTPClient::~HTTPClient(){
		
	}
	
} //namespace lw

@implementation HTTPDelegate
- (id)initWithMsg:(lw::HTTPMsg*)p
{
    if ( self =[super init] ){
        pMsg=p;
        pMsg->_pDelegate=self;
        dead = false;
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

-(void)die{
    dead = true;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if ( dead )
        return;
    pMsg->getBuff().clear();
    if ( lw::_pHTTPOKCallback ){
        lw::_pHTTPOKCallback();
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if ( dead )
        return;
    pMsg->getBuff().append((char*)([data bytes]), [data length]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if ( dead ){
        [connection release];
        return;
    }
    pMsg->onRespond(LWHTTPERR_NONE);
    delete pMsg;
    [connection release];
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if ( dead ){
        [connection release];
        return;
    }
    lwerror("http error:" << [[error localizedDescription]UTF8String] << " from: " << pMsg->getBuff().c_str());
    if ( lw::_pHTTPErrorCallback ){
        lw::_pHTTPErrorCallback();
    }
    pMsg->onRespond(LWHTTPERR_NET);
    delete pMsg;
}

@end