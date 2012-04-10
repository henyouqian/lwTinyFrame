#ifndef __LW_THREAD_H__
#define __LW_THREAD_H__

namespace lw {
    class Thread{
    public:
        Thread();
        virtual ~Thread();
        void startThread();
        virtual void vThreadMain() = 0;
        
    private:
        struct Data;
        Data* _pd;
    };
}

#endif //__LW_THREAD_H__