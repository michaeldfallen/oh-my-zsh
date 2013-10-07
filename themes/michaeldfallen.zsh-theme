PROMPT='$(custom_update_remotes)%{$fg_bold[red]%}➜%{$fg_bold[green]%}%p %{$fg[cyan]%}%c $(custom_git_prompt_info)%{$fg_bold[blue]%}% %{$reset_color%}'

ZSH_THEME_RESET_COLOR="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_PREFIX="%{$FG[243]%}git:(%{$reset_color%}"
ZSH_THEME_GIT_BRANCH_PREFIX="%{$FG[249]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$FG[243]%})%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[red]%}✗%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[green]%}✓%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_UNSTAGED_COLOR="%{$FG[203]%}"
ZSH_THEME_GIT_PROMPT_STAGED_COLOR="%{$FG[155]%}"
ZSH_THEME_GIT_PROMPT_UNTRACKED_COLOR="%{$FG[252]%}"
ZSH_THEME_GIT_PROMPT_NOT_TRACKING="%{$FG[220]%}⌁%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_ADDED="A"
ZSH_THEME_GIT_PROMPT_DELETED="D"
ZSH_THEME_GIT_PROMPT_MODIFIED="M"
ZSH_THEME_GIT_PROMPT_UNTRACKED="U"
ZSH_THEME_GIT_PROMPT_CONFLICTED="C"
ZSH_THEME_GIT_PROMPT_RENAMED="R"
ZSH_THEME_GIT_PROMPT_MASTER="${ZSH_THEME_GIT_BRANCH_PREFIX}𝘮 %{$reset_color%}" 

ZSH_GIT_MASTER_BRANCH="master"

#ZSH_THEME_GIT_PROMPT_SEPARATOR="%{$FG[243]%}|%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_SEPARATOR="%{$FG[243]%} %{$reset_color%}"
ZSH_THEME_GIT_REMOTE_DIVERGED_MASTER="%{$FG[220]%}\xe2\x87\x86%{$reset_color%}"
ZSH_THEME_GIT_REMOTE_BEHIND_MASTER="%{$FG[039]%} \xe2\x86\x92 %{$reset_color%}"
ZSH_THEME_GIT_REMOTE_AHEAD_MASTER="%{$FG[166]%}\xe2\x86\x90 %{$reset_color%}"
ZSH_THEME_GIT_PROMPT_BEHIND_REMOTE="%{$FG[039]%}↓%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_AHEAD_REMOTE="%{$FG[166]%}↑%{$reset_color%}"

function tracking() {
  echo tracking $ZSH_GIT_MASTER_BRANCH
}

function track() {
  branch=$1
  if [[ -n $branch ]]; then 
    export ZSH_GIT_MASTER_BRANCH="$branch"
  fi
  tracking
}

function resettracking() {
  track master
}

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

function git_staged_status {
  gitStatus=$1
  modified="$(echo "$gitStatus" | grep -p "M[A|M|C|D|U|R ] " | wc -l | grep -oEi '[1-9][0-9]*')"
  added="$(echo "$gitStatus" | grep -p "A[A|M|C|D|U|R ] " | wc -l | grep -oEi '[1-9][0-9]*')"
  deleted="$(echo "$gitStatus" | grep -p "D[A|M|C|D|U|R ] " | wc -l | grep -oEi '[1-9][0-9]*')"
  renamed="$(echo "$gitStatus" | grep -p "R[A|M|C|D|U|R ] " | wc -l | grep -oEi '[1-9][0-9]*')"
  conflicted="$(echo "$gitStatus" | grep -p "U[A|M|C|D|U|R ] " | wc -l | grep -oEi '[1-9][0-9]*')"

  if [ -n "$added" ]; then
    echo -n "$added$ZSH_THEME_GIT_PROMPT_ADDED"
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
  if [ -n "$renamed" ]; then
    echo -n "$renamed$ZSH_THEME_GIT_PROMPT_RENAMED"
  fi
}

function git_unstaged_status {
  gitStatus=$1
  modified="$(echo "$gitStatus" | grep -p "[A|M|C|D|U|R ]M " | wc -l | grep -oEi '[1-9][0-9]*')"
  added="$(echo "$gitStatus" | grep -p "[A|M|C|D|U|R ]A " | wc -l | grep -oEi '[1-9][0-9]*')"
  deleted="$(echo "$gitStatus" | grep -p "[A|M|C|D|U|R ]D " | wc -l | grep -oEi '[1-9][0-9]*')"
  renamed="$(echo "$gitStatus" | grep -p "[A|M|C|D|U|R ]R " | wc -l | grep -oEi '[1-9][0-9]*')"
  conflicted="$(echo "$gitStatus" | grep -p "[A|M|C|D|U|R ]U " | wc -l | grep -oEi '[1-9][0-9]*')" 

  if [ -n "$added" ]; then
    echo -n "$added$ZSH_THEME_GIT_PROMPT_ADDED"
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
  if [ -n "$renamed" ]; then
    echo -n "$renamed$ZSH_THEME_GIT_PROMPT_RENAMED"
  fi
}

function git_untracked_status {
  gitStatus=$1
  untracked="$(echo "$gitStatus" | grep -p "?? " | wc -l | grep -oEi '[1-9][0-9]*')" 
 
  if [ -n "$untracked" ]; then
    echo -n "$untracked$ZSH_THEME_GIT_PROMPT_UNTRACKED"
  fi
}

function git_files_status {
  statS=$(git status --porcelain 2>/dev/null)
  stagedChanges="$(git_staged_status $statS)"
  unstagedChanges="$(git_unstaged_status $statS)"
  untrackedChanges="$(git_untracked_status $statS)"
  changes="$stagedChanges$unstagedChanges$untrackedChanges"
  if [ -n "$changes" ]; then
    echo -n "$ZSH_THEME_GIT_PROMPT_SEPARATOR"

    echo -n "$ZSH_THEME_GIT_PROMPT_STAGED_COLOR$stagedChanges$ZSH_THEME_RESET_COLOR"
    echo -n "$ZSH_THEME_GIT_PROMPT_UNSTAGED_COLOR$unstagedChanges$ZSH_THEME_RESET_COLOR"
    echo -n "$ZSH_THEME_GIT_PROMPT_UNTRACKED_COLOR$untrackedChanges$ZSH_THEME_RESET_COLOR"
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

function custom_git_remote_vs_master_status() {
  remote=$1
  master=$2

  if [[ -n $remote ]] && [[ -n $master ]] ; then
    # creates global variables $1 and $2 based on left vs. right tracking
    # inspired by @adam_spiers
    set --
    set -- $(git rev-list --left-right --count $master...$remote)
    master_behind=$1
    master_ahead=$2
    set --
    if [ $master_ahead -eq 0 ] && [ $master_behind -gt 0 ]
    then
      echo -e "$ZSH_THEME_GIT_PROMPT_MASTER%{$FG[255]%}$master_behind%{$reset_color%}$ZSH_THEME_GIT_REMOTE_BEHIND_MASTER"
    elif [ $master_ahead -gt 0 ] && [ $master_behind -eq 0 ]
    then
      echo -e "$ZSH_THEME_GIT_PROMPT_MASTER$ZSH_THEME_GIT_REMOTE_AHEAD_MASTER%{$FG[255]%}$master_ahead%{$reset_color%} "
    elif [ $master_ahead -gt 0 ] && [ $master_behind -gt 0 ]
    then
      echo -e "$ZSH_THEME_GIT_PROMPT_MASTER%{$FG[255]%}$master_behind%{$reset_color%}$ZSH_THEME_GIT_REMOTE_DIVERGED_MASTER%{$FG[255]%}$master_ahead%{$reset_color%} "
    fi
  else 
    echo -e "$ZSH_THEME_GIT_PROMPT_MASTER$ZSH_THEME_GIT_PROMPT_NOT_TRACKING "
  fi
}

function custom_git_remote_status() {
  remote=$1
  
  if [[ -n $remote ]] ; then
    # creates global variables $1 and $2 based on left vs. right tracking
    # inspired by @adam_spiers
    set --
    set -- $(git rev-list --left-right --count $remote...HEAD)
    behind=$1
    ahead=$2
    set --
    
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

function git_this_branch() {
  remote=$(git for-each-ref --format='%(refname:short)' $(git symbolic-ref -q HEAD))
  echo $remote
}


function custom_git_prompt_info() {
  ref=$(git symbolic-ref HEAD 2> /dev/null) || return

  master=$(git for-each-ref --format='%(upstream:short)' | grep $ZSH_GIT_MASTER_BRANCH)
  remote=$(git for-each-ref --format='%(upstream:short)' $(git symbolic-ref -q HEAD))
  
  echo -n "$ZSH_THEME_GIT_PROMPT_PREFIX"
  echo -n "$(custom_git_remote_vs_master_status $remote $master)"
  echo -n "$ZSH_THEME_GIT_BRANCH_PREFIX${ref#refs/heads/}"
  echo -n "$(custom_git_remote_status $remote)"
  echo -n "$(git_files_status)"
  echo -n "${ZSH_THEME_GIT_PROMPT_SUFFIX}"
}
