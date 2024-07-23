/*
 * SPDX-FileCopyrightText: 2024 Duncan Greatwood
 *
 * SPDX-License-Identifier: Apache-2.0
 */

// Defines a getrusage in Windows

#include <pistache/pist_resource.h>

/* ------------------------------------------------------------------------- */

#ifdef _IS_WINDOWS

#include <minwinbase.h> // for FILETIME
#include <winnt.h> // for ULARGE_INTEGER
#include <memory.h> // memset
#include <processthreadsapi.h> // GetProcessTimes

/* ------------------------------------------------------------------------- */

// Reference: https://github.com/postgres/postgres/blob/7559d8ebfa11d98728e816f6b655582ce41150f3/src/port/getrusage.c

extern "C" int pist_getrusage(int who, struct PST_RUSAGE * rusage)
{
    FILETIME    starttime;
    FILETIME    exittime;
    FILETIME    kerneltime;
    FILETIME    usertime;
    ULARGE_INTEGER li;

    if (who != RUSAGE_SELF)
    {
        /* Only RUSAGE_SELF is supported in this implementation for now */
        errno = EINVAL;
        return -1;
    }

    if (rusage == (struct rusage *) NULL)
    {
        errno = EFAULT;
        return -1;
    }
    memset(rusage, 0, sizeof(struct rusage));
    if (GetProcessTimes(GetCurrentProcess(),
                        &starttime, &exittime, &kerneltime, &usertime) == 0)
    {
        errno = EINVAL;
        return -1;
    }

    /* Convert FILETIMEs (0.1 us) to struct timeval */
    memcpy(&li, &kerneltime, sizeof(FILETIME));
    li.QuadPart /= 10L;            /* Convert to microseconds */
    rusage->ru_stime.tv_sec = li.QuadPart / 1000000L;
    rusage->ru_stime.tv_usec = li.QuadPart % 1000000L;

    memcpy(&li, &usertime, sizeof(FILETIME));
    li.QuadPart /= 10L;            /* Convert to microseconds */
    rusage->ru_utime.tv_sec = li.QuadPart / 1000000L;
    rusage->ru_utime.tv_usec = li.QuadPart % 1000000L;
}



/* ------------------------------------------------------------------------- */

#endif // of ifdef _IS_WINDOWS