#ifndef _HDY_JOBTHREAD_H_HH_
#define _HDY_JOBTHREAD_H_HH_

#include <list>
#include <thread>
#include <mutex>
#include <condition_variable>

//#include "base/defines.h"

namespace dsdk {

class job_base
{
 public:
    job_base() {}
    virtual ~job_base() {}

    virtual void do_job() {};
    virtual int  hash() { return 0; }
};

class job_thread
{
    static void thread_proc(void* ctx);
 public:
    job_thread();
    virtual ~job_thread();

    void push_job(job_base* job);

    void end();
 private:
    void run();

 private:
    std::list<job_base*>    _jobs;
    std::mutex              _lock;
    std::condition_variable _cond;
    bool                    _running;
    std::thread             _thread;
};

}; //namespace
#endif //_HDY_JOBTHREAD_H_HH_

