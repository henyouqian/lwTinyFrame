#ifndef __LW_HTTP_CLIENT_H__
#define __LW_HTTP_CLIENT_H__

#define LWHTTPERR_NONE 0
#define LWHTTPERR_CONNECTION -1
#define LWHTTPERR_NET -2

namespace lw{
	
	class HTTPClient;
	class HTTPMsg{
	public:
		HTTPMsg(const char* route, lw::HTTPClient* pClient, bool useHTTPS = false);
        virtual ~HTTPMsg();
        void addParam(const char* param);
		void send();
		virtual void onRespond(int error){}
		HTTPClient* getClient(){
			return _pClient;
		}
        std::string& getBuff(){
            return _buff;
        }
        void* _pDelegate;

	protected:
		std::string _buff;
		HTTPClient* _pClient;
        bool _useHTTPS;

	friend class HTTPClient;
	};

	class HTTPClient{
	public:
        HTTPClient(const char* host, bool enableHTTPS = true);
		~HTTPClient();
        bool isHTTPSEnabled(){
            return _httpsEnable;
        }
        const char* getHost(){
            return _strHost.c_str();
        }

	private:
		std::string _strHost;
        bool _httpsEnable;
	};
    typedef void (*HTTPErrorCallback) (void);
    typedef void (*HTTPOKCallback) (void);
    void setHTTPErrorCallback(HTTPErrorCallback pCallback);
    void setHTTPOKCallback(HTTPOKCallback pCallback);
    
} //namespace lw

#endif //__LW_HTTP_CLIENT_H__