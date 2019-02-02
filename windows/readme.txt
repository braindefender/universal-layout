kbdasm by Grom PE
May, 2016

Assembler/disassembler of Windows keyboard layouts in flat assembler

This program allows to create, edit and install keyboard layouts natively
in Windows 2000, XP, 7, 8, 10; 32-bit or 64-bit.

Customize your keyboard layout to:
- easily type additional symbols without resorting to Alt+codes;
- remap or disable keys;
- combine several alphabets in a single layout, switchable with Caps Lock or Kana key or both;


How to use kbdusru_undead keyboard layout
=========================================
1. >make.bat
2. >install.bat
3. >open_control_input.bat
4. Set the new keyboard layout
5. Restart programs you're typing in


How to modify an existing keyboard layout
=========================================
1. >diskbd.bat kbdtarget.dll
2. edit kbdtarget_source.asm
3. >make.bat kbdtarget_source.asm


How to install Workman keyboard layout
======================================
1. >install_workman.bat
2. >open_control_input.bat
3. Set the new keyboard layout
4. Restart programs you're typing in


How to install custom keyboard layout
=====================================
1. >install.bat kbdtarget.dll
2. >open_control_input.bat
3. Set the new keyboard layout
4. Restart programs you're typing in


Note that you can also drag&drop target files on the .bat files.


flat assembler Copyright (c) 1999-2013, Tomasz Grysztar.
http://flatassembler.net/

Keyboard images generated with keyboard-layout-editor by Ian Prest.
http://keyboard-layout-editor.com/
https://github.com/ijprest/keyboard-layout-editor

The rest is public domain.
