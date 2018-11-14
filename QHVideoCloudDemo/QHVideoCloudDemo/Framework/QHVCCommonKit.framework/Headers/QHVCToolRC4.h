#ifndef QHVCTool_RC4_H_
#define QHVCTool_RC4_H_

typedef struct QHVCTool_RC4_KEY{
     unsigned char abyState[256];
     unsigned char byX;
     unsigned char byY;
}QHVCTool_RC4_KEY;

void QHVCTool_RC4_set_key(QHVCTool_RC4_KEY* key, int length, const void* pachKeyData);

void QHVCTool_RC4(QHVCTool_RC4_KEY *key, int length, const void* pachIn, void* pachOut);

#endif
