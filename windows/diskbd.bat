;@echo kbdasm by Grom PE. Public domain.
;@echo diskbd - keyboard layout disassembler
;@echo off
;set input=%1
;if "%input%"=="" goto:usage
;set frombat=nul.
;set include=%~pd0fasm\include
;"%~pd0fasm\fasm.exe" "%~df0" %~n1_source.asm
;goto:eof
;:usage
;echo Usage: diskbd.bat ^<kbdfile.dll^> - produce kbdfile_source.asm
;goto:eof
use32
include "%frombat%not_standalone.inc"
include "base.inc"

WOW64 = 0

format binary as "txt"

macro db_utf8 w
{
  if w < 80h
    db w
  else if w < 800h
    db 0C0h or (w shr 6), 80h or (w and 3Fh)
  else if w < 0D800h | w >= 0E000h
    db 0E0h or (w shr 12), 80h or ((w shr 6) and 3Fh), 80h or (w and 3Fh)
  else
    err "Unexpected surrogate here"
  end if
}

macro display_hex bits,value
{
  if value<0
    err "Negative value conversion to hex is not implemented"
  else
    display '0x'
    repeat bits/4
      d = '0' + (value) shr (bits-%*4) and 0Fh
      if d > '9'
        d = d + 'A'-'9'-1
      end if
      display d
    end repeat
  end if
}

macro db_hex bits,value
{
  if value<0
    err "Negative value conversion to hex is not implemented"
  else
    db '0x'
    repeat bits/4
      d = '0' + (value) shr (bits-%*4) and 0Fh
      if d > '9'
        d = d + 'A'-'9'-1
      end if
      db d
    end repeat
  end if
}

macro display_str size,value
{
  repeat size
    display value shr ((%-1)*8) and 0FFh
  end repeat
}

macro display_strz_from addr
{
  while 1
    load d byte from addr+%-1
    if d = 0
      break
    end if
    display d
  end while
}

macro display_wstrz_from addr
{
  while 1
    load d word from addr+(%-1)*2
    if d = 0
      break
    end if
    display d and 0FFh
  end while
}

macro db_strz_from addr
{
  while 1
    load d byte from addr+%-1
    if d = 0
      break
    end if
    db d
  end while
}

macro db_wstrz_from addr
{
  while 1
    load d word from addr+(%-1)*2
    if d = 0
      break
    end if
    db_utf8 d
  end while
}

macro db_quoted_wstrz_from addr
{
  local q
  q = '"'
  while 1
    load d word from addr+(%-1)*2
    if d = 0
      break
    end if
    if d = '"'
      q = "'"
    end if
  end while
  db q
  db_wstrz_from addr
  db q
}

macro compare_strz_from addr, target
{
  equals = 0
  while 1
    load a byte from addr+%-1
    ; Yes, virtual address space is defined every character, this is very ugly
    ; but I found no better way: when the macro is inside the repeat block,
    ; local label gives "symbol already defined" error.
    virtual at 0
      db target, 0
      load b byte from %-1
    end virtual
    if a = 0 | b = 0
      if a = 0 & b = 0
        equals = 1
      end if
      break
    else if a <> b
      break
    end if
  end while
}

macro display_int value
{
  temp = value
  if temp<0
    display '-'
    temp = -temp
  end if
  virtual at 0
    if temp=0
      db '0'
    end if
    while temp>0
      d = '0' + temp mod 10
      db d
      temp = temp / 10
    end while
    repeat $
      load d byte from $-%
      display d
    end repeat
  end virtual
}

macro db_int value
{
  temp = value
  if temp < 0
    db '-'
    temp = -temp
  end if
  if temp = 0
    db '0'
  else
    d = 1
    while temp / (d * 10) > 0
      d = d * 10
    end while
    while d > 0
      n = temp / d
      db '0' + n
      temp = temp - d * n
      d = d / 10
    end while
  end if
}

macro find_section_from_rva addr
{
  found = 0
  repeat num_sections
    load section_name qword from pe + 18h + optional_size + (%-1) * 28h
    load section_vsize dword from pe + 20h + optional_size + (%-1) * 28h
    load section_vaddr dword from pe + 24h + optional_size + (%-1) * 28h
    load section_psize dword from pe + 28h + optional_size + (%-1) * 28h
    load section_paddr dword from pe + 2Ch + optional_size + (%-1) * 28h
    if addr <= section_vaddr + section_vsize
      found = 1
      break
    end if
  end repeat
  if found <> 1
    display "Failed to find a section with rva "
    display_hex 32,addr
    display 13,10
    err
  end if
}

