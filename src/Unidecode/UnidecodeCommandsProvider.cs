using Microsoft.CommandPalette.Extensions;
using Microsoft.CommandPalette.Extensions.Toolkit;

namespace Unidecode;

public sealed partial class UnidecodeCommandsProvider : CommandProvider
{
    private readonly ICommandItem[] _commands;

    public UnidecodeCommandsProvider()
    {
        DisplayName = "Unidecode";
        Icon = new IconInfo("\uE8D2");
        _commands =
        [
            new CommandItem(new UnicodeDecodePage())
            {
                Title = "Unidecode",
                Subtitle = @"Decode \uXXXX Unicode escape sequences",
            },
        ];
    }

    public override ICommandItem[] TopLevelCommands() => _commands;
}
