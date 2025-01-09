WinComposeMod
=============

A **modified** version of [WinCompose](https://github.com/samhocevar/wincompose) (v 0.9.6): a compose key for Windows, free and open-source, created by Sam Hocevar with the help of [dozens of contributors](https://github.com/samhocevar/wincompose/graphs/contributors).

A **compose key** allows to easily write special characters (such as: **É**, **È**, **~** (tilde), **\`** (backtick)) using short and often very intuitive key combinations.

### My modifications ###
* The <kbd>⎄ Compose</kbd> key must be kept pressed to initiate a compose sequence (this key defaults to <kbd>Right Alt</kbd>);
* Combinations are optimized for the Italian keyboard.

### Release ###
* WinComposeMod_x.x.x_Setup_64_user.msi
  * MSI package for **user** installation;
  * Doesn't require administrator privileges;
  * By default can't inject keyboard events into high level processes, such as cmd.exe run as Administrator;
  * Application can be restarted with elevated privileges, necessary to inject keyboard events into other high level processes, such as cmd.exe run as Administrator.

### Development ###
* Written in C#
* Compiles with Microsoft .NET Framework 3.5 and Microsoft Visual Studio Community 2019 (free).
* Used NuGet packages:
  * Emoji.Wpf (v 0.1.5) by Sam Hocevar
  * Hardcodet.NotifyIcon.Wpf (v 1.0.8) by Philipp Sumi

Installer created with:
* MAKEMSI (v 19.089) by Dennis Bareis - https://dennisbareis.com/makemsi.htm

### Default special characters and strings ###
Here ``<Multi_key>`` stands for the <kbd>⎄ Compose</kbd> key (this key defaults to <kbd>Right Alt</kbd>).

    <Multi_key> <'> : "`"  # grave accent
    <Multi_key> <ì> : "~"  # tilde

    <Multi_key> <,> <space>: "´"  # acute accent

    <Multi_key> <ù> <a> : "à"  # a grave
    <Multi_key> <ù> <e> : "è"  # e grave
    <Multi_key> <ù> <i> : "ì"  # i grave
    <Multi_key> <ù> <o> : "ò"  # o grave
    <Multi_key> <ù> <u> : "ù"  # u grave

    <Multi_key> <ù> <A> : "À"  # A grave
    <Multi_key> <ù> <E> : "È"  # E grave
    <Multi_key> <ù> <I> : "Ì"  # I grave
    <Multi_key> <ù> <O> : "Ò"  # O grave
    <Multi_key> <ù> <U> : "Ù"  # U grave

    <Multi_key> <,> <a> : "á"  # a acute
    <Multi_key> <,> <e> : "é"  # e acute
    <Multi_key> <,> <i> : "í"  # i acute
    <Multi_key> <,> <o> : "ó"  # o acute
    <Multi_key> <,> <u> : "ú"  # u acute

    <Multi_key> <,> <A> : "Á"  # A acute
    <Multi_key> <,> <E> : "É"  # E acute
    <Multi_key> <,> <I> : "Í"  # I acute
    <Multi_key> <,> <O> : "Ó"  # O acute
    <Multi_key> <,> <U> : "Ú"  # U acute

    <Multi_key> <?> : "¿"  # inverted question mark
    <Multi_key> <!> : "¡"  # inverted exclamation mark

    <Multi_key> <less>    : "«"  # left double angle quote
    <Multi_key> <greater> : "»"  # right double angle quote

    <Multi_key> <(>       : "‘"  # left single quote
    <Multi_key> <)>       : "’"  # right single quote

    <Multi_key> <">       : "“"  # left double quote
    <Multi_key> <£>       : "”"  # right double quote

    <Multi_key> <b> <h> : "Hello world!"
    <Multi_key> <b> <b> : "Bye bye!"