macro convert_to_phys list&
{
  irp var, list
  \{
    if var <> 0
      var = section_paddr - section_vaddr - image_base + var
    end if
  \}
}

macro load_names addr
{
  while 1
    if machine = MACHINE_64BIT | wow_64
      load a byte from input:addr + (%-1) * 16
      load b qword from input:addr + (%-1) * 16 + 8
    else
      load a byte from input:addr + (%-1) * 8
      load b dword from input:addr + (%-1) * 8 + 4
    end if
    if a = 0
      break
    end if
    if b < image_base
      db '; Warning: invalid list termination',13,10
      display ":: Warning: invalid pointer, terminating the names list",13,10
      break
    end if
    convert_to_phys b
    db '    dp '
    db_hex 8,a
    db ', '
    db_quoted_wstrz_from input:b
    db 13,10
  end while
  db '    dp 0, 0',13,10
  db 13,10
  db 'palign',13,10
  db 13,10
}

macro load_ext_scancode2vk addr
{
  while 1
    load a word from input:addr + (%-1) * 4
    load b word from input:addr + (%-1) * 4 + 2
    if a = 0
      break
    end if
    db '    dw '
    db_hex 16,a
    db ', '
    db_vk_ext b
    db 13,10
  end while
  db '    dw 0, 0',13,10
  db 13,10
  db 'palign',13,10
  db 13,10
}

macro db_vk vk
{
  local vkn
  load vkn dword from byte2vk:(vk) * 4
  if vkn = 0
    db_hex 8,vk
  else
    db_wstrz_from byte2vk:vkn
  end if
}

macro db_vk_ext vk
{
  if vk < 100h
    db_vk vk
  else if vk and 0FF00h = KBDEXT
    db "KBDEXT+"
    db_vk vk - KBDEXT
  else if vk and 0FF00h = KBDMULTIVK
    db "KBDMULTIVK+"
    db_vk vk - KBDMULTIVK
  else if vk and 0FF00h = KBDSPECIAL
    db "KBDSPECIAL+"
    db_vk vk - KBDSPECIAL
  else if vk and 0FF00h = KBDNUMPAD
    db "KBDNUMPAD+"
    db_vk vk - KBDNUMPAD
  else if vk and 0FF00h = KBDEXT+KBDMULTIVK
    db "KBDEXT+KBDMULTIVK+"
    db_vk vk - (KBDEXT+KBDMULTIVK)
  else if vk and 0FF00h = KBDSPECIAL+KBDNUMPAD
    db "KBDSPECIAL+KBDNUMPAD+"
    db_vk vk - (KBDSPECIAL+KBDNUMPAD)
  else
    db_hex 16,vk
  end if
}

MACHINE_64BIT = 8664h
MACHINE_32BIT = 14Ch

