#ifdef HAVE_OPENSSL
#include <openssl/md5.h>
#else
#ifndef __WINDMILL__MD5__H__
#define __WINDMILL__MD5__H__
namespace gnet {
#ifdef __cplusplus
extern "C" {
#endif
/* Any 32-bit or wider unsigned integer data type will do */
typedef unsigned int MD5_u32plus;

typedef struct MD5_CTX {
    MD5_u32plus lo, hi;
    MD5_u32plus a, b, c, d;
    unsigned char buffer[64];
    MD5_u32plus block[16];
} MD5_CTX;

extern void MD5_Init(MD5_CTX *ctx);
extern void MD5_Update(MD5_CTX *ctx, const void *data, unsigned long size);
extern void MD5_Final(unsigned char *result, MD5_CTX *ctx);

#ifdef __cplusplus
}
#endif

}  // namespace gnet
#endif /* __WINDMILL__MD5__H__ */
#endif /* HAVE_OPENSSL */

