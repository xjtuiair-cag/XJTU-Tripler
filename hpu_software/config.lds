OUTPUT_ARCH( "riscv" )

ENTRY( _start )

MEMORY
{
    ictm  : ORIGIN = 0x00000000, LENGTH = 64K
    dctm  : ORIGIN = 0x00100000, LENGTH = 64K
}

SECTIONS
{
    .text.init          : { *(.text.init) } >ictm
    .text               : { *(.text) } >ictm

    .rodata             : { *(.rodata) } >dctm
    .bss                : { *(.bss) } >dctm
    .common             : { *(.common) *(.comm) } >dctm
    .data               : { *(.data) } >dctm
    .stack              : { *(.stack) } >dctm
}
