## Legacy Options

Slimline can be customized using a variety of environment variables.
For an example on how to do so see the [example](#example).

- [Prompt Symbol](#prompt-symbol)
- [Current Working Directory](#current-working-directory)
- [Exit Status](#exit-status)
- [Execution Time](#execution-time)
- [User and Host Info](#user-and-host-info)
- [AWS Profile Info](#aws-profile-info)
- [Auto Correction](#auto-correction)
- [Python Virtualenv](#python-virtualenv)

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

### User and Host Info

##### `SLIMLINE_DISPLAY_USER_HOST_INFO`

Defines whether the `user@host` part is displayed if the user differs from the default user or if connected to a ssh server. Default is `1`.

##### `SLIMLINE_USER_COLOR`

Defines the color of the user. Default is `green`.

##### `SLIMLINE_USER_ROOT_COLOR`

Defines the color of the user if the user is root. Default is `red`.

##### `SLIMLINE_HOST_COLOR`

Defines the color of the host. Default is `yellow`.

##### `SLIMLINE_DEFAULT_USER`

Username to consider as the default user. By default this is the current effective user (i.e. the output of `whoami`)

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

### Python Virtualenv

##### `SLIMLINE_DISPLAY_VIRTUALENV`

Defines whether active python virtualenv shall be displayed. Default is `1`.

##### `SLIMLINE_VIRTUALENV_COLOR`

Defines the color of the virtualenv name. Default is `cyan`.

##### `SLIMLINE_VIRTUALENV_PARENS_COLOR`

Defines the color of the parens surrounding the virtualenv name. Default is `white`.

### Git Information

##### `SLIMLINE_ENABLE_GIT`

Defines whether git information shall be displayed (requires python). Default is `1`.

## Example

Here is an example for customizing the prompt symbol as well as the git repository indicator and
branch format:

```shell
export SLIMLINE_PROMPT_VERSION=1 # Activate legacy option format
export SLIMLINE_PROMPT_SYMBOL='$'

# If you have a powerline compatible font you can also use the alternative repo indicator ''.
export GITLINE_REPO_INDICATOR='${reset}git'
export GITLINE_BRANCH='[${blue}${branch}${reset}]'

source "<path-to-slimline>/slimline.zsh"
```
