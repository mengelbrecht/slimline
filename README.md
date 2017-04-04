# slimline

Minimal, fast and elegant ZSH prompt. Displays the right information at the right time.

Features:
- sleek look
- customizable non-blocking git information display
- prompt symbol indicates if prompt background tasks are running
- exit code of last command if the exit code is not zero
- runtime of executed command if it exceeds a threshold
- username and host name if connected to a ssh server
- very customizable

<img src="screenshot.png" width="682" height="299">

With most information (connected to ssh server, runtime and exit status from last command):

<img src="screenshot_full.png" width="682" height="299">

For a fish compatible version of this theme have a look at [slimfish](https://github.com/mgee/slimfish).

## Table Of Contents

- [Requirements](#requirements)
    - [Optional](#optional)
- [Installation](#installation)
    - [antigen](#antigen)
    - [zplugin](#zplugin)
    - [zgen](#zgen)
    - [Manually](#manually)
- [Options](#options)
    - [Prompt Symbol](#prompt-symbol)
    - [Current Working Directory](#current-working-directory)
    - [Exit Status](#exit-status)
    - [Execution Time](#execution-time)
    - [SSH Info](#ssh-info)
    - [AWS Profile Info](#aws-profile-info)
    - [Auto Correction](#auto-correction)
    - [Git Information](#git-information)
        - [Gitline](#gitline)
- [Example](#example)
- [Thanks](#thanks)
- [License](#license)

## Requirements

* zsh

### Optional

* python 2.6+ to enable git information display

## Installation

Choose one of the methods below.

### [antigen](https://github.com/zsh-users/antigen)

```
antigen bundle mgee/slimline
```

### [zplugin](https://github.com/zdharma/zplugin)

```
zplugin load mgee/slimline
```

### [zgen](https://github.com/tarjoilija/zgen)

```
zgen load mgee/slimline
```

### Manually

Clone the repository:

```shell
git clone --recursive https://github.com/mgee/slimline.git
```

Source the prompt in your `.zshrc` (or other appropriate) file:

```shell
source <path-to-slimline>/slimline.zsh
```

## Options

Slimline can be customized using a variety of environment variables.
For an example on how to do so see the [example](#example).

### Prompt Symbol

##### `SLIMLINE_PROMPT_SYMBOL`

Defines the symbol of the prompt. Default is `∙`.

##### `SLIMLINE_PROMPT_SYMBOL_COLOR_WORKING`

Defines the color of the prompt when asynchronous tasks are running. Default is `red`.

##### `SLIMLINE_PROMPT_SYMBOL_COLOR_READY`

Defines the color of the prompt when all asynchronous tasks are finished. Default is `white`.

### Current Working Directory

##### `SLIMLINE_CWD_COLOR`

Defines the color of the current working directory. Default is `cyan`.

##### `SLIMLINE_CWD_ROOT_COLOR`

Defines the color of the current working directory if it equals the root directory `/`. Default is `red`.

### Exit Status

##### `SLIMLINE_DISPLAY_EXIT_STATUS`

Defines whether the exit status is displayed if the exit code is not zero. Default is `1`.

##### `SLIMLINE_EXIT_STATUS_SYMBOL`

Defines the symbol of the exit status glyph. Default is `↵`.

##### `SLIMLINE_EXIT_STATUS_COLOR`

Defines the color of the exit status information. Default is `red`.

### Execution Time

##### `SLIMLINE_DISPLAY_EXEC_TIME`

Defines whether the runtime of a process is displayed if it exceeds the maximum execution time
specified by the option below. Default is `1`.

##### `SLIMLINE_MAX_EXEC_TIME`

Defines the maximum execution time of a process until its run time is displayed on exit.
Default is `5` seconds.

##### `SLIMLINE_EXEC_TIME_COLOR`

Defines the color of the execution time. Default is `yellow`.

### SSH Info

##### `SLIMLINE_DISPLAY_SSH_INFO`

Defines whether the `user@host` part is displayed if connected to a ssh server. Default is `1`.

##### `SLIMLINE_SSH_INFO_USER_COLOR`

Defines the color of the ssh user. Default is `red`.

##### `SLIMLINE_SSH_INFO_HOST_COLOR`

Defines the color of the ssh host. Default is `yellow`.

### AWS Profile Info

##### `SLIMLINE_DISPLAY_AWS_INFO`

Defines whether value of `AWS_PROFILE` environment variable should be displayed. Default is `0`.

##### `SLIMLINE_AWS_COLOR`

Defines the color of aws profile info. Default is `blue`.

### Auto Correction

##### `SLIMLINE_AUTOCORRECT_MISSPELLED_COLOR`

Defines the color of the misspelled string for which is correction is proposed. Default is `red`.

##### `SLIMLINE_AUTOCORRECT_PROPOSED_COLOR`

Defines the color of the proposed correction of a misspelled string. Default is `green`.

### Git Information

##### `SLIMLINE_ENABLE_GIT`

Defines whether git information shall be displayed (requires python). Default is `1`.

#### Gitline

slimline uses [gitline](https://github.com/mgee/gitline) to display git information.
gitline can be extensively customized. Have a look at the [gitline options](https://github.com/mgee/gitline#options).

## Example

Here is an example for customizing the prompt symbol as well as the git repository indicator and
branch format:

```shell
export SLIMLINE_PROMPT_SYMBOL='$'
# If you have a powerline compatible font you can also use the alternative repo indicator ''.
export GITLINE_REPO_INDICATOR='${reset}git'
export GITLINE_BRANCH='[${blue}${branch}${reset}]'

source "<path-to-slimline>/slimline.plugin.zsh"
```

<img src="screenshot_example.png" width="682" height="299">

## Thanks

- [sindresorhus/pure](https://github.com/sindresorhus/pure)
- [sorin-ionescu/prezto](https://github.com/sorin-ionescu/prezto.git)

## License

Released under the [MIT License](LICENSE)
