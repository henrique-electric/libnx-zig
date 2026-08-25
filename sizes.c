/*
 * sizes.c - dumps sizeof() for every real libnx struct/union relevant to
 * the libnx-zig port (libnx.zig / services.zig), grouped by source header.
 *
 * Purpose: ABI sanity check. Compare this output against the equivalent
 * @sizeOf(...) values on the Zig side for the same types - any mismatch
 * means the Zig struct's field layout doesn't match what the real,
 * devkitA64-built libnx.a actually expects (see the "ABI risk" section of
 * README.md).
 *
 * This is generated from libnx/include/switch/**\/*.h - it is NOT
 * hand-written, so re-run the extraction if libnx/ is updated.
 *
 * A few forward-declared types (VirtmemReservation, WaitableMethods, ...)
 * have no public struct body in the headers (opaque handles) - sizeof()
 * on those wouldn't compile, so they're intentionally left out; see the
 * comment above each such header's section below.
 *
 * Build (must use the real devkitA64 toolchain - struct layout is only
 * meaningful for the actual AArch64/newlib ABI that libnx.a was built
 * with; a host compiler's sizeof() is not guaranteed to match):
 *
 *   aarch64-none-elf-gcc -march=armv8-a -mtune=cortex-a57 -mtp=soft -fPIC \
 *     -D__SWITCH__ -I$DEVKITPRO/libnx/include -c sizes.c -o sizes.o
 *   aarch64-none-elf-gcc -specs=$DEVKITPRO/libnx/switch.specs \
 *     sizes.o -L$DEVKITPRO/libnx/lib -lnx -o sizes.elf
 *   elf2nro sizes.elf sizes.nro
 *
 * Then run sizes.nro (e.g. via nxlink -s to stream stdout back over the
 * network, or hbmenu on-console/emulator).
 */

#include <switch.h>
#include <stdio.h>

#include <sys/types>

