package smart_ptr

import "core:sync"

SmartPtr :: struct($T: typeid) {
    data: ^T,
    ref_count: ^int,
    mutex: ^sync.Mutex,
}

make_smart_ptr :: proc($T: typeid, value: T) -> SmartPtr(T) {
    ptr := new(T)
    ptr^ = value

    return SmartPtr(T){
        data = ptr,
        ref_count = new_clone(1),
        mutex = new(sync.Mutex),
    }
}

clone :: proc(ptr: ^SmartPtr($T)) -> SmartPtr(T) {
    sync.mutex_lock(ptr.mutex)
    defer sync.mutex_unlock(ptr.mutex)

    ptr.ref_count^ += 1
    return ptr^
}

destroy :: proc(ptr: ^SmartPtr($T)) {
    sync.mutex_lock(ptr.mutex)
    defer sync.mutex_unlock(ptr.mutex)

    ptr.ref_count^ -= 1
    if ptr.ref_count^ == 0 {
        free(ptr.data)
        free(ptr.ref_count)
        free(ptr.mutex)
    }
}

get :: proc(ptr: ^SmartPtr($T)) -> ^T {
    return ptr.data
}

// Example usage:
/*
main :: proc() {
    ptr := make_smart_ptr(int, 42)
    defer destroy(&ptr)

    ptr2 := clone(&ptr)
    defer destroy(&ptr2)

    value := get(&ptr)^
    fmt.println(value) // 42
}
*/