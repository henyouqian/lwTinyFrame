
#include "lwHTTPClient.h"
#include "lwUtil.h"

@interface HTTPCallback : NSObject<NSURLConnectionDelegate> {
    lw::HTTPMsg *pMsg;
}
- (id)initWithMsg:(lw::HTTPMsg*)p;
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
		[(HTTPCallback*)_pObjCCallback release];
	}

	void HTTPMsg::send(){
		_pClient->sendMsg(this, _useHTTPS);
	}
    
    void HTTPMsg::addParam(const char* param){
        _buff.append(param);
    }
    
    HTTPClient::HTTPClient(const char* host)
    :_httpsEnable(true){
		_strHost = host;
	}

	HTTPClient::~HTTPClient(){
		
	}

	void HTTPClient::sendMsg(HTTPMsg* pMsg, bool useHTTPS){
        std::stringstream ss;
		const char* routeparam = pMsg->getBuff().c_str();
        if ( useHTTPS && _httpsEnable ){
            ss << "https://" << _strHost.c_str() << routeparam;
        }else{
            ss << "http://" << _strHost.c_str() << routeparam;
        }
        NSString* urlString=[[NSString alloc] initWithUTF8String:ss.str().c_str()];
        NSURL* url=[[NSURL alloc] initWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSURLRequest *theRequest=[NSURLRequest requestWithURL:url
                                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                              timeoutInterval:60.0];
        // create the connection with the request
        // and start loading the data
        HTTPCallback* pCallback = [[HTTPCallback alloc] initWithMsg:pMsg];
        NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:pCallback];
        if (!theConnection) {
            pMsg->onRespond(LWHTTPERR_CONNECTION);
            delete pMsg;
        }
        [urlString release];
        [url release];
	}
	
} //namespace lw

@implementation HTTPCallback
- (id)initWithMsg:(lw::HTTPMsg*)p
{
    if ( self =[super init] ){
        pMsg=p;
        pMsg->_pObjCCallback=self;
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    pMsg->getBuff().clear();
    if ( lw::_pHTTPOKCallback ){
        lw::_pHTTPOKCallback();
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    pMsg->getBuff().append((char*)([data bytes]), [data length]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    pMsg->onRespond(LWHTTPERR_NONE);
    delete pMsg;
    [connection release];
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    lwerror("http error:" << [[error localizedDescription]UTF8String] << " from: " << pMsg->getBuff().c_str());
    if ( lw::_pHTTPErrorCallback ){
        lw::_pHTTPErrorCallback();
    }
    pMsg->onRespond(LWHTTPERR_NET);
    delete pMsg;
}

@end