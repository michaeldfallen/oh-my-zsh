PROMPT='%{$fg_bold[red]%}➜ %{$fg_bold[green]%}%p %{$fg[cyan]%}%c %{$FG[237]%}$(custom_git_prompt_info)$(custom_git_remote_status)%{$fg_bold[blue]%} % %{$reset_color%}'

ZSH_THEME_GIT_PROMPT_PREFIX="git:(%{$FG[243]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$FG[237]%}) %{$fg[red]%}✗%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$FG[237]%}) %{$fg[green]%}✓%{$reset_color%}"

ZSH_THEME_GIT_PROMPT_BEHIND_REMOTE="%{$fg_bold[magenta]%}↓%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_AHEAD_REMOTE="%{$fg_bold[magenta]%}↑%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIVERGED_REMOTE="%{$fg_bold[magenta]%}↕%{$reset_color%}"


function custom_git_dirty() {
  if [ -n "$(is_git_dirty)" ]; then 
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
    remote=${$(git rev-parse --verify ${hook_com[branch]}@{upstream} --symbolic-full-name 2>/dev/null)/refs\/remotes\/}
    if [[ -n ${remote} ]] ; then
        ahead=$(echo $(git rev-list ${hook_com[branch]}@{upstream}..HEAD 2>/dev/null | wc -l) | xargs)
        behind=$(echo $(git rev-list HEAD..${hook_com[branch]}@{upstream} 2>/dev/null | wc -l) | xargs)

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
  echo "$ZSH_THEME_GIT_PROMPT_PREFIX${ref#refs/heads/}$(git_dirty)${ZSH_THEME_GIT_PROMPT_SUFFIX}"
}
