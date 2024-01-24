HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
bindkey -e
# completions
zstyle :compinstall filename $HOME/.zshrc
zstyle ':completion:*' menu select

# End of lines added by compinstall
setopt COMPLETE_ALIASES
setopt PROMPT_SUBST

autoload -Uz compinit
compinit
autoload -Uz bashcompinit
bashcompinit
unsetopt autocd

test -f $HOME/.aliases && source $HOME/.aliases
test -f $HOME/.envvars && source $HOME/.envvars
test -f $HOME/.zshrc_settings && source $HOME/.zshrc_settings
test -f $HOME/.addr_settings && source $HOME/.addr_settings

isWsl=false
if [[ $(grep -i microsoft /proc/version) ]]; then
    isWsl=true
    test -d "/mnt/c/Users/$WIN_USER" && export WINHOME="/mnt/c/Users/$WIN_USER"

    # Running in WSL
    # checks to see if we are in a windows or linux dir
    function isWinDir {
      case $PWD/ in
        /mnt/*) return $(true);;
        *) return $(false);;
      esac
    }

    # wrap the git command to either run windows git or linux
    native_git_exec=$(which git)
    function git {
        if isWinDir; then
            git.exe "$@"
        else
            $native_git_exec "$@"
        fi
    }
else
    function isWinDir {
        $(false)
    }
fi

function parse_git_dirty {
  if [[ $(git status --porcelain 2> /dev/null) ]]; then
          echo " *"
  else
          echo ""
  fi
}
function parse_git_branch {
        git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/[\1$(parse_git_dirty)]/"
}

if [ -f "$ZSH_GIT_PROMPT_REPO/zshrc.sh" ]; then
    source "$ZSH_GIT_PROMPT_REPO/zshrc.sh"

    if [ "${ZSH_GIT_PROMPT_USE_SIMPLE_SYMBOLS}" -eq "1" ]; then
        # see https://www.compart.com/en/unicode/U+2715
        ZSH_THEME_GIT_PROMPT_CONFLICTS="%{$fg[red]%}%{\u2715%G%}"
        ZSH_THEME_GIT_PROMPT_CHANGED="%{$fg[blue]%}%{+%G%}"
        # see https://en.wikipedia.org/wiki/Geometric_Shapes_(Unicode_block)
        ZSH_THEME_GIT_PROMPT_STASHED="%{$fg[blue]%}%{\u25b3%G%}"

        # see https://en.wikipedia.org/wiki/Check_mark
        ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[green]%}\u2713"
    fi

    function git_st_wrapper {
        if isWinDir; then
            parse_git_branch
        else
            git_super_status
        fi;
    }
else
    alias git_st_wrapper=parse_git_branch
fi

PROMPT='%F{cyan}%n%f@%F{cyan}%M%f:%F{green}%~%f %F{magenta}$(git_st_wrapper)%f
%# '

#RPROMPT='$(git_super_status)'

alias ls='ls --color=auto'
alias rm='rm -i'
alias mv='mv -i'
alias help='man'

#just for lolz + dysphoria purposes
alias woman='man'
alias girl='man'

alias gb='git branch --show-current 2>/dev/null'
alias ll='ls -l'
alias llh='ls -lh'

export PATH=$HOME/bin:$PATH:$HOME/.local/bin

bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word
bindkey '^H' backward-kill-word
bindkey '5~' kill-word

# force poweroff
alias fpoweroff='systemctl poweroff -i'
alias freboot='systemctl reboot -i'

test -d $HOME/Dropbox && export DROPBOX=$HOME/Dropbox
# opam configuration
test -r $HOME/.opam/opam-init/init.zsh && . $HOME/.opam/opam-init/init.zsh > /dev/null 2> /dev/null || true

# vcpkg
if [ -d "$VCPKG_ROOT" ]; then
    export PATH=$PATH:$VCPKG_ROOT
    source "$VCPKG_ROOT/scripts/vcpkg_completion.zsh"
fi
