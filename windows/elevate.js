// Run elevated cmd with batch script and arguments
var
  arg = WScript.Arguments,
  r = "",
  app = WScript.CreateObject("Shell.Application");
for (i=0; i < arg.length; i++)
{
  var readyarg = arg(i).indexOf(" ") == -1 ? arg(i) : '"'+arg(i)+'"';
  r += " " + readyarg;
}
app.ShellExecute("cmd", "/k " + r, "", "runas", 1);
