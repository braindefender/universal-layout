format PE console 5.0

struc pstr [text*]
{
  common
    align 4
    dd .length
    . db text
  .length = $ - .
}

entry main

STD_OUTPUT_HANDLE = 0FFFFFFF5h
KLF_ACTIVATE      = 1

section ".text" readable executable

main:
    xor   ebx, ebx
    call  [GetCommandLineW]
    mov   esi, eax
    mov   edi, eax
.get_command_line_length:
    push  eax
    call  [lstrlenW]
    mov   ecx, eax
    mov   edi, esi
.parse_arg:
    mov   ax, '"'
    ;dec   ecx
    scasw
    jne   .no_quote
.parse_quote:
    repne scasw
    jmp   .arg_end
.no_quote:
    mov   ax, ' '
    repne scasw
    dec   edi
    dec   edi
    inc   ecx
.arg_end:
    push  ecx
    call  handle_argument
    pop   ecx
    mov   ax, ' '
    repe  scasw
    dec   edi
    dec   edi
    mov   esi, edi
    inc   ebx
    cmp   ecx, 0
    ja    .parse_arg
.done_args:
    dec   ebx
    jz    .show_usage ; no arguments
    cmp   [_err], 0
    jnz   .invalid_arg
    dec   ebx
    jz    .invalid_arg
.install:
    push  [_mode]
    push  _layout
    call  [InstallLayoutOrTip]
    test  eax, eax
    jz    .install_error
    lea   eax, [_layout + 9]
    push  KLF_ACTIVATE
    push  eax
    call  [LoadKeyboardLayoutW]
    test  eax, eax
    jz    .load_error
    mov   eax, _op_success
    call  write_pstr
    push  0
    call  [ExitProcess]
.invalid_arg:
    mov   eax, _invalid
    call  write_pstr
.show_usage:
    mov   eax, _usage
    call  write_pstr
    jmp   .exit_err
.load_error:
    mov   eax, _load_error
    call  write_pstr
    jmp   .exit_err
.install_error:
    mov   eax, _op_error
    call  write_pstr
.exit_err:
    push  1
    call  [ExitProcess]

write_pstr:
    push  0
    push  esp
    push  dword [eax-4]
    push  eax
    push  STD_OUTPUT_HANDLE
    call  [GetStdHandle]
    push  eax
    call  [WriteFile]
    ret

handle_argument:
; ebx = argument
; esi = start of the string
; edi = end of the string
    mov   eax, edi
    sub   eax, esi
    shr   eax, 1
    mov   edx, esi
    cmp   word [esi], '"'
    jne   .no_quote
    inc   edx
    inc   edx
    dec   eax
    dec   eax
.no_quote:
    cmp   ebx, 2
    jg    .not_handled
    jmp   dword [.jumptable+ebx*4]
.jumptable:
    dd .not_handled
    dd .set_mode
    dd .set_layout
.set_mode:
    cmp   eax, 1
    jne   .err
    xor   eax, eax
    mov   dx, [edx]
    cmp   dx, "r"
    je    .reg
    cmp   dx, "u"
    je    .unreg
    jmp   .err
.unreg:
    inc   eax
.reg:
    mov   [_mode], eax
    jmp   .exit
.set_layout:
    cmp   eax, 17
    jne   .err
    mov   ecx, eax
    push  esi
    push  edi
    mov   esi, edx
    mov   edi, _layout
    repne movsw
    pop   edi
    pop   esi
    jmp   .exit
.err:
    mov   al, 1
    mov   [_err], al
.not_handled:
.exit:
    ret

section ".data" readable writable

_mode dd 0
_err db 0

_layout du "0x0000:0x00000000",0

_invalid pstr "Error: invalid argument",13,10
_usage pstr "Register layout:",13,10,\
            "  reg_layout r 0x0419:0x12340419",13,10,\
            "Unregister layout:",13,10,\
            "  reg_layout u 0x0419:0x12340419",13,10
_load_error pstr "Error: LoadKeyboardLayoutW function returned an error",13,10
_op_error pstr "Error: InstallLayoutOrTip function returned an error",13,10
_op_success pstr "Operation successful",13,10

align 4

include "import.inc"
import kernel32.dll, ExitProcess, lstrlenW, GetCommandLineW, GetStdHandle,\
  WriteFile, GetLastError, FormatMessageW
import user32.dll, LoadKeyboardLayoutW
import input.dll, InstallLayoutOrTip
importend
