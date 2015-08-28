# slimline

Minimal and fast ZSH prompt.

Features:
- sleek look
- [asynchronous](https://github.com/mafredri/zsh-async) git information display using [git-radar](https://github.com/michaeldfallen/git-radar)
- the right amount of information at the right time
- the prompt symbol is colored red, when all asynchronous tasks are finished it turns white

![](screenshot.png)

With all information (connected to ssh server and exit status from last command):
![](screenshot_full.png)

## Requirements

* zsh
* [zsh-async](https://github.com/mafredri/zsh-async)
* [git-radar](https://github.com/michaeldfallen/git-radar) (optional, enables git info display)

## Install

First, install [git-radar](https://github.com/michaeldfallen/git-radar).
Then choose one of the methods below.

### [antigen](https://github.com/zsh-users/antigen)

```
antigen bundle mafredri/zsh-async
antigen bundle mgee/slimline
```

### [zgen](https://github.com/tarjoilija/zgen)

```
zgen load mafredri/zsh-async
zgen load mgee/slimline
```

### Manually

Install [zsh-async](https://github.com/mafredri/zsh-async).

Clone the repository:

```git clone https://github.com/mgee/slimline```

Source the prompt in your `.zshrc` (or other appropriate) file:

```source <path-to-slimline>/slimline.zsh```

## Options

### `SLIMLINE_PROMPT_SYMBOL`

Defines the symbol of the prompt. Default is `∙`.

### `SLIMLINE_DISPLAY_EXEC_TIME`

Defines whether the runtime of a process is displayed if it exceeds the maximum execution time specified by the option below. Default is `1`.

### `SLIMLINE_MAX_EXEC_TIME`

Defines the maximum execution time of a process until its run time is displayed on exit. Default is `5` seconds.

### `SLIMLINE_DISPLAY_EXIT_STATUS`

Defines whether the exit status is displayed if the exit code is not zero. Default is `1`.

### `SLIMLINE_DISPLAY_SSH_INFO`

Defines whether the `user@host` part is displayed if connected to a ssh server. Default is `1`.

## Thanks to

- [sindresorhus/pure](https://github.com/sindresorhus/pure)
- [sorin-ionescu/prezto](https://github.com/sorin-ionescu/prezto.git)
- [zsh-async](https://github.com/mafredri/zsh-async)
- [git-radar](https://github.com/michaeldfallen/git-radar)

## License

Released under the [MIT License](LICENSE)
