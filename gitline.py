#!/usr/bin/env python
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------------------
# Gitline
# by Markus Engelbrecht
#
# Credits
# * git-radar (https://github.com/michaeldfallen/git-radar)
# * gitHUD (https://github.com/gbataille/gitHUD)
#
# MIT License
# -------------------------------------------------------------------------------


import os
import subprocess
from string import Template
from threading import Thread


def parse_repository():
    def execute(command):
        with open(os.devnull) as DEVNULL:
            return subprocess.Popen(command, stdout=subprocess.PIPE, stderr=DEVNULL).communicate()[0]

    repo = dict(
        directory="", branch="", remote="", remote_tracking_branch="", sha1="",
        local_commits_to_pull=0, local_commits_to_push=0, remote_commits_to_pull=0, remote_commits_to_push=0,
        staged_added=0, staged_modified=0, staged_deleted=0, staged_renamed=0, staged_copied=0,
        unstaged_modified=0, unstaged_deleted=0, untracked=0, unmerged=0, stashes=0
    )
    repo['directory'] = execute(['git', 'rev-parse', '--show-toplevel']).rstrip()
    if not repo['directory']:
        return None

    def execute_tasks(*args):
        threads = [Thread(target=task) for task in args]
        for thread in threads:
            thread.start()
        for thread in threads:
            thread.join()

    def branch():
        repo['branch'] = execute(['git', 'symbolic-ref', '--short', 'HEAD']).rstrip()

    def sha1():
        repo['sha1'] = execute(['git', 'rev-parse', '--short', 'HEAD']).rstrip()

    def stashes():
        repo['stashes'] = execute(['git', 'stash', 'list']).count('\n')

    def status():
        for code in map(lambda x: x[0:2], execute(['git', 'status', '-z']).split('\0')):
            if code in ["A ", "AD", "AM"]:
                repo['staged_added'] += 1
            if code in [" M", "AM", "CM", "RM"]:
                repo['unstaged_modified'] += 1
            if code in ["M ", "MD", "MM"]:
                repo['staged_modified'] += 1
            if code in [" D", "AD", "CD", "MD", "RD"]:
                repo['unstaged_deleted'] += 1
            if code in ["D ", "DM"]:
                repo['staged_deleted'] += 1
            if code in ["R ", "RD", "RM"]:
                repo['staged_renamed'] += 1
            if code in ["C ", "CA", "CD", "CM", "CR"]:
                repo['staged_copied'] += 1
            if code in ["AA", "AU", "DD", "DU", "UU", "UA", "UD"]:
                repo['unmerged'] += 1
            if code == "??":
                repo['untracked'] += 1

    def commits_to_pull(source, dest):
        try:
            return int(
                execute(['git', 'rev-list', '--no-merges', '--left-only', '--count', source + '...' + dest]).rstrip())
        except ValueError:
            return 0

    def commits_to_push(source, dest):
        try:
            return int(
                execute(['git', 'rev-list', '--no-merges', '--right-only', '--count', source + '...' + dest]).rstrip())
        except ValueError:
            return 0

    def local_commits_to_pull():
        repo['local_commits_to_pull'] = commits_to_pull(repo['remote_tracking_branch'], 'HEAD')

    def local_commits_to_push():
        repo['local_commits_to_push'] = commits_to_push(repo['remote_tracking_branch'], 'HEAD')

    def remote_commits_to_pull():
        repo['remote_commits_to_pull'] = commits_to_pull('origin/master', repo['remote_tracking_branch'])

    def remote_commits_to_push():
        repo['remote_commits_to_push'] = commits_to_push('origin/master', repo['remote_tracking_branch'])

    execute_tasks(status, branch, stashes, sha1)
    repo['remote'] = execute(['git', 'config', '--get', 'branch.' + repo['branch'] + '.remote']).rstrip()
    repo['remote_tracking_branch'] = execute(
        ['git', 'config', '--get', 'branch.' + repo['branch'] + '.merge']).rstrip().replace('refs/heads',
                                                                                            repo['remote'], 1)
    if execute(['git', 'merge-base', repo['remote_tracking_branch'], 'origin/master']).rstrip():
        execute_tasks(local_commits_to_pull, local_commits_to_push, remote_commits_to_pull, remote_commits_to_push)
    else:
        execute_tasks(local_commits_to_pull, local_commits_to_push)
    return repo


def build_prompt(repo):
    def env_str(s, default):
        return os.getenv('SLIMLINE_GIT_' + s, default)

    def expand(*args):
        return ''.join(Template(fmt).substitute(repo) for cond, fmt in args if cond)

    def choose(formats, *args):
        return expand((True, formats[sum(1 << i for i, v in enumerate(reversed(args)) if v)]))

    parts = filter(bool, [
        expand((True, env_str('REPO_INDICATOR', '%fᚴ'))),
        expand((not repo['remote_tracking_branch'], env_str('NO_TRACKED_UPSTREAM', 'upstream %F{red}⚡%f'))),
        choose(['',
                env_str('REMOTE_COMMITS_PUSH', '𝘮 %F{green}←%f${remote_commits_to_push}'),
                env_str('REMOTE_COMMITS_PULL', '𝘮 %F{red}→%f${remote_commits_to_pull}'),
                env_str('REMOTE_COMMITS_PUSH_PULL',
                        '𝘮 ${remote_commits_to_pull} %F{yellow}⇄%f ${remote_commits_to_push}')],
               repo['remote_commits_to_pull'], repo['remote_commits_to_push']),
        choose([env_str('DETACHED', '%F{red}detached@${sha1}%f'), env_str('BRANCH', '${branch}')], repo['branch']),
        choose(['',
                env_str('LOCAL_COMMITS_PUSH', '${local_commits_to_push}%F{green}↑%f'),
                env_str('LOCAL_COMMITS_PULL', '${local_commits_to_pull}%F{red}↓%f'),
                env_str('LOCAL_COMMITS_PUSH_PULL', '${local_commits_to_pull} %F{yellow}⥯%f ${local_commits_to_push}')],
               repo['local_commits_to_pull'], repo['local_commits_to_push']),
        expand((repo['staged_added'], env_str('STAGED_ADDED', '${staged_added}%F{green}A%f')),
               (repo['staged_modified'], env_str('STAGED_MODIFIED', '${staged_modified}%F{green}M%f')),
               (repo['staged_deleted'], env_str('STAGED_DELETED', '${staged_deleted}%F{green}D%f')),
               (repo['staged_renamed'], env_str('STAGED_RENAMED', '${staged_renamed}%F{green}R%f')),
               (repo['staged_copied'], env_str('STAGED_COPIED', '${staged_copied}%F{green}C%f'))),
        expand((repo['unstaged_modified'], env_str('UNSTAGED_MODIFIED', '${unstaged_modified}%F{red}M%f')),
               (repo['unstaged_deleted'], env_str('UNSTAGED_DELETED', '${unstaged_deleted}%F{red}D%f'))),
        expand((repo['untracked'], env_str('UNTRACKED', '${untracked}%F{white}A%f'))),
        expand((repo['unmerged'], env_str('UNMERGED', '${unmerged}%F{yellow}U%f'))),
        expand((repo['stashes'], env_str('STASHES', '${stashes}%F{yellow}≡%f')))
    ])

    return ' '.join(parts)


if __name__ == '__main__':
    r = parse_repository()
    if r:
        print(build_prompt(r))
