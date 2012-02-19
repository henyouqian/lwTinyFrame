#ifndef __LW_HTTP_CLIENT_H__
#define __LW_HTTP_CLIENT_H__


namespace lw{
	
	class HttpMsgBuf{
	public:
		HttpMsgBuf(int initSize):_size(0), _buffSize(initSize){
			_buff = new char[initSize];
			_pRead = _buff;
		}
		~HttpMsgBuf(){
			delete [] _buff;
		}
		
		char* getBuff(){
			return _buff;
		}
		int getSize(){
			return _size;
		}
		int getBuffSize(){
			return _buffSize;
		}
		void reset(){
			_size = 0;
			_pRead = _buff;
		}

		void write(const char* p, int size);
		void writeChar(char c);
		void writeShort(short s);
		void writeInt(int n);
		void writeFloat(float f);
		void writeString(const wchar_t* str);
		void writeUtf8(const char* str);
		void writeBlob(const char* p, int size);
		void readReset();
		char readChar();
		short readShort();
		int readInt();
		float readFloat();
		const char* readString();
		void readBlob(const char*& pData, int& dataSize);

	private:
		char* _buff;
		int _buffSize;
		int _size;
		char* _pRead;
	};

	class HTTPClient;
	class HTTPMsg{
	public:
		HTTPMsg(const char* objName, lw::HTTPClient* pClient, bool useHTTPS = false);
		const char* getObjName(){
			return _objName.c_str();
		}
		HTTPClient* getClient(){
			return _pClient;
		}
        void addParam(const char* param);
		void send();
        void* _pObjCCallback;
		virtual void onRespond(){}
		
		HttpMsgBuf* getBuff(){
			return &_buff;
		}
		
		enum {
			BUFF_SIZE = 4096,
		};

	protected:
		virtual ~HTTPMsg();

	protected:
		HttpMsgBuf _buff;
		std::string _objName;
		HTTPClient* _pClient;
        bool _useHTTPS;

	friend class HTTPClient;
	};

	class HTTPClient{
	public:
        HTTPClient(const char* host);
		~HTTPClient();
		bool connect();
		void sendMsg(HTTPMsg* pMsg, bool useHTTPS);
		void deleteMsg(HTTPMsg* pMsg);
		void addToRespond(HTTPMsg* pMsg);
		void main();
        void enableHTTPS(bool b){
            _httpsEnable = b;
        }

	private:
		std::string _strHost;
		std::vector<HTTPMsg*> _msgs;
		std::vector<HTTPMsg*> _respondMsgs;
        bool _httpsEnable;
	};
    
} //namespace lw

#endif //__LW_HTTP_CLIENT_H__