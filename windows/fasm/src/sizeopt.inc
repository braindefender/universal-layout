macro test op,val { 
        local address,opcode,length,start 
        start=$ 
        address equ 
        match [addr], op \{ address equ addr \} 
        match size [addr], op \{ address equ addr \} 
        match size =ptr addr, op \{ address equ addr \} 
        if val eqtype 0 
                virtual at 0 
                        test op,val 
                        length=$-$$ 
                        repeat $ 
                                load opcode byte from %-1 
                                if opcode <> 66h & opcode <> 67h & \ 
                                   opcode <> 64h & opcode <> 65h & \ 
                                   opcode <> 26h & opcode <> 2eh & \ 
                                   opcode <> 36h & opcode <> 3eh 
                                        break 
                                end if 
                        end repeat 
                end virtual 
                if opcode = 0F7h & ~ address eq 
                        if val = (val) and 7Fh 
                                test byte [address],val 
                        else if val = (val) and 7F00h 
                                test byte [address+1],(val) shr 8 
                        else if val = (val) and 7F0000h 
                                test byte [address+2],(val) shr 16 
                        else if val = (val) and 0FF000000h 
                                test byte [address+3],(val) shr 24 
                        else if val = (val) and 07FFFh 
                                test word [address],val 
                        else if val = (val) and 07FFF00h 
                                test word [address+1],(val) shr 8 
                        else if val = (val) and 0FFFF0000h 
                                test word [address+2],(val) shr 16 
                        else 
                                test op,val 
                        end if 
                else if op eq eax & val = (val) and 7Fh 
                        test al,val 
                else if op eq eax & val = (val) and 7F00h 
                        test ah,(val) shr 8 
                else if op eq ebx & val = (val) and 7Fh 
                        test bl,val 
                else if op eq ebx & val = (val) and 7F00h 
                        test bh,(val) shr 8 
                else if op eq ecx & val = (val) and 7Fh 
                        test cl,val 
                else if op eq ecx & val = (val) and 7F00h 
                        test ch,(val) shr 8 
                else if op eq edx & val = (val) and 7Fh 
                        test dl,val 
                else if op eq edx & val = (val) and 7F00h 
                        test dh,(val) shr 8 
                else if op eq ax & val = (val) and 7Fh 
                        test al,val 
                else if op eq ax & val = (val) and 0FF00h 
                        test ah,(val) shr 8 
                else if op eq bx & val = (val) and 7Fh 
                        test bl,val 
                else if op eq bx & val = (val) and 0FF00h 
                        test bh,(val) shr 8 
                else if op eq cx & val = (val) and 7Fh 
                        test cl,val 
                else if op eq cx & val = (val) and 0FF00h 
                        test ch,(val) shr 8 
                else if op eq dx & val = (val) and 7Fh 
                        test dl,val 
                else if op eq dx & val = (val) and 0FF00h 
                        test dh,(val) shr 8 
                else 
                        test op,val 
                end if 
        else 
                test op,val 
        end if 
}

macro lea [stuff] { 
        common 
        local b1,b2,b3,address 
        address equ 
        match reg=,[addr],stuff\{address equ addr\}  
        match reg=,size[addr],stuff\{address equ addr\}  
        match reg=,size =ptr addr,stuff\{address equ addr\}  
        virtual 
                b1=0 
                b2=0 
                leA stuff 
                if ($-$$)=2 
                        load b1 byte from $$ 
                        load b2 byte from $$+1 
                else if ($-$$)=3 
                        load b1 byte from $$ 
                        load b2 byte from $$+1 
                        load b3 byte from $$+2 
                        if ~(b1=8dh & (b2 and 307o)=004o & b3=24h) & \ ;lea reg,[esp] 
                           ~(b1=8dh & (b2 and 307o)=105o & b3=00h)     ;lea reg,[ebp] 
                                b1=0 
                        end if 
                else if ($-$$)=6 & ~address eq 
                        load b1  byte from $$ 
                        load b2  byte from $$+1 
                        if b1=8dh & (b2 and 307o)=005o ;lea reg,[immediate] 
                                b1=100h 
                        else 
                                b1=0 
                        end if 
                end if 
        end virtual 
        if b1=08dh 
                if ~((b2 and 7o)=((b2 and 70o) shr 3)) 
                        db 08bh,b2 or 300o 
                else 
                        ;do nothing 
                end if 
        else if b1=100h 
                db 0b8h or ((b2 and 70o) shr 3) 
                dd address 
        else 
                leA stuff 
        end if 
}

macro mov op1, op2 
{ 
  if op2 eqtype 0 & op2 relativeto 0
    if op2 = 0 
      if op1 eqtype eax 
        xor op1, op1 
      else 
        and op1, 0 
      end if 
    else if op2 = -1 
      or op1, -1 
    else if op2 = 1 & op1 in <eax,ebx,ecx,edx,esi,edi,ebp,esp> 
      xor op1, op1 
      inc op1 
    else 
      mov op1, op2 
    end if 
  else 
    mov op1, op2 
  end if 
}
