using System.Runtime.InteropServices;
using Microsoft.CommandPalette.Extensions;

namespace Unidecode;

[Guid("54F19365-5E07-4C92-BA72-D2E61AB2D107")]
public sealed partial class UnidecodeExtension : IExtension, IDisposable
{
    private readonly ManualResetEvent _extensionDisposedEvent;
    private readonly UnidecodeCommandsProvider _provider = new();

    public UnidecodeExtension(ManualResetEvent extensionDisposedEvent)
    {
        _extensionDisposedEvent = extensionDisposedEvent;
    }

    public object? GetProvider(ProviderType providerType) => providerType switch
    {
        ProviderType.Commands => _provider,
        _ => null,
    };

    public void Dispose() => _extensionDisposedEvent.Set();
}
