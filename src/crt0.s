# 1 "crt0.S"
# 1 "<built-in>"
# 1 "<command-line>"
# 1 "/usr/include/stdc-predef.h" 1 3 4
# 1 "<command-line>" 2
# 1 "crt0.S"
 .title "crt0.S for m68k-elf"





        .data
        .align 2
SYM (environ):
        .long 0

  .align 2
 .text







 .extern SYM (main)
# 32 "crt0.S"
 .extern __stack
 .extern __bss_start
 .extern _end







 .global SYM (start)
 .weak SYM (start)
 .set SYM (start),SYM(_start)

 .global SYM (_start)
SYM (_start):







 movel IMM(__stack), a0
 cmpl IMM(0), a0
 jbeq 1f
 movel a0, sp
1:

 link a6, IMM(-8)




 movel IMM(__bss_start), d1
 movel IMM(_end), d0
 cmpl d0, d1
 jbeq 3f
 movl d1, a0
 subl d1, d0
 subql IMM(1), d0
2:
 clrb (a0)+

 dbra d0, 2b
 clrw d0
 subql IMM(1), d0
 jbcc 2b





3:
