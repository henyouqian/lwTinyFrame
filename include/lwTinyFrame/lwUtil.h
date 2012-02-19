#ifndef __LW_UTIL_H__
#define __LW_UTIL_H__

namespace lw{
	
	void srand();

} //namespace lw

class W2UTF8
{
public:
	W2UTF8(const wchar_t* w);
	~W2UTF8();
	int size();
	const char* data();
	operator const char*();

private:
#ifdef __OBJC__
    NSString* _str;
#else
    wchar_t *_buffer;
    int _size;
#endif
};

class UTF82W
{
public:
	UTF82W(const char* c);
	~UTF82W();
	int size();
	const wchar_t* data();
	operator const wchar_t*();

private:
#ifdef __OBJC__
    NSString* _str;
#else
    wchar_t *_buffer;
    int _size;
#endif
};

#endif //__LW_UTIL_H__