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

![](screenshot.png)

With all information (connected to ssh server, runtime and exit status from last command):
![](screenshot_full.png)

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
		- [Repo Indicator](#repo-indicator)
		- [No Tracked Upstream](#no-tracked-upstream)
		- [Remote Commits](#remote-commits)
		- [Branch](#branch)
		- [Local Commits](#local-commits)
		- [Staged Changes](#staged-changes)
		- [Unstaged Changes](#unstaged-changes)
		- [Untracked](#untracked)
		- [Unmerged](#unmerged)
		- [Stashes](#stashes)
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

```git clone --recursive https://github.com/mgee/slimline.git```

Source the prompt in your `.zshrc` (or other appropriate) file:

```source <path-to-slimline>/slimline.zsh```

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

#### Repo Indicator

##### `SLIMLINE_GIT_REPO_INDICATOR`

Defines the git repository indicator text. Default is `%fᚴ`.

#### No Tracked Upstream

##### `SLIMLINE_GIT_NO_TRACKED_UPSTREAM`

Defines the text which is displayed if the branch has no remote tracking branch.
Default is `upstream %F{red}⚡%f`.

#### Remote Commits

##### `SLIMLINE_GIT_REMOTE_COMMITS_PUSH_PULL`

Defines the format used to display commits which can be pushed and pulled to/from `origin/master`.
Default is `𝘮 ${remote_commits_to_pull} %F{yellow}⇄%f ${remote_commits_to_push}`.

##### `SLIMLINE_GIT_REMOTE_COMMITS_PULL`

Defines the format used to display commits which can be pulled from `origin/master`.
Default is `𝘮 %F{red}→%f${remote_commits_to_pull}`.

##### `SLIMLINE_GIT_REMOTE_COMMITS_PUSH`

Defines the format used to display commits which can be pushed to `origin/master`.
Default is `𝘮 %F{green}←%f${remote_commits_to_push}`.

#### Branch

##### `SLIMLINE_GIT_BRANCH`

Defines the format for the local branch. Default is `${branch}`.

##### `SLIMLINE_GIT_DETACHED`

Defines the format if the repository is not on a branch. Default is `%F{red}detached@${sha1}%f`.

#### Local Commits

##### `SLIMLINE_GIT_LOCAL_COMMITS_PUSH_PULL`

Defines the format used to display commits which can be pushed and pulled to/from the remote tracking
branch. Default is `${local_commits_to_pull} %F{yellow}⥯%f ${local_commits_to_push}`.

##### `SLIMLINE_GIT_LOCAL_COMMITS_PULL`

Defines the format used to display commits which can be pulled from the remote tracking branch.
Default is `${local_commits_to_pull}%F{red}↓%f`.

##### `SLIMLINE_GIT_LOCAL_COMMITS_PUSH`

Defines the format used to display commits which can be pushed to the remote tracking branch.
Default is `${local_commits_to_push}%F{green}↑%f`.

#### Staged Changes

##### `SLIMLINE_GIT_STAGED_ADDED`

Defines the format used to display staged added files. Default is `${staged_added}%F{green}A%f`.

##### `SLIMLINE_GIT_STAGED_MODIFIED`

Defines the format used to display staged modified files. Default is `${staged_modified}%F{green}M%f`.

##### `SLIMLINE_GIT_STAGED_DELETED`

Defines the format used to display staged deleted files. Default is `${staged_deleted}%F{green}D%f`.

##### `SLIMLINE_GIT_STAGED_RENAMED`

Defines the format used to display staged renamed files. Default is `${staged_renamed}%F{green}R%f`.

##### `SLIMLINE_GIT_STAGED_COPIED`

Defines the format used to display staged copied files. Default is `${staged_copied}%F{green}C%f`.

#### Unstaged Changes

##### `SLIMLINE_GIT_UNSTAGED_MODIFIED`

Defines the format used to display unstaged modified files. Default is `${unstaged_modified}%F{red}M%f`.

##### `SLIMLINE_GIT_UNSTAGED_DELETED`

Defines the format used to display unstaged deleted files. Default is `${unstaged_deleted}%F{red}D%f`.

#### Untracked

##### `SLIMLINE_GIT_UNTRACKED`

Defines the format used to display untracked files. Default is `${untracked}%F{white}A%f`.

#### Unmerged

##### `SLIMLINE_GIT_UNMERGED`

Defines the format used to display unmerged files. Default is `${unmerged}%F{yellow}U%f`.

#### Stashes

##### `SLIMLINE_GIT_STASHES`

Defines the format used to display the number of stashes. Default is `${stashes}%F{yellow}≡%f`.

## Example

Here is an example for customizing the prompt symbol as well as the git repository indicator and
branch format:

```shell
export SLIMLINE_PROMPT_SYMBOL='$'
# If you have a powerline compatible font you can also use the alternative repo indicator ''.
export SLIMLINE_GIT_REPO_INDICATOR='git'
export SLIMLINE_GIT_BRANCH='[%F{blue}${branch}%f]'

source "<path-to-slimline>/slimline.plugin.zsh"
```

![](screenshot_example.png)

## Thanks

- [sindresorhus/pure](https://github.com/sindresorhus/pure)
- [sorin-ionescu/prezto](https://github.com/sorin-ionescu/prezto.git)
- [michaeldfallen/git-radar](https://github.com/michaeldfallen/git-radar)
- [gbataille/gitHUD](https://github.com/gbataille/gitHUD)

## License

Released under the [MIT License](LICENSE)
