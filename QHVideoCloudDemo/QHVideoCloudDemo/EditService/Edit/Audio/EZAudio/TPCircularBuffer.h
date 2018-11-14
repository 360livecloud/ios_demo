
#ifndef TPCircularBuffer_h
#define TPCircularBuffer_h

#include <libkern/OSAtomic.h>
#include <string.h>
#include <assert.h>

#ifdef __cplusplus
extern "C" {
#endif
    
typedef struct
    {
    void             *buffer;
    int32_t           length;
    int32_t           tail;
    int32_t           head;
    volatile int32_t  fillCount;
    bool              atomic;
} TPCircularBuffer;


#define TPCircularBufferInit(buffer, length) \
    _TPCircularBufferInit(buffer, length, sizeof(*buffer))
bool _TPCircularBufferInit(TPCircularBuffer *buffer, int32_t length, size_t structSize);


void  TPCircularBufferCleanup(TPCircularBuffer *buffer);


void  TPCircularBufferClear(TPCircularBuffer *buffer);
    

void  TPCircularBufferSetAtomic(TPCircularBuffer *buffer, bool atomic);

static __inline__ __attribute__((always_inline)) void* TPCircularBufferTail(TPCircularBuffer *buffer, int32_t* availableBytes) {
    *availableBytes = buffer->fillCount;
    if ( *availableBytes == 0 ) return NULL;
    return (void*)((char*)buffer->buffer + buffer->tail);
}

static __inline__ __attribute__((always_inline)) void TPCircularBufferConsume(TPCircularBuffer *buffer, int32_t amount) {
    buffer->tail = (buffer->tail + amount) % buffer->length;
    if ( buffer->atomic ) {
        OSAtomicAdd32Barrier(-amount, &buffer->fillCount);
    } else {
        buffer->fillCount -= amount;
    }
    assert(buffer->fillCount >= 0);
}

static __inline__ __attribute__((always_inline)) void* TPCircularBufferHead(TPCircularBuffer *buffer, int32_t* availableBytes) {
    *availableBytes = (buffer->length - buffer->fillCount);
    if ( *availableBytes == 0 ) return NULL;
    return (void*)((char*)buffer->buffer + buffer->head);
}
    

static __inline__ __attribute__((always_inline)) void TPCircularBufferProduce(TPCircularBuffer *buffer, int32_t amount) {
    buffer->head = (buffer->head + amount) % buffer->length;
    if ( buffer->atomic ) {
        OSAtomicAdd32Barrier(amount, &buffer->fillCount);
    } else {
        buffer->fillCount += amount;
    }
    assert(buffer->fillCount <= buffer->length);
}


static __inline__ __attribute__((always_inline)) bool TPCircularBufferProduceBytes(TPCircularBuffer *buffer, const void* src, int32_t len) {
    int32_t space;
    void *ptr = TPCircularBufferHead(buffer, &space);
    if ( space < len ) return false;
    memcpy(ptr, src, len);
    TPCircularBufferProduce(buffer, len);
    return true;
}


static __inline__ __attribute__((always_inline)) __deprecated_msg("use TPCircularBufferSetAtomic(false) and TPCircularBufferConsume instead")
void TPCircularBufferConsumeNoBarrier(TPCircularBuffer *buffer, int32_t amount) {
    buffer->tail = (buffer->tail + amount) % buffer->length;
    buffer->fillCount -= amount;
    assert(buffer->fillCount >= 0);
}

static __inline__ __attribute__((always_inline)) __deprecated_msg("use TPCircularBufferSetAtomic(false) and TPCircularBufferProduce instead")
void TPCircularBufferProduceNoBarrier(TPCircularBuffer *buffer, int32_t amount) {
    buffer->head = (buffer->head + amount) % buffer->length;
    buffer->fillCount += amount;
    assert(buffer->fillCount <= buffer->length);
}

#ifdef __cplusplus
}
#endif

#endif
