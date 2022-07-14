/* Capstone Disassembly Engine */
/* By Nguyen Anh Quynh <aquynh@gmail.com>, 2013-2014 */

#include <stdint.h>
#include <stdarg.h>
#if defined(CAPSTONE_HAS_OSXKERNEL)
#include <libkern/libkern.h>
#else
#include <stdio.h>
#endif
#include <string.h>

#include "SStream.h"
#include "cs_priv.h"
#include "myinttypes.h"
#include "utils.h"

#ifdef _MSC_VER
#pragma warning(disable: 4996) // disable MSVC's warning on strcpy()
#endif

void SStream_Init(SStream *ss)
{
	ss->index = 0;
	ss->buffer[0] = '\0';
}

void SStream_concat0(SStream *ss, char *s)
{
#ifndef CAPSTONE_DIET
	unsigned int len = (unsigned int) strlen(s);

	memcpy(ss->buffer + ss->index, s, len);
	ss->index += len;
	ss->buffer[ss->index] = '\0';
#endif
}

void SStream_concat(SStream *ss, const char *fmt, ...)
{
#ifndef CAPSTONE_DIET
	va_list ap;
	int ret;

	va_start(ap, fmt);
	ret = cs_vsnprintf(ss->buffer + ss->index, sizeof(ss->buffer) - (ss->index + 1), fmt, ap);
	va_end(ap);
	ss->index += ret;
#endif
}

// print number with prefix #
void printInt64Bang(SStream *O, int64_t val)
{
	if (val >= 0) {
		if (val > HEX_THRESHOLD)
			SStream_concat(O, "#0x%llx", val);
		else
			SStream_concat(O, "#%llu", val);
	} else {
		if (val <- HEX_THRESHOLD)
			SStream_concat(O, "#-0x%llx", -val);
		else
			SStream_concat(O, "#-%llu", -val);
	}
}

void printUInt64Bang(SStream *O, uint64_t val)
{
	if (val > HEX_THRESHOLD)
		SStream_concat(O, "#0x%llx", val);
	else
		SStream_concat(O, "#%llu", val);
}

// print number
void printInt64(SStream *O, int64_t val)
{
	if (val >= 0) {
		if (val > HEX_THRESHOLD)
			SStream_concat(O, "0x%llx", val);
		else
			SStream_concat(O, "%llu", val);
	} else {
		if (val <- HEX_THRESHOLD)
			SStream_concat(O, "-0x%llx", -val);
		else
			SStream_concat(O, "-%llu", -val);
	}
}

// print number in decimal mode
void printInt32BangDec(SStream *O, int32_t val)
{
	if (val >= 0)
		SStream_concat(O, "#%u", val);
	else
		SStream_concat(O, "#-%u", -val);
}

void printInt32Bang(SStream *O, int32_t val)
{
	if (val >= 0) {
		if (val > HEX_THRESHOLD)
			SStream_concat(O, "#0x%x", val);
		else
			SStream_concat(O, "#%u", val);
	} else {
		if (val <- HEX_THRESHOLD)
			SStream_concat(O, "#-0x%x", -val);
		else
			SStream_concat(O, "#-%u", -val);
	}
}

void printInt32(SStream *O, int32_t val)
{
	if (val >= 0) {
		if (val > HEX_THRESHOLD)
			SStream_concat(O, "0x%x", val);
		else
			SStream_concat(O, "%u", val);
	} else {
		if (val <- HEX_THRESHOLD)
			SStream_concat(O, "-0x%x", -val);
		else
			SStream_concat(O, "-%u", -val);
	}
}

void printUInt32Bang(SStream *O, uint32_t val)
{
	if (val > HEX_THRESHOLD)
		SStream_concat(O, "#0x%x", val);
	else
		SStream_concat(O, "#%u", val);
}

void printUInt32(SStream *O, uint32_t val)
{
	if (val > HEX_THRESHOLD)
		SStream_concat(O, "0x%x", val);
	else
		SStream_concat(O, "%u", val);
}

/*
   int main()
   {
   SStream ss;
   int64_t i;

   SStream_Init(&ss);

   SStream_concat(&ss, "hello ");
   SStream_concat(&ss, "%d - 0x%x", 200, 16);

   i = 123;
   SStream_concat(&ss, " + %ld", i);
   SStream_concat(&ss, "%s", "haaaaa");

   printf("%s\n", ss.buffer);

   return 0;
   }
 */
