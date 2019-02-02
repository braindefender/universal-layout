if not exist reg_layout.exe call make reg_layout.asm
if not exist layouts\kbdunirus.dll call make layouts\kbdunirus.asm
install layouts\kbdunirus.dll 07430419 00d0 "Uni RU" "Univesal Layout Russian"
install layouts\kbdunieng.dll 07430409 00d1 "Uni EN" "Univesal Layout English"