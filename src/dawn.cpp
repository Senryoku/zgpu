//#include "dawn/native/DawnNative.h"
//#include <assert.h>
//#include <stdio.h>

#include "webgpu.h"
#include <assert.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct DawnNativeInstanceImpl* DawnNativeInstance;

DawnNativeInstance dniCreate(void) {
//    return reinterpret_cast<DawnNativeInstance>(new dawn::native::Instance());
    return reinterpret_cast<DawnNativeInstance>(wgpuCreateInstance(nullptr));
}

void dniDestroy(DawnNativeInstance dni) {
    assert(dni);

//    delete reinterpret_cast<dawn::native::Instance*>(dni);
//    delete dni;
}

WGPUInstance dniGetWgpuInstance(DawnNativeInstance dni) {
    assert(dni);
//    return reinterpret_cast<dawn::native::Instance*>(dni)->Get();
    return reinterpret_cast<WGPUInstance>(dni);
}

//void dniDiscoverDefaultAdapters(DawnNativeInstance dni) {
//    assert(dni);
//    dawn::native::Instance* instance = reinterpret_cast<dawn::native::Instance*>(dni);
//    instance->DiscoverDefaultAdapters();
//}

const WGPUProc dnGetProcs(void) {
//    return &dawn::native::GetProcs();
    return wgpuGetProcAddress(WGPUStringView{"createInstance", 14});
}

#ifdef __cplusplus
}
#endif