virtual at 0
  input::
  file "%input%"
  load a word from 0
  if a <> "MZ"
    err "Not a MZ file."
  end if
  load pe word from 3Ch
  load a dword from pe
  if a <> "PE"
    err "Not a PE file."
  end if
  load machine word from pe + 4
  if machine = MACHINE_64BIT
    display ":: reading 64-bit PE file",13,10
  else if machine = MACHINE_32BIT
    display ":: reading 32-bit PE file",13,10
  else
    display "Unsupported machine: "
    display_hex 16,machine
    display 13,10
    err
  end if
  load num_sections word from pe + 6
  load optional_size word from pe + 14h
  if optional_size <> 0f0h & optional_size <> 0e0h
    err "Unexpected optional size."
  end if
  if machine = MACHINE_64BIT
    load num_directories dword from pe + 84h
    load image_base qword from pe + 30h
    load export_rva dword from pe + 88h
    load resource_rva dword from pe + 98h
  else
    load num_directories dword from pe + 74h
    load image_base dword from pe + 34h
    load export_rva dword from pe + 78h
    load resource_rva dword from pe + 88h
  end if
  if export_rva = 0
    err "No export data."
  end if
  if num_directories <> 16
    err "Unexpected number of directories."
  end if
  repeat num_sections
    display ":: Section "
    display_int %
    display ": '"
    load section_name qword from pe + 18h + optional_size + (%-1) * 28h
    load section_vsize dword from pe + 20h + optional_size + (%-1) * 28h
    load section_vaddr dword from pe + 24h + optional_size + (%-1) * 28h
    load section_psize dword from pe + 28h + optional_size + (%-1) * 28h
    load section_paddr dword from pe + 2Ch + optional_size + (%-1) * 28h
    display_str 8,section_name
    display "' "
    display_hex 32,section_vsize
    display " "
    display_hex 32,section_vaddr
    display " "
    display_hex 32,section_psize
    display " "
    display_hex 32,section_paddr
    display 13,10
  end repeat
  find_section_from_rva export_rva
  export_start = section_paddr - section_vaddr + export_rva
  load lib_name_addr dword from export_start + 0Ch
  lib_name_real_addr = section_paddr - section_vaddr + lib_name_addr
  load num_exported dword from export_start + 14h
  load addr_addr dword from export_start + 1Ch
  load names_addr dword from export_start + 20h
  if num_exported > 1
    display "Warning: additional exported functions will be discarded",13,10
  end if
  repeat num_exported
    load addr_ptr dword from section_paddr - section_vaddr + addr_addr + (%-1) * 4
    load name_ptr dword from section_paddr - section_vaddr + names_addr + (%-1) * 4
    compare_strz_from section_paddr - section_vaddr + name_ptr, "KbdLayerDescriptor"
    if equals
      break
    end if
  end repeat
  if ~ equals
    err "Couldn't find exported function KbdLayerDescriptor"
  end if
  find_section_from_rva addr_ptr
  func_start = section_paddr - section_vaddr + addr_ptr

  load instr dword from func_start
  if instr and 0FFFFFFh = 058D48h & machine = MACHINE_64BIT
    display ":: KbdLayerDescriptor: lea rax,[addr]",13,10
    load addr dword from func_start + 3
    kbd_tables_rva = (addr_ptr + addr + 7) and 0FFFFFFFFh
  else if instr and 0FFh = 0B8h & machine = MACHINE_32BIT
    display ":: KbdLayerDescriptor: mov eax,addr",13,10
    load addr dword from func_start + 1
    kbd_tables_rva = addr - image_base
  else
    err "Unknown instruction at the start of KbdLayerDescriptor"
  end if
  find_section_from_rva kbd_tables_rva
  kbd_tables = section_paddr - section_vaddr + kbd_tables_rva

  display ":: KbdTables physical address: "
  display_hex 32,kbd_tables
  display 13,10
  wow_64 = 0
  if machine = MACHINE_32BIT
    load addr dword from kbd_tables + 4h
    ; Assume WOW64 if vk2wchar is zero
    if addr = 0
      wow_64 = 1
    end if
  end if
  kbd_type = 0
  kbd_subtype = 0
  if machine = MACHINE_64BIT | wow_64
    load modifiers_addr qword from kbd_tables
    load vk2wchar_addr qword from kbd_tables + 8h
    load deadkeys_addr qword from kbd_tables + 10h
    load keynames_addr qword from kbd_tables + 18h
    load keynamesExt_addr qword from kbd_tables + 20h
    load keynamesDead_addr qword from kbd_tables + 28h
    load scancode2vk_addr qword from kbd_tables + 30h
    load scancode2vk_size byte from kbd_tables + 38h
    load e0scancode2vk_addr qword from kbd_tables + 40h
    load e1scancode2vk_addr qword from kbd_tables + 48h
    load kbd_flags word from kbd_tables + 50h
    load kbd_version word from kbd_tables + 52h
    load ligatureMaxChars byte from kbd_tables + 54h
    load ligatureEntry byte from kbd_tables + 55h
    load ligatures_addr qword from kbd_tables + 58h
    if kbd_version >= 1
      load kbd_type dword from kbd_tables + 60h
      load kbd_subtype dword from kbd_tables + 64h
    end if
  else
    load modifiers_addr dword from kbd_tables
    load vk2wchar_addr dword from kbd_tables + 4h
    load deadkeys_addr dword from kbd_tables + 8h
    load keynames_addr dword from kbd_tables + 0Ch
    load keynamesExt_addr dword from kbd_tables + 10h
    load keynamesDead_addr dword from kbd_tables + 14h
    load scancode2vk_addr dword from kbd_tables + 18h
    load scancode2vk_size byte from kbd_tables + 1Ch
    load e0scancode2vk_addr dword from kbd_tables + 20h
    load e1scancode2vk_addr dword from kbd_tables + 24h
    load kbd_flags word from kbd_tables + 28h
    load kbd_version word from kbd_tables + 2Ah
    load ligatureMaxChars byte from kbd_tables + 2Ch
    load ligatureEntry byte from kbd_tables + 2Dh
    load ligatures_addr dword from kbd_tables + 30h
    if kbd_version >= 1
      load kbd_type dword from kbd_tables + 34h
      load kbd_subtype dword from kbd_tables + 38h
    end if
  end if
  convert_to_phys modifiers_addr,vk2wchar_addr,deadkeys_addr,keynames_addr,\
    keynamesExt_addr,keynamesDead_addr,scancode2vk_addr,\
    e0scancode2vk_addr,e1scancode2vk_addr,ligatures_addr
  ;display_hex 64,e0scancode2vk_addr
  if machine = MACHINE_64BIT | wow_64
    load vk2bits_addr qword from modifiers_addr
    load modifiers_max word from modifiers_addr + 8
    modifiers_values_addr = modifiers_addr + 10
  else
    load vk2bits_addr dword from modifiers_addr
    load modifiers_max word from modifiers_addr + 4
    modifiers_values_addr = modifiers_addr + 6
  end if
  convert_to_phys vk2bits_addr

  find_section_from_rva resource_rva
  resource_start = section_paddr - section_vaddr + resource_rva
  load num_res word from resource_start + 0Eh
  if num_res > 1
    display "Warning: additional resources will be discarded",13,10
  end if
  found = 0
  repeat num_res
    load resource_type dword from resource_start + 10h + (%-1) * 8
    load resource_offs dword from resource_start + 10h + (%-1) * 8 + 4
    if resource_type = RT_VERSION
      found = 1
      break
    end if
  end repeat
  if found <> 1
    display "Warning: no version info",13,10
    version_start = 0
  else
    repeat 2
      addr = resource_start + resource_offs and 7FFFFFFFh
      load num_res word from addr + 0Eh
      if num_res > 1
        display "Warning: additional subresources will be discarded",13,10
      end if
      load resource_id dword from addr + 10h
      load resource_offs dword from addr + 10h + 4
    end repeat
    addr = resource_start + resource_offs and 7FFFFFFFh
    load version_rva dword from addr
    load version_size dword from addr + 4
    version_start = section_paddr - section_vaddr + version_rva
    ;display_hex 32,version_start
    load a word from version_start + 2
    vstringtable_start = version_start + a + 28h + 24h
    load vstringtable_size word from vstringtable_start
    vstringtable_end = vstringtable_start + vstringtable_size
    ;display_hex 32,vstringtable_end
  end if

  find_section_from_rva kbd_tables_rva ; Must be the last since following code
                                       ; assumes it for convert_to_phys
