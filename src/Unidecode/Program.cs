using Microsoft.CommandPalette.Extensions;
using Shmuelie.WinRTServer;
using Shmuelie.WinRTServer.CsWinRT;

namespace Unidecode;

public static class Program
{
    [MTAThread]
    public static void Main(string[] args)
    {
        if (args.Length == 0 || args[0] != "-RegisterProcessAsComServer")
        {
            return;
        }

        var server = new ComServer();
        using var extensionDisposedEvent = new ManualResetEvent(false);
        var extensionInstance = new UnidecodeExtension(extensionDisposedEvent);

        server.RegisterClass<UnidecodeExtension, IExtension>(() => extensionInstance);
        server.Start();
        extensionDisposedEvent.WaitOne();
        server.Stop();
        server.UnsafeDispose();
    }
}
