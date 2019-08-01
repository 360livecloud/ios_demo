// Copyright 2015, qihoo.net
// All rights reserved.
// Author: gengxiandong

#include <time.h>
#include <stdio.h>
#include <stdarg.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdint.h>

#if (defined(WIN32) || defined(WIN64))
#else
#include <unistd.h>
#endif
#include <string.h>

#include "ll_log.h"

namespace dsdk {

void ll_log::init(ll_log_func func)
{
    _log_func = func; 
}

void ll_log::print(int type, const char* fm, ...)
{
	int len = 0;
    char buff[8192] = {0};

    va_list pargs;
    va_start(pargs, fm);
    len += vsnprintf(buff + len, sizeof(buff) - len - 1, fm, pargs);
    va_end(pargs);

    if (_log_func) {
        _log_func(type, buff);
    } else {
        printf("%s", buff);
    }
}
}  // namespace dsdk