end virtual

; ----------------------------------------------------------------------------

virtual at 0
  byte2vk::
  include "reverse_vk.inc"
  store_strings
end virtual

; ----------------------------------------------------------------------------

db 0EFh,0BBh,0BFh,'="utf8"',13,10
db 'include "detect_%arch%.inc"',13,10
db 13,10
db 'if SYSTEM_64BIT',13,10
db "  format PE64 DLL native 5.0 at "
db_hex 64,image_base
db ' on "nul" as "dll" ; Build for 64-bit Windows',13,10
db 'else',13,10
db "  format PE DLL native 5.0 at "
db_hex 32,image_base
db ' on "nul" as "dll" ; Build for 32-bit Windows or WOW64',13,10
db 'end if',13,10

db 13,10
db 'MAKE_DLL equ 1',13,10
db 13,10
db 'include "base.inc"',13,10
db 13,10
if wow_64
  db 'WOW64 = 1'
else
  db 'WOW64 = 0'
end if
db ' ; Use when assembling for 32-bit subsystem for 64-bit OS (Is this ever needed?)',13,10
db 'NONE = WCH_NONE',13,10
db 'DEAD = WCH_DEAD',13,10
db 'LGTR = WCH_LGTR',13,10
db 13,10
db 'section ".data" readable executable',13,10
db 13,10

; ----------------------------------------------------------------------------

db 'keynames:',13,10
load_names keynames_addr

db 'keynamesExt:',13,10
load_names keynamesExt_addr

