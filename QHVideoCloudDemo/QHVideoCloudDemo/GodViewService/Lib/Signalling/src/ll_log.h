#ifndef _HDY_DSDK_LL_LOG_H_HH_
#define _HDY_DSDK_LL_LOG_H_HH_

#include "ll_client.h"

namespace dsdk {

#define DBUG(log, ...)   if (log) log->print(LL_LOG_DEBUG, "[ll mqtt] " "DBUG: "  __VA_ARGS__)
#define INFO(log, ...)   if (log) log->print(LL_LOG_INFO,  "[ll mqtt] " "INFO: "  __VA_ARGS__)
#define WARN(log, ...)   if (log) log->print(LL_LOG_WARN,  "[ll mqtt] " "WARN: "  __VA_ARGS__)
#define FATAL(log, ...)  if (log) log->print(LL_LOG_FATAL, "[ll mqtt] " "FATAL: " __VA_ARGS__)

class ll_log
{
 public:
    ll_log() : _log_func(NULL) {}
    void init(ll_log_func func);
    void print(int type, const char* format, ...);

 private:
    ll_log_func _log_func;
};

} // namespace dsdk
#endif  // _HDY_DSDK_LL_LOG_H_HH_

