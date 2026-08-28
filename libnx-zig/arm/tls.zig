pub inline fn armGetTls() *anyopaque {
    var ret: *anyopaque = undefined;
    asm volatile ("mrs %x[data], tpidrro_el0" : [data] "=r" (ret));
}