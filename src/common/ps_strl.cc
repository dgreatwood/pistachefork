/*
 * SPDX-FileCopyrightText: 2024 Duncan Greatwood
 *
 * SPDX-License-Identifier: Apache-2.0
 */

// Defines a ps_strlcpy and ps_strlcat for OS that do not have strlcpy/strlcat
// natively, including Windows and (some) Linux

#include <pistache/ps_strl.h>

/* ------------------------------------------------------------------------- */

#if defined(_IS_WINDOWS) || defined(__linux__)

#include <string.h> // for memcpy

/* ------------------------------------------------------------------------- */

extern "C" size_t ps_strlcpy(char *dst, const char *src, size_t n)
{
    if ((!dst) || (!src) || (!n))
        return(0);

    if (n == 1)
    {
        dst[0] = 0;
        return(0);
    }

    size_t bytes_to_copy = (strlen(src)+1);
    if (bytes_to_copy > n)
    {
        bytes_to_copy = n-1;
        
        memcpy(dst, src, bytes_to_copy);
        dst[bytes_to_copy] = 0;
    }
    else
    {
        memcpy(dst, src, bytes_to_copy);
    }

    return(bytes_to_copy);
}

    
extern "C" size_t ps_strlcat(char *dst, const char *src, size_t n)
{
    if ((!dst) || (!src) || (n <= 1))
        return(0);

    size_t dst_len= strlen(dst);
    if ((n+1) <= dst_len)
        return(dst_len); // no space to add onto dst

    size_t len_added = ps_strlcpy(dst+dst_len, src, (n - dst_len));
    return(dst_len+len_added);
}

/* ------------------------------------------------------------------------- */

#endif // of #if defined(_IS_WINDOWS) || defined(__linux__)