if keynamesDead_addr <> 0
  db 'keynamesDead:',13,10
  while 1
    if machine = MACHINE_64BIT | wow_64
      load a qword from input:keynamesDead_addr + (%-1) * 8
    else
      load a dword from input:keynamesDead_addr + (%-1) * 4
    end if
    if a = 0
      break
    end if
    convert_to_phys a
    db '    dp '
    db_quoted_wstrz_from input:a
    db 13,10
  end while
  db '    dp 0',13,10
  db 13,10
  db 'palign',13,10
  db 13,10
end if

; ----------------------------------------------------------------------------

if ligatures_addr <> 0
  db 'ligatures: .:',13,10

  while 1
    load vk byte from input:ligatures_addr + (%-1) * ligatureEntry
    load vkmod byte from input:ligatures_addr + (%-1) * ligatureEntry + 2
    i = %
    if vk = 0
      break
    end if
    db '    dw '
    db_vk vk
    db 13,10
    db '    dw '
    db_hex 16,vkmod
    db 13,10
    db '    dw '
    repeat ligatureMaxChars
      if % <> 1
        db ', '
      end if
      load w word from input:ligatures_addr + (i-1) * ligatureEntry + 4 + (%-1) * 2
      if w = WCH_NONE
        db 'WCH_NONE'
      else
        db_hex 16,w
      end if
    end repeat
    db 13,10
    if % = 1
      db 'ligature_size = $ - .',13,10
    end if
  end while
  db '    db ligatureEntry dup 0',13,10
  db 13,10
  db 'palign',13,10
  db 13,10
  db 'ligatureMaxChars = (ligature_size - 4) / 2',13,10
  db 'if ligatureMaxChars > 4',13,10
  db '  err "4 characters is max for a ligature on Windows XP or if you use Firefox"',13,10
  db 'end if',13,10
  db 'ligatureEntry = ligature_size',13,10
  db 13,10
end if

; ----------------------------------------------------------------------------

db 'KbdTables:',13,10
db '    dp modifiers',13,10
db '    dp vk2wchar',13,10
if deadkeys_addr = 0
  db '    dp 0                ; Dead keys',13,10
else
  db '    dp deadkeys',13,10
end if
db '    dp keynames         ; Names of keys',13,10
db '    dp keynamesExt',13,10
if keynamesDead_addr = 0
  db '    dp 0                ; Names of dead keys',13,10
else
  db '    dp keynamesDead',13,10
end if
db '    dp scancode2vk      ; Scan codes to virtual keys',13,10
db '    db scancode2vk.size / 2',13,10
db '    palign',13,10
db '    dp e0scancode2vk',13,10
db '    dp e1scancode2vk',13,10
if kbd_flags = 0
  db '    dw 0                ; Locale flags',13,10
else if kbd_flags = KLLF_ALTGR
  db '    dw KLLF_ALTGR       ; Locale flags',13,10
else if kbd_flags = KLLF_SHIFTLOCK
  db '    dw KLLF_SHIFTLOCK   ; Locale flags',13,10
else if kbd_flags = KLLF_LRM_RLM
  db '    dw KLLF_LRM_RLM     ; Locale flags',13,10
else if kbd_flags = KLLF_ALTGR + KLLF_SHIFTLOCK
  db '    dw KLLF_ALTGR + KLLF_SHIFTLOCK ; Locale flags',13,10
else if kbd_flags = KLLF_ALTGR + KLLF_LRM_RLM
  db '    dw KLLF_ALTGR + KLLF_LRM_RLM ; Locale flags',13,10
else if kbd_flags = KLLF_SHIFTLOCK + KLLF_LRM_RLM
  db '    dw KLLF_SHIFTLOCK + KLLF_LRM_RLM ; Locale flags',13,10
else if kbd_flags = KLLF_ALTGR + KLLF_SHIFTLOCK + KLLF_LRM_RLM
  db '    dw KLLF_ALTGR + KLLF_SHIFTLOCK + KLLF_LRM_RLM ; Locale flags',13,10
else
  db '    dw '
  db_hex 16,kbd_flags
  db '           ; Locale flags',13,10
end if
db '    dw KBD_VERSION'
if kbd_version <> 1
  db '      ; Original value: '
  db_hex 16,kbd_version
end if
db 13,10
if ligatures_addr = 0
  db '    db 0                ; Maximum ligature table characters',13,10
  db '    db 0                ; Count of bytes in each ligature row',13,10
  db '    palign',13,10
  db '    dp 0',13,10
else
  db '    db ligatureMaxChars ; Maximum ligature table characters',13,10
  db '    db ligatureEntry    ; Count of bytes in each ligature row',13,10
  db '    palign',13,10
  db '    dp ligatures',13,10
