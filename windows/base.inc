; Detect whether we're assembling in 32 or 64 bits
virtual at 0
  xchg eax,eax
  detected_32bit = $-2
end virtual

include "const.inc"

match =1, MAKE_DLL
{
  include 'macro/export.inc'
  include 'macro/resource.inc'
  include "encoding/utf8.inc"
}
maybe_rva equ
match =1, MAKE_DLL
{
  maybe_rva equ rva
}
macro zeroalign value
{
  rb (value-1)-(maybe_rva $+value-1) mod value
}
macro palign value
{
  if detected_32bit & ~ WOW64
    zeroalign 4
  else
    zeroalign 8
  end if
}
macro vkrow VirtualKey, Attributes, wch&
{
  db VirtualKey, Attributes
  du wch
}
; The following macros are to prevent assembly with missing or extra columns
macro vkrow1 v, a, c1*
{ vkrow v, a, c1 }
macro vkrow2 v, a, c1*, c2*
{ vkrow v, a, c1, c2 }
macro vkrow3 v, a, c1*, c2*, c3*
{ vkrow v, a, c1, c2, c3 }
macro vkrow4 v, a, c1*, c2*, c3*, c4*
{ vkrow v, a, c1, c2, c3, c4 }
macro vkrow5 v, a, c1*, c2*, c3*, c4*, c5*
{ vkrow v, a, c1, c2, c3, c4, c5 }
macro vkrow6 v, a, c1*, c2*, c3*, c4*, c5*, c6*
{ vkrow v, a, c1, c2, c3, c4, c5, c6 }
macro vkrow7 v, a, c1*, c2*, c3*, c4*, c5*, c6*, c7*
{ vkrow v, a, c1, c2, c3, c4, c5, c6, c7 }
macro vkrow8 v, a, c1*, c2*, c3*, c4*, c5*, c6*, c7*, c8*
{ vkrow v, a, c1, c2, c3, c4, c5, c6, c7, c8 }
macro vkrow9 v, a, c1*, c2*, c3*, c4*, c5*, c6*, c7*, c8*, c9*
{ vkrow v, a, c1, c2, c3, c4, c5, c6, c7, c8, c9 }
macro vkrow10 v, a, c1*, c2*, c3*, c4*, c5*, c6*, c7*, c8*, c9*, c10*
{ vkrow v, a, c1, c2, c3, c4, c5, c6, c7, c8, c9, c10 }

struc equ! expr
{
  rept 1 value:expr
  \{
    restore .
    . equ value
  \}
}

stored_strings equ ""
stst_index equ 1

macro dp [v]
{
  forward
    stst_index equ! stst_index+1
    if v eqtype ""
      match A,stst_index
      \{
        if detected_32bit & ~ WOW64
          dd stst_\#A
        else
          dq stst_\#A
        end if
      \}
      stored_strings equ stored_strings,v
    else
      if detected_32bit & ~ WOW64
        dd v
      else
        dq v
      end if
    end if
}

macro store_strings
{
  stst_index equ 0
  match a,stored_strings
  \{
    irp v,a
    \\{
      stst_index equ! stst_index+1
      match A,stst_index
      \\\{
        stst_\\\#A:
        if v eqtype ""
          du v, 0
        end if
        palign
      \\\}
    \\}
  \}
}
