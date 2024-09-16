;;! target = "aarch64"
;;! test = "winch"
;;! flags = "-O static-memory-maximum-size=100 -O dynamic-memory-guard-size=0xffff"

(module
  (memory (export "memory") 17)
  (func (export "run") (param i32) (result i32 i32 i32)
    ;; Within the guard region.
    local.get 0
    i32.load offset=0
    ;; Also within the guard region, bounds check should GVN with previous.
    local.get 0
    i32.load offset=4

    ;; Outside the guard region, needs additional bounds checks.
    local.get 0
    i32.load offset=0x000fffff
  )
  (data (i32.const 0) "\45\00\00\00\a4\01\00\00")
  (data (i32.const 0x000fffff) "\39\05\00\00")
)
;; wasm[0]::function[0]:
;;       stp     x29, x30, [sp, #-0x10]!
;;       mov     x29, sp
;;       mov     x28, sp
;;       mov     x9, x0
;;       sub     sp, sp, #0x20
;;       mov     x28, sp
;;       stur    x0, [x28, #0x18]
;;       stur    x1, [x28, #0x10]
;;       stur    w2, [x28, #0xc]
;;       stur    x3, [x28]
;;       ldur    w0, [x28, #0xc]
;;       ldur    x1, [x9, #0x68]
;;       mov     w2, w0
;;       add     x2, x2, #4
;;       b.vs    #0x14c
;;   3c: cmp     x2, x1, uxtx
;;       b.hi    #0x150
;;   44: ldur    x3, [x9, #0x60]
;;       add     x3, x3, x0, uxtx
;;       mov     x16, #0
;;       mov     x4, x16
;;       cmp     x2, x1, uxtx
;;       b.ls    #0x64
;;       b       #0x60
;;   60: mov     x3, x4
;;       ldur    w0, [x3]
;;       ldur    w1, [x28, #0xc]
;;       ldur    x2, [x9, #0x68]
;;       mov     w3, w1
;;       add     x3, x3, #8
;;       b.vs    #0x154
;;   7c: cmp     x3, x2, uxtx
;;       b.hi    #0x158
;;   84: ldur    x4, [x9, #0x60]
;;       add     x4, x4, x1, uxtx
;;       add     x4, x4, #4
;;       mov     x16, #0
;;       mov     x5, x16
;;       cmp     x3, x2, uxtx
;;       b.ls    #0xa8
;;       b       #0xa4
;;   a4: mov     x4, x5
;;       ldur    w1, [x4]
;;       ldur    w2, [x28, #0xc]
;;       ldur    x3, [x9, #0x68]
;;       mov     w4, w2
;;       mov     w16, #3
;;       movk    w16, #0x10, lsl #16
;;       add     x4, x4, x16, uxtx
;;       b.vs    #0x15c
;;   c8: cmp     x4, x3, uxtx
;;       b.hi    #0x160
;;   d0: ldur    x5, [x9, #0x60]
;;       add     x5, x5, x2, uxtx
;;       orr     x16, xzr, #0xfffff
;;       add     x5, x5, x16, uxtx
;;       mov     x16, #0
;;       mov     x6, x16
;;       cmp     x4, x3, uxtx
;;       b.ls    #0xf8
;;       b       #0xf4
;;   f4: mov     x5, x6
;;       ldur    w2, [x5]
;;       sub     sp, sp, #4
;;       mov     x28, sp
;;       stur    w0, [x28]
;;       sub     sp, sp, #4
;;       mov     x28, sp
;;       stur    w1, [x28]
;;       mov     w0, w2
;;       ldur    x1, [x28, #8]
;;       ldur    w16, [x28]
;;       add     sp, sp, #4
;;       mov     x28, sp
;;       stur    w16, [x1]
;;       ldur    w16, [x28]
;;       add     sp, sp, #4
;;       mov     x28, sp
;;       stur    w16, [x1, #4]
;;       add     sp, sp, #0x20
;;       mov     x28, sp
;;       ldp     x29, x30, [sp], #0x10
;;       ret
;;  14c: .byte   0x1f, 0xc1, 0x00, 0x00
;;  150: .byte   0x1f, 0xc1, 0x00, 0x00
;;  154: .byte   0x1f, 0xc1, 0x00, 0x00
;;  158: .byte   0x1f, 0xc1, 0x00, 0x00
;;  15c: .byte   0x1f, 0xc1, 0x00, 0x00
;;  160: .byte   0x1f, 0xc1, 0x00, 0x00