end if
db '    dd '
db_hex 32,kbd_type
db '       ; Type',13,10
db '    dd '
db_hex 32,kbd_subtype
db '       ; Subtype (may contain OEM id)',13,10
db 13,10
db 'palign',13,10
db 13,10

; ----------------------------------------------------------------------------

db 'vk2bits:',13,10
while 1
  load a byte from input:vk2bits_addr + (%-1) * 2
  load b byte from input:vk2bits_addr + (%-1) * 2 + 1
  if a = 0 & b = 0
    break
  end if
  db '    db '
  db_vk a
  db ', '
  if b = KBDSHIFT
    db 'KBDSHIFT'
  else if b = KBDCTRL
    db 'KBDCTRL'
  else if b = KBDALT
    db 'KBDALT'
  else if b = KBDKANA
    db 'KBDKANA'
  else if b = KBDROYA
    db 'KBDROYA'
  else if b = KBDLOYA
    db 'KBDLOYA'
  else
    db_hex 8,b
  end if
  db 13,10
end while
db '    db 0, 0',13,10
db 13,10
db 'palign',13,10
db 13,10

; ----------------------------------------------------------------------------

db 'modifiers:',13,10
db '    dp vk2bits',13,10
db '    dw modifiers_max',13,10
db '.start:',13,10
repeat modifiers_max + 1
  load a byte from input:modifiers_values_addr + %-1
  if a = SHFT_INVALID
    db '    db SHFT_INVALID ; '
  else
    db '    db '
    db_hex 8,a
    db '         ; '
  end if
  if (%-1) and 8 = 8
    db 'KANA'
  else
    db '----'
  end if
  if (%-1) and 4 = 4
    db ' ALT'
  else
    db ' ---'
  end if
  if (%-1) and 2 = 2
    db ' CTRL'
  else
    db ' ----'
  end if
  if (%-1) and 1 = 1
    db ' SHIFT'
  else
    db ' -----'
  end if
  if % = 7
    db ' (Alt+Ctrl = AltGr)'
  end if
  db 13,10
end repeat
db 'modifiers_max = $ - .start - 1',13,10
db 13,10
db 'palign',13,10
db 13,10

; ----------------------------------------------------------------------------

while 1
  if machine = MACHINE_64BIT | wow_64
    load addr qword from input:vk2wchar_addr + (%-1) * 16
    load b qword from input:vk2wchar_addr + (%-1) * 16 + 8
  else
    load addr dword from input:vk2wchar_addr + (%-1) * 8
    load b dword from input:vk2wchar_addr + (%-1) * 8 + 4
  end if
  if addr = 0
    break
  end if
  convert_to_phys addr
  size = b and 0FFh
  db 'vk2wchar'
  db_int %
  db '_'
  db_int size
  db ':',13,10

  vsize = size*2+2
  while 1
    load vk byte from input:addr + (%-1) * vsize
    load vkmod byte from input:addr + (%-1) * vsize + 1
    i = %
    if vk = 0
      break
    end if
    db '    vkrow'
    db_int size
    db ' '
    a = $
    db_vk vk
    ; Text align
    while $ - a < 13
      db ' '
    end while
    db ', '
    if vkmod = 0
      db '0                             '
    else if vkmod = CAPLOK
      db 'CAPLOK                        '
    else if vkmod = SGCAPS
      db 'SGCAPS                        '
    else if vkmod = CAPLOKALTGR
      db 'CAPLOKALTGR                   '
    else if vkmod = KANALOK
      db 'KANALOK                       '
    else if vkmod = CAPLOK + CAPLOKALTGR
      db 'CAPLOK + CAPLOKALTGR          '
    else if vkmod = CAPLOK + KANALOK
      db 'CAPLOK + KANALOK              '
    else if vkmod = CAPLOK + CAPLOKALTGR + KANALOK
      db 'CAPLOK + CAPLOKALTGR + KANALOK'
    else
      db_hex 8,vkmod
      db     '                          '
    end if
    repeat size
      db ', '
      load w word from input:addr + (i-1) * vsize + 2 + (%-1) * 2
      if w = WCH_NONE
        db "NONE"
      else if w = WCH_DEAD
        db "DEAD"
      else if w = WCH_LGTR
        db "LGTR"
      else
        if w < 20h
          db_hex 8,w
        else if w = '"'
          db "'"
          db_utf8 w
          db "' "
        else
          db '"'
          db_utf8 w
          db '" '
        end if
      end if
    end repeat
    db 13,10
  end while


  db '    dw 0, 0, '
  db_int size
  db ' dup 0',13,10
  db 13,10
  db 'palign',13,10
  db 13,10