int main(int argc, char** argv)
{
    (void)argc; (void)argv;

    printf("\n== libnx/include/switch/types.h ==\n");
    printf("  %-46s %zu\n", "Uuid (struct)", sizeof(Uuid));
    printf("  %-46s %zu\n", "UtilFloat3 (struct)", sizeof(UtilFloat3));

    printf("\n== libnx/include/switch/kernel/rwlock.h ==\n");
    printf("  %-46s %zu\n", "RwLock (struct)", sizeof(RwLock));

    printf("\n== libnx/include/switch/kernel/semaphore.h ==\n");
    printf("  %-46s %zu\n", "Semaphore (struct)", sizeof(Semaphore));

    printf("\n== libnx/include/switch/kernel/barrier.h ==\n");
    printf("  %-46s %zu\n", "Barrier (struct)", sizeof(Barrier));

    printf("\n== libnx/include/switch/kernel/event.h ==\n");
    printf("  %-46s %zu\n", "Event (struct)", sizeof(Event));

    printf("\n== libnx/include/switch/kernel/levent.h ==\n");
    printf("  %-46s %zu\n", "LEvent (struct)", sizeof(LEvent));

    printf("\n== libnx/include/switch/kernel/uevent.h ==\n");
    printf("  %-46s %zu\n", "UEvent (struct)", sizeof(UEvent));

    printf("\n== libnx/include/switch/kernel/wait.h ==\n");
    printf("  %-46s %zu\n", "Waiter (struct)", sizeof(Waiter));
    printf("  %-46s %zu\n", "Waitable (struct)", sizeof(Waitable));
    printf("  %-46s %zu\n", "WaitableNode (struct)", sizeof(WaitableNode));
    /* opaque, no body in header - sizeof() not possible: WaitableMethods */

    printf("\n== libnx/include/switch/kernel/thread.h ==\n");
    printf("  %-46s %zu\n", "Thread (struct)", sizeof(Thread));

    printf("\n== libnx/include/switch/kernel/tmem.h ==\n");
    printf("  %-46s %zu\n", "TransferMemory (struct)", sizeof(TransferMemory));

    printf("\n== libnx/include/switch/kernel/shmem.h ==\n");
    printf("  %-46s %zu\n", "SharedMemory (struct)", sizeof(SharedMemory));

    printf("\n== libnx/include/switch/kernel/jit.h ==\n");
    printf("  %-46s %zu\n", "Jit (struct)", sizeof(Jit));

    printf("\n== libnx/include/switch/kernel/virtmem.h ==\n");
    /* opaque, no body in header - sizeof() not possible: VirtmemReservation */

    printf("\n== libnx/include/switch/kernel/svc.h ==\n");
    printf("  %-46s %zu\n", "MemoryInfo (struct)", sizeof(MemoryInfo));
    printf("  %-46s %zu\n", "PhysicalMemoryInfo (struct)", sizeof(PhysicalMemoryInfo));
    printf("  %-46s %zu\n", "SecmonArgs (struct)", sizeof(SecmonArgs));
    printf("  %-46s %zu\n", "LastThreadContext (struct)", sizeof(LastThreadContext));
    printf("  %-46s %zu\n", "CreateProcessFlags (struct)", sizeof(CreateProcessFlags));
    printf("  %-46s %zu\n", "DebugEventInfo (struct)", sizeof(DebugEventInfo));

    printf("\n== libnx/include/switch/display/types.h ==\n");
    printf("  %-46s %zu\n", "NativeHandle (struct)", sizeof(NativeHandle));

    printf("\n== libnx/include/switch/display/native_window.h ==\n");
    printf("  %-46s %zu\n", "NWindow (struct)", sizeof(NWindow));

    printf("\n== libnx/include/switch/display/framebuffer.h ==\n");
    printf("  %-46s %zu\n", "Framebuffer (struct)", sizeof(Framebuffer));

    printf("\n== libnx/include/switch/display/buffer_producer.h ==\n");
    printf("  %-46s %zu\n", "BqRect (struct)", sizeof(BqRect));
    printf("  %-46s %zu\n", "BqBufferInput (struct)", sizeof(BqBufferInput));
    printf("  %-46s %zu\n", "BqBufferOutput (struct)", sizeof(BqBufferOutput));
    printf("  %-46s %zu\n", "BqGraphicBuffer (struct)", sizeof(BqGraphicBuffer));

    printf("\n== libnx/include/switch/display/binder.h ==\n");
    printf("  %-46s %zu\n", "Binder (struct)", sizeof(Binder));

    printf("\n== libnx/include/switch/display/parcel.h ==\n");
    printf("  %-46s %zu\n", "ParcelHeader (struct)", sizeof(ParcelHeader));
    printf("  %-46s %zu\n", "Parcel (struct)", sizeof(Parcel));

    printf("\n== libnx/include/switch/nvidia/address_space.h ==\n");
    printf("  %-46s %zu\n", "NvAddressSpace (struct)", sizeof(NvAddressSpace));

    printf("\n== libnx/include/switch/nvidia/channel.h ==\n");
    printf("  %-46s %zu\n", "NvChannel (struct)", sizeof(NvChannel));

    printf("\n== libnx/include/switch/nvidia/fence.h ==\n");
    printf("  %-46s %zu\n", "NvMultiFence (struct)", sizeof(NvMultiFence));

    printf("\n== libnx/include/switch/nvidia/gpu_channel.h ==\n");
    printf("  %-46s %zu\n", "NvGpuChannel (struct)", sizeof(NvGpuChannel));

    printf("\n== libnx/include/switch/nvidia/ioctl.h ==\n");
    printf("  %-46s %zu\n", "nvioctl_zcull_info (struct)", sizeof(nvioctl_zcull_info));
    printf("  %-46s %zu\n", "nvioctl_zbc_entry (struct)", sizeof(nvioctl_zbc_entry));
    printf("  %-46s %zu\n", "nvioctl_gpu_characteristics (struct)", sizeof(nvioctl_gpu_characteristics));
    printf("  %-46s %zu\n", "nvioctl_va_region (struct)", sizeof(nvioctl_va_region));
    printf("  %-46s %zu\n", "nvioctl_zbc_slot_mask (struct)", sizeof(nvioctl_zbc_slot_mask));
    printf("  %-46s %zu\n", "nvioctl_gpu_time (struct)", sizeof(nvioctl_gpu_time));
    printf("  %-46s %zu\n", "nvioctl_fence (struct)", sizeof(nvioctl_fence));
    printf("  %-46s %zu\n", "nvioctl_gpfifo_entry (struct)", sizeof(nvioctl_gpfifo_entry));
    printf("  %-46s %zu\n", "nvioctl_cmdbuf (struct)", sizeof(nvioctl_cmdbuf));
    printf("  %-46s %zu\n", "nvioctl_reloc (struct)", sizeof(nvioctl_reloc));
    printf("  %-46s %zu\n", "nvioctl_reloc_shift (struct)", sizeof(nvioctl_reloc_shift));
    printf("  %-46s %zu\n", "nvioctl_syncpt_incr (struct)", sizeof(nvioctl_syncpt_incr));
    printf("  %-46s %zu\n", "nvioctl_command_buffer_map (struct)", sizeof(nvioctl_command_buffer_map));
    printf("  %-46s %zu\n", "nvioctl_clk_rate (struct)", sizeof(nvioctl_clk_rate));
    printf("  %-46s %zu\n", "NvNotification (struct)", sizeof(NvNotification));
    printf("  %-46s %zu\n", "NvError (struct)", sizeof(NvError));

    printf("\n== libnx/include/switch/nvidia/map.h ==\n");
    printf("  %-46s %zu\n", "NvMap (struct)", sizeof(NvMap));

    printf("\n== libnx/include/switch/nvidia/graphic_buffer.h ==\n");
    printf("  %-46s %zu\n", "NvSurface (struct)", sizeof(NvSurface));
    printf("  %-46s %zu\n", "NvGraphicBuffer (struct)", sizeof(NvGraphicBuffer));

    printf("\n== libnx/include/switch/services/hid.h ==\n");
    printf("  %-46s %zu\n", "HidAnalogStickState (struct)", sizeof(HidAnalogStickState));
    printf("  %-46s %zu\n", "HidVector (struct)", sizeof(HidVector));
    printf("  %-46s %zu\n", "HidDirectionState (struct)", sizeof(HidDirectionState));
    printf("  %-46s %zu\n", "HidCommonLifoHeader (struct)", sizeof(HidCommonLifoHeader));
    printf("  %-46s %zu\n", "HidDebugPadState (struct)", sizeof(HidDebugPadState));
    printf("  %-46s %zu\n", "HidDebugPadStateAtomicStorage (struct)", sizeof(HidDebugPadStateAtomicStorage));
    printf("  %-46s %zu\n", "HidDebugPadLifo (struct)", sizeof(HidDebugPadLifo));
    printf("  %-46s %zu\n", "HidDebugPadSharedMemoryFormat (struct)", sizeof(HidDebugPadSharedMemoryFormat));
    printf("  %-46s %zu\n", "HidTouchState (struct)", sizeof(HidTouchState));
    printf("  %-46s %zu\n", "HidTouchScreenState (struct)", sizeof(HidTouchScreenState));
    printf("  %-46s %zu\n", "HidTouchScreenStateAtomicStorage (struct)", sizeof(HidTouchScreenStateAtomicStorage));
    printf("  %-46s %zu\n", "HidTouchScreenLifo (struct)", sizeof(HidTouchScreenLifo));
    printf("  %-46s %zu\n", "HidTouchScreenSharedMemoryFormat (struct)", sizeof(HidTouchScreenSharedMemoryFormat));
    printf("  %-46s %zu\n", "HidTouchScreenConfigurationForNx (struct)", sizeof(HidTouchScreenConfigurationForNx));
    printf("  %-46s %zu\n", "HidMouseState (struct)", sizeof(HidMouseState));
    printf("  %-46s %zu\n", "HidMouseStateAtomicStorage (struct)", sizeof(HidMouseStateAtomicStorage));
    printf("  %-46s %zu\n", "HidMouseLifo (struct)", sizeof(HidMouseLifo));
    printf("  %-46s %zu\n", "HidMouseSharedMemoryFormat (struct)", sizeof(HidMouseSharedMemoryFormat));
    printf("  %-46s %zu\n", "HidKeyboardState (struct)", sizeof(HidKeyboardState));
    printf("  %-46s %zu\n", "HidKeyboardStateAtomicStorage (struct)", sizeof(HidKeyboardStateAtomicStorage));
    printf("  %-46s %zu\n", "HidKeyboardLifo (struct)", sizeof(HidKeyboardLifo));
    printf("  %-46s %zu\n", "HidKeyboardSharedMemoryFormat (struct)", sizeof(HidKeyboardSharedMemoryFormat));
    printf("  %-46s %zu\n", "HidBasicXpadState (struct)", sizeof(HidBasicXpadState));
    printf("  %-46s %zu\n", "HidBasicXpadStateAtomicStorage (struct)", sizeof(HidBasicXpadStateAtomicStorage));
    printf("  %-46s %zu\n", "HidBasicXpadLifo (struct)", sizeof(HidBasicXpadLifo));
    printf("  %-46s %zu\n", "HidBasicXpadSharedMemoryEntry (struct)", sizeof(HidBasicXpadSharedMemoryEntry));
    printf("  %-46s %zu\n", "HidBasicXpadSharedMemoryFormat (struct)", sizeof(HidBasicXpadSharedMemoryFormat));
    printf("  %-46s %zu\n", "HidDigitizerState (struct)", sizeof(HidDigitizerState));
    printf("  %-46s %zu\n", "HidDigitizerStateAtomicStorage (struct)", sizeof(HidDigitizerStateAtomicStorage));
    printf("  %-46s %zu\n", "HidDigitizerLifo (struct)", sizeof(HidDigitizerLifo));
    printf("  %-46s %zu\n", "HidDigitizerSharedMemoryFormat (struct)", sizeof(HidDigitizerSharedMemoryFormat));
    printf("  %-46s %zu\n", "HidHomeButtonState (struct)", sizeof(HidHomeButtonState));
    printf("  %-46s %zu\n", "HidHomeButtonStateAtomicStorage (struct)", sizeof(HidHomeButtonStateAtomicStorage));
    printf("  %-46s %zu\n", "HidHomeButtonLifo (struct)", sizeof(HidHomeButtonLifo));
    printf("  %-46s %zu\n", "HidHomeButtonSharedMemoryFormat (struct)", sizeof(HidHomeButtonSharedMemoryFormat));
    printf("  %-46s %zu\n", "HidSleepButtonState (struct)", sizeof(HidSleepButtonState));
    printf("  %-46s %zu\n", "HidSleepButtonStateAtomicStorage (struct)", sizeof(HidSleepButtonStateAtomicStorage));
    printf("  %-46s %zu\n", "HidSleepButtonLifo (struct)", sizeof(HidSleepButtonLifo));
    printf("  %-46s %zu\n", "HidSleepButtonSharedMemoryFormat (struct)", sizeof(HidSleepButtonSharedMemoryFormat));
    printf("  %-46s %zu\n", "HidCaptureButtonState (struct)", sizeof(HidCaptureButtonState));
    printf("  %-46s %zu\n", "HidCaptureButtonStateAtomicStorage (struct)", sizeof(HidCaptureButtonStateAtomicStorage));
    printf("  %-46s %zu\n", "HidCaptureButtonLifo (struct)", sizeof(HidCaptureButtonLifo));
    printf("  %-46s %zu\n", "HidCaptureButtonSharedMemoryFormat (struct)", sizeof(HidCaptureButtonSharedMemoryFormat));
    printf("  %-46s %zu\n", "HidInputDetectorState (struct)", sizeof(HidInputDetectorState));
    printf("  %-46s %zu\n", "HidInputDetectorStateAtomicStorage (struct)", sizeof(HidInputDetectorStateAtomicStorage));
    printf("  %-46s %zu\n", "HidInputDetectorLifo (struct)", sizeof(HidInputDetectorLifo));
    printf("  %-46s %zu\n", "HidInputDetectorSharedMemoryEntry (struct)", sizeof(HidInputDetectorSharedMemoryEntry));
    printf("  %-46s %zu\n", "HidInputDetectorSharedMemoryFormat (struct)", sizeof(HidInputDetectorSharedMemoryFormat));
    printf("  %-46s %zu\n", "HidUniquePadConfigMutex (struct)", sizeof(HidUniquePadConfigMutex));
    printf("  %-46s %zu\n", "HidSixAxisSensorUserCalibrationState (struct)", sizeof(HidSixAxisSensorUserCalibrationState));
    printf("  %-46s %zu\n", "HidSixAxisSensorUserCalibrationStateAtomicStorage (struct)", sizeof(HidSixAxisSensorUserCalibrationStateAtomicStorage));
    printf("  %-46s %zu\n", "HidSixAxisSensorUserCalibrationStateLifo (struct)", sizeof(HidSixAxisSensorUserCalibrationStateLifo));
    printf("  %-46s %zu\n", "HidAnalogStickCalibrationStateImpl (struct)", sizeof(HidAnalogStickCalibrationStateImpl));
    printf("  %-46s %zu\n", "HidAnalogStickCalibrationStateImplAtomicStorage (struct)", sizeof(HidAnalogStickCalibrationStateImplAtomicStorage));
    printf("  %-46s %zu\n", "HidAnalogStickCalibrationStateImplLifo (struct)", sizeof(HidAnalogStickCalibrationStateImplLifo));
    printf("  %-46s %zu\n", "HidUniquePadConfig (struct)", sizeof(HidUniquePadConfig));
    printf("  %-46s %zu\n", "HidUniquePadConfigAtomicStorage (struct)", sizeof(HidUniquePadConfigAtomicStorage));
    printf("  %-46s %zu\n", "HidUniquePadConfigLifo (struct)", sizeof(HidUniquePadConfigLifo));
    printf("  %-46s %zu\n", "HidUniquePadLifo (struct)", sizeof(HidUniquePadLifo));
    printf("  %-46s %zu\n", "HidUniquePadSharedMemoryEntry (struct)", sizeof(HidUniquePadSharedMemoryEntry));
    printf("  %-46s %zu\n", "HidUniquePadSharedMemoryFormat (struct)", sizeof(HidUniquePadSharedMemoryFormat));
    printf("  %-46s %zu\n", "HidNpadControllerColor (struct)", sizeof(HidNpadControllerColor));
    printf("  %-46s %zu\n", "HidNpadFullKeyColorState (struct)", sizeof(HidNpadFullKeyColorState));
    printf("  %-46s %zu\n", "HidNpadJoyColorState (struct)", sizeof(HidNpadJoyColorState));
    printf("  %-46s %zu\n", "HidNpadCommonState (struct)", sizeof(HidNpadCommonState));
    printf("  %-46s %zu\n", "HidNpadGcState (struct)", sizeof(HidNpadGcState));
    printf("  %-46s %zu\n", "HidNpadLarkState (struct)", sizeof(HidNpadLarkState));
    printf("  %-46s %zu\n", "HidNpadHandheldLarkState (struct)", sizeof(HidNpadHandheldLarkState));
    printf("  %-46s %zu\n", "HidNpadLuciaState (struct)", sizeof(HidNpadLuciaState));
    printf("  %-46s %zu\n", "HidNpadCommonStateAtomicStorage (struct)", sizeof(HidNpadCommonStateAtomicStorage));
    printf("  %-46s %zu\n", "HidNpadCommonLifo (struct)", sizeof(HidNpadCommonLifo));
    printf("  %-46s %zu\n", "HidNpadGcTriggerState (struct)", sizeof(HidNpadGcTriggerState));
    printf("  %-46s %zu\n", "HidNpadGcTriggerStateAtomicStorage (struct)", sizeof(HidNpadGcTriggerStateAtomicStorage));
    printf("  %-46s %zu\n", "HidNpadGcTriggerLifo (struct)", sizeof(HidNpadGcTriggerLifo));
    printf("  %-46s %zu\n", "HidSixAxisSensorState (struct)", sizeof(HidSixAxisSensorState));
    printf("  %-46s %zu\n", "HidSixAxisSensorStateAtomicStorage (struct)", sizeof(HidSixAxisSensorStateAtomicStorage));
    printf("  %-46s %zu\n", "HidNpadSixAxisSensorLifo (struct)", sizeof(HidNpadSixAxisSensorLifo));
    printf("  %-46s %zu\n", "HidNpadSystemProperties (struct)", sizeof(HidNpadSystemProperties));
    printf("  %-46s %zu\n", "HidNpadSystemButtonProperties (struct)", sizeof(HidNpadSystemButtonProperties));
    printf("  %-46s %zu\n", "HidPowerInfo (struct)", sizeof(HidPowerInfo));
    printf("  %-46s %zu\n", "XcdDeviceHandle (struct)", sizeof(XcdDeviceHandle));
    printf("  %-46s %zu\n", "HidNfcXcdDeviceHandleStateImpl (struct)", sizeof(HidNfcXcdDeviceHandleStateImpl));
    printf("  %-46s %zu\n", "HidNfcXcdDeviceHandleStateImplAtomicStorage (struct)", sizeof(HidNfcXcdDeviceHandleStateImplAtomicStorage));
    printf("  %-46s %zu\n", "HidNfcXcdDeviceHandleState (struct)", sizeof(HidNfcXcdDeviceHandleState));
    printf("  %-46s %zu\n", "HidNpadInternalState (struct)", sizeof(HidNpadInternalState));
    printf("  %-46s %zu\n", "HidNpadSharedMemoryEntry (struct)", sizeof(HidNpadSharedMemoryEntry));
    printf("  %-46s %zu\n", "HidNpadSharedMemoryFormat (struct)", sizeof(HidNpadSharedMemoryFormat));
    printf("  %-46s %zu\n", "HidGesturePoint (struct)", sizeof(HidGesturePoint));
    printf("  %-46s %zu\n", "HidGestureState (struct)", sizeof(HidGestureState));
    printf("  %-46s %zu\n", "HidGestureDummyStateAtomicStorage (struct)", sizeof(HidGestureDummyStateAtomicStorage));
    printf("  %-46s %zu\n", "HidGestureLifo (struct)", sizeof(HidGestureLifo));
    printf("  %-46s %zu\n", "HidGestureSharedMemoryFormat (struct)", sizeof(HidGestureSharedMemoryFormat));
    printf("  %-46s %zu\n", "HidConsoleSixAxisSensor (struct)", sizeof(HidConsoleSixAxisSensor));
    printf("  %-46s %zu\n", "HidSharedMemory (struct)", sizeof(HidSharedMemory));
    printf("  %-46s %zu\n", "HidSevenSixAxisSensorState (struct)", sizeof(HidSevenSixAxisSensorState));
    printf("  %-46s %zu\n", "HidSevenSixAxisSensorStateEntry (struct)", sizeof(HidSevenSixAxisSensorStateEntry));
    printf("  %-46s %zu\n", "HidSevenSixAxisSensorStates (struct)", sizeof(HidSevenSixAxisSensorStates));
    printf("  %-46s %zu\n", "HidSixAxisSensorHandle (union)", sizeof(HidSixAxisSensorHandle));
    printf("  %-46s %zu\n", "HidVibrationDeviceHandle (union)", sizeof(HidVibrationDeviceHandle));
    printf("  %-46s %zu\n", "HidVibrationDeviceInfo (struct)", sizeof(HidVibrationDeviceInfo));
    printf("  %-46s %zu\n", "HidVibrationValue (struct)", sizeof(HidVibrationValue));
    printf("  %-46s %zu\n", "HidPalmaConnectionHandle (struct)", sizeof(HidPalmaConnectionHandle));
    printf("  %-46s %zu\n", "HidPalmaOperationInfo (struct)", sizeof(HidPalmaOperationInfo));
    printf("  %-46s %zu\n", "HidPalmaApplicationSectionAccessBuffer (struct)", sizeof(HidPalmaApplicationSectionAccessBuffer));
    printf("  %-46s %zu\n", "HidPalmaActivityEntry (struct)", sizeof(HidPalmaActivityEntry));

    printf("\n== libnx/include/switch/services/set.h ==\n");
    printf("  %-46s %zu\n", "SetBatteryLot (struct)", sizeof(SetBatteryLot));
    printf("  %-46s %zu\n", "SetSysNetworkSettings (struct)", sizeof(SetSysNetworkSettings));
    printf("  %-46s %zu\n", "SetSysLcdBacklightBrightnessMapping (struct)", sizeof(SetSysLcdBacklightBrightnessMapping));
    printf("  %-46s %zu\n", "SetSysBacklightSettings (struct)", sizeof(SetSysBacklightSettings));
    printf("  %-46s %zu\n", "SetSysBacklightSettingsEx (struct)", sizeof(SetSysBacklightSettingsEx));
    printf("  %-46s %zu\n", "SetSysBluetoothDevicesSettings (struct)", sizeof(SetSysBluetoothDevicesSettings));
    printf("  %-46s %zu\n", "SetSysFirmwareVersion (struct)", sizeof(SetSysFirmwareVersion));
    printf("  %-46s %zu\n", "SetSysFirmwareVersionDigest (struct)", sizeof(SetSysFirmwareVersionDigest));
    printf("  %-46s %zu\n", "SetSysSerialNumber (struct)", sizeof(SetSysSerialNumber));
    printf("  %-46s %zu\n", "SetSysDeviceNickName (struct)", sizeof(SetSysDeviceNickName));
    printf("  %-46s %zu\n", "SetSysUserSelectorSettings (struct)", sizeof(SetSysUserSelectorSettings));
    printf("  %-46s %zu\n", "SetSysAccountSettings (struct)", sizeof(SetSysAccountSettings));
    printf("  %-46s %zu\n", "SetSysAudioVolume (struct)", sizeof(SetSysAudioVolume));
    printf("  %-46s %zu\n", "SetSysEulaVersion (struct)", sizeof(SetSysEulaVersion));
    printf("  %-46s %zu\n", "SetSysNotificationTime (struct)", sizeof(SetSysNotificationTime));
    printf("  %-46s %zu\n", "SetSysNotificationSettings (struct)", sizeof(SetSysNotificationSettings));
    printf("  %-46s %zu\n", "SetSysAccountNotificationSettings (struct)", sizeof(SetSysAccountNotificationSettings));
    printf("  %-46s %zu\n", "SetSysTvSettings (struct)", sizeof(SetSysTvSettings));
    printf("  %-46s %zu\n", "SetSysModeLine (struct)", sizeof(SetSysModeLine));
    printf("  %-46s %zu\n", "SetSysDataBlock (struct)", sizeof(SetSysDataBlock));
    printf("  %-46s %zu\n", "SetSysExtensionBlock (struct)", sizeof(SetSysExtensionBlock));
    printf("  %-46s %zu\n", "SetSysEdid (struct)", sizeof(SetSysEdid));
    printf("  %-46s %zu\n", "SetSysDataDeletionSettings (struct)", sizeof(SetSysDataDeletionSettings));
    printf("  %-46s %zu\n", "SetSysSleepSettings (struct)", sizeof(SetSysSleepSettings));
    printf("  %-46s %zu\n", "SetSysInitialLaunchSettings (struct)", sizeof(SetSysInitialLaunchSettings));
    printf("  %-46s %zu\n", "SetSysPtmFuelGaugeParameter (struct)", sizeof(SetSysPtmFuelGaugeParameter));
    printf("  %-46s %zu\n", "SetSysColor4u8Type (struct)", sizeof(SetSysColor4u8Type));
    printf("  %-46s %zu\n", "SetSysNxControllerLegacySettings (struct)", sizeof(SetSysNxControllerLegacySettings));
    printf("  %-46s %zu\n", "SetSysNxControllerSettings (struct)", sizeof(SetSysNxControllerSettings));
    printf("  %-46s %zu\n", "SetSysConsoleSixAxisSensorAccelerationBias (struct)", sizeof(SetSysConsoleSixAxisSensorAccelerationBias));
    printf("  %-46s %zu\n", "SetSysConsoleSixAxisSensorAngularVelocityBias (struct)", sizeof(SetSysConsoleSixAxisSensorAngularVelocityBias));
    printf("  %-46s %zu\n", "SetSysConsoleSixAxisSensorAccelerationGain (struct)", sizeof(SetSysConsoleSixAxisSensorAccelerationGain));
    printf("  %-46s %zu\n", "SetSysConsoleSixAxisSensorAngularVelocityGain (struct)", sizeof(SetSysConsoleSixAxisSensorAngularVelocityGain));
    printf("  %-46s %zu\n", "SetSysAllowedSslHosts (struct)", sizeof(SetSysAllowedSslHosts));
    printf("  %-46s %zu\n", "SetSysHostFsMountPoint (struct)", sizeof(SetSysHostFsMountPoint));
    printf("  %-46s %zu\n", "SetSysBlePairingSettings (struct)", sizeof(SetSysBlePairingSettings));
    printf("  %-46s %zu\n", "SetSysConsoleSixAxisSensorAngularVelocityTimeBias (struct)", sizeof(SetSysConsoleSixAxisSensorAngularVelocityTimeBias));
    printf("  %-46s %zu\n", "SetSysConsoleSixAxisSensorAngularAcceleration (struct)", sizeof(SetSysConsoleSixAxisSensorAngularAcceleration));
    printf("  %-46s %zu\n", "SetSysRebootlessSystemUpdateVersion (struct)", sizeof(SetSysRebootlessSystemUpdateVersion));
    printf("  %-46s %zu\n", "SetSysAccountOnlineStorageSettings (struct)", sizeof(SetSysAccountOnlineStorageSettings));
    printf("  %-46s %zu\n", "SetSysAnalogStickUserCalibration (struct)", sizeof(SetSysAnalogStickUserCalibration));
    printf("  %-46s %zu\n", "SetSysThemeId (struct)", sizeof(SetSysThemeId));
    printf("  %-46s %zu\n", "SetSysThemeSettings (struct)", sizeof(SetSysThemeSettings));
    printf("  %-46s %zu\n", "SetSysHomeMenuScheme (struct)", sizeof(SetSysHomeMenuScheme));
    printf("  %-46s %zu\n", "SetSysButtonConfigSettings (struct)", sizeof(SetSysButtonConfigSettings));
    printf("  %-46s %zu\n", "SetSysButtonConfigRegisteredSettings (struct)", sizeof(SetSysButtonConfigRegisteredSettings));
    printf("  %-46s %zu\n", "SetCalAccelerometerOffset (struct)", sizeof(SetCalAccelerometerOffset));
    printf("  %-46s %zu\n", "SetCalAccelerometerScale (struct)", sizeof(SetCalAccelerometerScale));
    printf("  %-46s %zu\n", "SetCalAmiiboEcdsaCertificate (struct)", sizeof(SetCalAmiiboEcdsaCertificate));
    printf("  %-46s %zu\n", "SetCalAmiiboEcqvBlsCertificate (struct)", sizeof(SetCalAmiiboEcqvBlsCertificate));
    printf("  %-46s %zu\n", "SetCalAmiiboEcqvBlsKey (struct)", sizeof(SetCalAmiiboEcqvBlsKey));
    printf("  %-46s %zu\n", "SetCalAmiiboEcqvBlsRootCertificate (struct)", sizeof(SetCalAmiiboEcqvBlsRootCertificate));
    printf("  %-46s %zu\n", "SetCalAmiiboEcqvCertificate (struct)", sizeof(SetCalAmiiboEcqvCertificate));
    printf("  %-46s %zu\n", "SetCalAmiiboKey (struct)", sizeof(SetCalAmiiboKey));
    printf("  %-46s %zu\n", "SetCalAnalogStickFactoryCalibration (struct)", sizeof(SetCalAnalogStickFactoryCalibration));
    printf("  %-46s %zu\n", "SetCalAnalogStickModelParameter (struct)", sizeof(SetCalAnalogStickModelParameter));
    printf("  %-46s %zu\n", "SetCalBdAddress (struct)", sizeof(SetCalBdAddress));
    printf("  %-46s %zu\n", "SetCalConfigurationId1 (struct)", sizeof(SetCalConfigurationId1));
    printf("  %-46s %zu\n", "SetCalConsoleSixAxisSensorHorizontalOffset (struct)", sizeof(SetCalConsoleSixAxisSensorHorizontalOffset));
    printf("  %-46s %zu\n", "SetCalCountryCode (struct)", sizeof(SetCalCountryCode));
    printf("  %-46s %zu\n", "SetCalEccB233DeviceCertificate (struct)", sizeof(SetCalEccB233DeviceCertificate));
    printf("  %-46s %zu\n", "SetCalEccB233DeviceKey (struct)", sizeof(SetCalEccB233DeviceKey));
    printf("  %-46s %zu\n", "SetCalGameCardCertificate (struct)", sizeof(SetCalGameCardCertificate));
    printf("  %-46s %zu\n", "SetCalGameCardKey (struct)", sizeof(SetCalGameCardKey));
    printf("  %-46s %zu\n", "SetCalGyroscopeOffset (struct)", sizeof(SetCalGyroscopeOffset));
    printf("  %-46s %zu\n", "SetCalGyroscopeScale (struct)", sizeof(SetCalGyroscopeScale));
    printf("  %-46s %zu\n", "SetCalMacAddress (struct)", sizeof(SetCalMacAddress));
    printf("  %-46s %zu\n", "SetCalRsa2048DeviceCertificate (struct)", sizeof(SetCalRsa2048DeviceCertificate));
    printf("  %-46s %zu\n", "SetCalRsa2048DeviceKey (struct)", sizeof(SetCalRsa2048DeviceKey));
    printf("  %-46s %zu\n", "SetCalSpeakerParameter (struct)", sizeof(SetCalSpeakerParameter));
    printf("  %-46s %zu\n", "SetCalSslCertificate (struct)", sizeof(SetCalSslCertificate));
    printf("  %-46s %zu\n", "SetCalSslKey (struct)", sizeof(SetCalSslKey));
    printf("  %-46s %zu\n", "SetCalRegionCode (struct)", sizeof(SetCalRegionCode));

    printf("\n== libnx/include/switch/services/pctl.h ==\n");
    printf("  %-46s %zu\n", "PctlRestrictionSettings (struct)", sizeof(PctlRestrictionSettings));

    printf("\n== libnx/include/switch/services/applet.h ==\n");
    printf("  %-46s %zu\n", "AppletLockAccessor (struct)", sizeof(AppletLockAccessor));
    printf("  %-46s %zu\n", "AppletStorage (struct)", sizeof(AppletStorage));
    printf("  %-46s %zu\n", "AppletHolder (struct)", sizeof(AppletHolder));
    printf("  %-46s %zu\n", "AppletApplication (struct)", sizeof(AppletApplication));
    printf("  %-46s %zu\n", "AppletGpuErrorHandler (struct)", sizeof(AppletGpuErrorHandler));
    printf("  %-46s %zu\n", "AppletAttribute (struct)", sizeof(AppletAttribute));
    printf("  %-46s %zu\n", "LibAppletInfo (struct)", sizeof(LibAppletInfo));
    printf("  %-46s %zu\n", "AppletProcessLaunchReason (struct)", sizeof(AppletProcessLaunchReason));
    printf("  %-46s %zu\n", "AppletInfo (struct)", sizeof(AppletInfo));
    printf("  %-46s %zu\n", "AppletIdentityInfo (struct)", sizeof(AppletIdentityInfo));
    printf("  %-46s %zu\n", "AppletApplicationAttributeForQuest (struct)", sizeof(AppletApplicationAttributeForQuest));
    printf("  %-46s %zu\n", "AppletApplicationAttribute (struct)", sizeof(AppletApplicationAttribute));
    printf("  %-46s %zu\n", "AppletApplicationLaunchProperty (struct)", sizeof(AppletApplicationLaunchProperty));
    printf("  %-46s %zu\n", "AppletApplicationLaunchRequestInfo (struct)", sizeof(AppletApplicationLaunchRequestInfo));
    printf("  %-46s %zu\n", "AppletResourceUsageInfo (struct)", sizeof(AppletResourceUsageInfo));
    printf("  %-46s %zu\n", "AppletHookCookie (struct)", sizeof(AppletHookCookie));

    printf("\n== libnx/include/switch/services/vi.h ==\n");
    printf("  %-46s %zu\n", "ViDisplayName (struct)", sizeof(ViDisplayName));
    printf("  %-46s %zu\n", "ViDisplay (struct)", sizeof(ViDisplay));
    printf("  %-46s %zu\n", "ViLayer (struct)", sizeof(ViLayer));

    return 0;
}
