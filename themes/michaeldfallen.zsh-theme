PROMPT='%{$fg_bold[red]%}➜ %{$fg_bold[green]%}%p %{$fg[cyan]%}%c %{$FG[237]%}$(custom_git_prompt_info)%{$fg_bold[blue]%} % %{$reset_color%}'

LAST_UPDATE=0

ZSH_THEME_GIT_PROMPT_PREFIX="git:(%{$FG[243]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$FG[237]%}) %{$fg[red]%}✗%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$FG[237]%}) %{$fg[green]%}✓%{$reset_color%}"

ZSH_THEME_GIT_PROMPT_BEHIND_REMOTE="%{$fg_bold[magenta]%}↓%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_AHEAD_REMOTE="%{$fg_bold[magenta]%}↑%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIVERGED_REMOTE="%{$fg_bold[magenta]%}↕%{$reset_color%}"


function custom_git_dirty() {
  if [ -n "$(custom_is_git_dirty)" ]; then 
    echo "$ZSH_THEME_GIT_PROMPT_DIRTY"
  else
    echo "$ZSH_THEME_GIT_PROMPT_CLEAN"
  fi
}

function custom_is_git_dirty() {
  if [ -n "$(git ls-files --others --exclude-standard)" ]; then
    echo "untracked" 
  elif [[ -n $(git diff-index --cached --quiet HEAD -- || echo "yup") ]]; then
    echo "staged"
  fi
}

function custom_git_remote_status() {
    mins=$(date +%M)
    if [[ $(($mins - $LAST_UPDATE)) -gt "300000" ]] ; then 
 	LAST_UPDATE=$mins
	echo "\nRefreshing remotes"
        nohup git fetch > /dev/null &
    fi
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
            echo " $behind$ZSH_THEME_GIT_PROMPT_BEHIND_REMOTE"
        elif [ $ahead -gt 0 ] && [ $behind -eq 0 ]
        then
            echo " $ahead$ZSH_THEME_GIT_PROMPT_AHEAD_REMOTE"
        elif [ $ahead -gt 0 ] && [ $behind -gt 0 ]
        then
            echo " $behind$ZSH_THEME_GIT_PROMPT_BEHIND_REMOTE $ahead$ZSH_THEME_GIT_PROMPT_AHEAD_REMOTE"
        fi
    fi
}

function custom_git_prompt_info() {
  ref=$(git symbolic-ref HEAD 2> /dev/null) || return
  echo "$ZSH_THEME_GIT_PROMPT_PREFIX${ref#refs/heads/}$(parse_git_dirty)${ZSH_THEME_GIT_PROMPT_SUFFIX}$(custom_git_remote_status)"
}