end while

; ----------------------------------------------------------------------------

db 'vk2wchar:',13,10

while 1
  if machine = MACHINE_64BIT | wow_64
    load a qword from input:vk2wchar_addr + (%-1) * 16
    load b qword from input:vk2wchar_addr + (%-1) * 16 + 8
  else
    load a dword from input:vk2wchar_addr + (%-1) * 8
    load b dword from input:vk2wchar_addr + (%-1) * 8 + 4
  end if
  if a = 0
    break
  end if
  size = b and 0FFh
  db '    dp vk2wchar'
  db_int %
  db '_'
  db_int size
  db ', '
  sizes = size or (size*2+2) shl 8
  db_hex 16,sizes
  if b <> sizes
    db '; Original value: '
    db_hex 16,b
  end if
  db 13,10
end while
db '    dp 0, 0',13,10
db 13,10
db 'palign',13,10
db 13,10

; ----------------------------------------------------------------------------

db 'e1scancode2vk:',13,10
load_ext_scancode2vk e1scancode2vk_addr

db 'e0scancode2vk:',13,10
load_ext_scancode2vk e0scancode2vk_addr

; ----------------------------------------------------------------------------

db 'scancode2vk: .:',13,10
repeat scancode2vk_size
  load a word from input:scancode2vk_addr + (%-1) * 2
  db '    dw '
  db_vk_ext a
  db 13,10
end repeat
db '.size = $ - .',13,10
db 13,10
db 'palign',13,10
db 13,10

; ----------------------------------------------------------------------------

if deadkeys_addr <> 0
  db 'deadkeys:',13,10
  while 1
    load a word from input:deadkeys_addr + (%-1) * 8
    load b word from input:deadkeys_addr + (%-1) * 8 + 2
    load c word from input:deadkeys_addr + (%-1) * 8 + 4
    load f word from input:deadkeys_addr + (%-1) * 8 + 6
    if a = 0
      break
    end if
    if a = '"' | b = '"' | c = '"'
      db "    du '"
      db_utf8 a
      db_utf8 b
      db_utf8 c
      db "', "
    else
      db '    du "'
      db_utf8 a
      db_utf8 b
      db_utf8 c
      db '", '
    end if
    if f = 0
      db '0'
    else if f = 1
      db '1'
    else
      db_hex 16,f
    end if
    db 13,10
  end while
  db '    dw 4 dup 0',13,10
  db 13,10
  db 'palign',13,10
  db 13,10
end if

; ----------------------------------------------------------------------------

db 'data export',13,10
db 'export "'
db_strz_from input:lib_name_real_addr
db '", KbdLayerDescriptor, "KbdLayerDescriptor"',13,10
db 'end data',13,10
db 13,10
db 'palign',13,10
db 13,10
db 'KbdLayerDescriptor:',13,10
db 'if detected_32bit',13,10
db '    mov    eax,KbdTables',13,10
db '    cdq',13,10
db 'else',13,10
db '    lea    rax,[KbdTables]',13,10
db 'end if',13,10
db '    ret',13,10
db 13,10
db 'palign',13,10
db 13,10
db 'store_strings',13,10
db 13,10

if version_start
  db 'section ".rsrc" data readable resource',13,10
  db 13,10
  db 'directory RT_VERSION,versions',13,10
  db 'resource versions,1,LANG_NEUTRAL,version',13,10
  db 'versioninfo version,VOS_NT_WINDOWS32,VFT_DLL,VFT2_DRV_KEYBOARD,0,1200'

  addr = vstringtable_start + 18h
  while 1
    addr = ((addr-1)/4+1)*4 ; Align to 4
    if addr >= vstringtable_end
      break
    end if
    load size word from input:addr
    db ',\',13,10,'    "'
    a = addr + 6
    while 1
      load d word from input:a
      a = a + 2
      if d = 0
        break
      end if
      db_utf8 d
    end while
    db '","'
    db_wstrz_from input:((a-1)/4+1)*4
    db '"'
    addr = addr + size
  end while
  db 13,10

  db 13,10
end if

db 'section ".reloc" data readable discardable fixups',13,10
