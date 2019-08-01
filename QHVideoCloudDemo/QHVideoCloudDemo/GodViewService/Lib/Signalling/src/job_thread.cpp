#include "job_thread.h"

namespace dsdk {

job_thread::job_thread()
    : _running(true),
      _thread(thread_proc, this)
{
}

job_thread::~job_thread()
{
    //_running = false;
    //if (_thread.joinable()) {
    //    _thread.join();
    //}
}

void job_thread::thread_proc(void* ctx)
{
    if (ctx) {
        job_thread* self = (job_thread*)ctx;
        self->run();
        delete self;
    }
}

void job_thread::run()
{
    while(1) {
        job_base* job = NULL;
        {
            std::unique_lock<std::mutex> lock(_lock);
            if (_jobs.size() <= 0) {
                if (!_running) {
                    break;
                }
                _cond.wait_for(lock, std::chrono::microseconds(500*1000));
            } else {
                job = _jobs.front();
                _jobs.pop_front();
            }
        }
        if (job) {
            job->do_job();
            delete job;
        }
    }
    _thread.detach();
}

void job_thread::push_job(job_base* job)
{
    std::unique_lock<std::mutex> lock(_lock);

    _jobs.push_back(job);
    _cond.notify_one();
}

void job_thread::end()
{
    _running = false;
}

}; //namespace

