PROMPT='$(custom_update_remotes)%{$fg_bold[red]%}➜%{$fg_bold[green]%}%p %{$fg[cyan]%}%c $(custom_git_prompt_info)%{$fg_bold[blue]%}% %{$reset_color%}'

ZSH_THEME_GIT_PROMPT_PREFIX="%{$FG[243]%}git:(%{$FG[249]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$FG[243]%})%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[red]%}✗%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[green]%}✓%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_ADDED="A "
ZSH_THEME_GIT_PROMPT_DELETED="D "
ZSH_THEME_GIT_PROMPT_MODIFIED="M "
ZSH_THEME_GIT_PROMPT_UNTRACKED="U "
ZSH_THEME_GIT_PROMPT_CONFLICTED="C "

ZSH_THEME_GIT_PROMPT_SEPARATOR="%{$FG[243]%}|%{$reset_color%}"

ZSH_THEME_GIT_PROMPT_BEHIND_REMOTE="%{$FG[039]%}↓%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_AHEAD_REMOTE="%{$FG[166]%}↑%{$reset_color%}"

alias git-graph='git log --graph --color --all --pretty=format:"%C(yellow)%H%C(green)%d%C(reset)%n%x20%cd%n%x20%cn%x20(%ce)%n%x20%s%n"'

function custom_is_git_dirty() {
  if [ -n "$(git ls-files --others --exclude-standard)" ]; then
    echo "untracked" 
  elif [[ -n $(git diff-index --cached --quiet HEAD -- || echo "yup") ]]; then
    echo "staged"
  fi
}

function minutes_since_last_commit {
    now=`date +%s`
    last_commit=`git log --pretty=format:'%at' -1`
    seconds_since_last_commit=$((now-last_commit))
    minutes_since_last_commit=$((seconds_since_last_commit/60))
    echo $minutes_since_last_commit
}

function shouldnt_you_commit {
  if [ "$(minutes_since_last_commit)" -gt 2 ]; then 
    echo "|%{$fg[234]%}ಠ_ಠ%{$reset_color%}"
  fi
}

function git_files_status {
  statS=$(git status --porcelain 2>/dev/null)
  untracked="$(echo "$statS" | grep -o "?? " | wc -l | grep -oEi '[1-9][0-9]*')"
  added="$(echo "$statS" | grep -o "A " | wc -l | grep -oEi '[1-9][0-9]*')"
  deleted="$(echo "$statS" | grep -o "D " | wc -l | grep -oEi '[1-9][0-9]*')"
  modified="$(echo "$statS" | grep -o "M " | wc -l | grep -oEi '[1-9][0-9]*')"
  conflicted="$(echo "$statS" | grep -o "UU " | wc -l | grep -oEi '[1-9][0-9]*')"

  if [ -n "$added" ]; then
    echo -n "$added$ZSH_THEME_GIT_PROMPT_ADDED"
  fi
  if [ -n "$untracked" ]; then 
    echo -n "$untracked$ZSH_THEME_GIT_PROMPT_UNTRACKED"
  fi
  if [ -n "$deleted" ]; then 
    echo -n "$deleted$ZSH_THEME_GIT_PROMPT_DELETED"
  fi
  if [ -n "$modified" ]; then 
    echo -n "$modified$ZSH_THEME_GIT_PROMPT_MODIFIED"
  fi
  if [ -n "$conflicted" ]; then
    echo -n "$conflicted$ZSH_THEME_GIT_PROMPT_CONFLICTED"
  fi
}

function custom_update_remotes() {
    ref=$(git symbolic-ref HEAD 2> /dev/null) || return
    fetch_head="$(git rev-parse --show-toplevel)/.git/FETCH_HEAD"
    if [ -f $fetch_head ]; then 
        last_update=$(stat -f %m $fetch_head)
        
        secs=$(date -u +%s)
    	if [[ $(($secs - $last_update)) -gt "360" ]] ; then 
	    (nohup git fetch --prune > /dev/null &) 2> /dev/null
    	fi
    else
        (nohup git fetch --prune > /dev/null &) 2> /dev/null
    fi
}

function custom_git_remote_status() {
    # get the tracking-branch name
    remote=$(git for-each-ref --format='%(upstream:short)' $(git symbolic-ref -q HEAD))
    
    if [[ -n ${remote} ]] ; then
    	# creates global variables $1 and $2 based on left vs. right tracking
    	# inspired by @adam_spiers
    	set -- $(git rev-list --left-right --count $remote...HEAD)
    	behind=$1
    	ahead=$2

        if [ $ahead -eq 0 ] && [ $behind -gt 0 ]
        then
            echo "$ZSH_THEME_GIT_PROMPT_SEPARATOR%{$FG[255]%}$behind%{$reset_color%}$ZSH_THEME_GIT_PROMPT_BEHIND_REMOTE"
        elif [ $ahead -gt 0 ] && [ $behind -eq 0 ]
        then
            echo "$ZSH_THEME_GIT_PROMPT_SEPARATOR%{$FG[255]%}$ahead%{$reset_color%}$ZSH_THEME_GIT_PROMPT_AHEAD_REMOTE"
        elif [ $ahead -gt 0 ] && [ $behind -gt 0 ]
        then
            echo "$ZSH_THEME_GIT_PROMPT_SEPARATOR%{$FG[255]%}$behind%{$reset_color%}$ZSH_THEME_GIT_PROMPT_BEHIND_REMOTE%{$FG[255]%}$ahead%{$reset_color%}$ZSH_THEME_GIT_PROMPT_AHEAD_REMOTE"
        fi
    fi
}

function custom_git_prompt_info() {
  ref=$(git symbolic-ref HEAD 2> /dev/null) || return
  echo "$ZSH_THEME_GIT_PROMPT_PREFIX${ref#refs/heads/}$(custom_git_remote_status)${ZSH_THEME_GIT_PROMPT_SUFFIX}$(git_files_status)$(parse_git_dirty)"
}
