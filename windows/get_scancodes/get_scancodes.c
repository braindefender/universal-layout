#include <stdint.h>
#include <stdio.h>
#include <conio.h>
#include <windows.h>

static int esc = 0;

__declspec(dllexport) LRESULT CALLBACK handlekeys(int code, WPARAM wp, LPARAM lp)
{
  if (wp == WM_KEYDOWN || wp == WM_SYSKEYDOWN)
  {
    KBDLLHOOKSTRUCT st_hook = *((KBDLLHOOKSTRUCT*)lp);
    unsigned int sc = st_hook.scanCode;
    unsigned int vk = st_hook.vkCode;
    char* ext = (st_hook.flags & LLKHF_EXTENDED) == 1 ? "ext" : "   ";
    printf("%s %02Xh -> %02X\n", ext, sc, vk);
    if (sc == 1)
    {
      if (esc)
      {
        PostQuitMessage(0);
      } else {
        esc = 1;
        printf("Press ESC again to quit\n");
      }
    } else {
      esc = 0;
    }
  }
  return 0;
}

void xMain()
{
  HINSTANCE modulehandle = GetModuleHandle(NULL);
  MSG msg;
  HHOOK kbdhook = SetWindowsHookEx(WH_KEYBOARD_LL, (HOOKPROC)handlekeys, modulehandle, 0);

  while (GetMessage(&msg, NULL, 0, 0))
  {
    TranslateMessage(&msg);
    DispatchMessage(&msg);
  }
  UnhookWindowsHookEx(kbdhook);
  // Clear the buffer
  while (_kbhit()) _getch();
}
