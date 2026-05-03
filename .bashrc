export BAT_THEME="OneHalfDark"
export FZF_DEFAULT_OPTS="--color=bg+:#151515,bg:#0a0a0f,spinner:#888888,hl:#ffffff,fg:#999999,header:#888888,info:#777777,pointer:#ffffff,marker:#ff8800,fg+:#ffffff,prompt:#888888,hl+:#ffffff"
export LS_COLORS="di=38;5;248:ex=38;5;255:ln=38;5;208:pi=38;5;245:so=38;5;245:bd=38;5;248:cd=38;5;248:or=38;5;208"

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias diff='diff --color=auto'

PS1='\[\e[38;5;255m\]\u\[\e[0m\]@\[\e[38;5;245m\]\h\[\e[0m\]:\[\e[38;5;248m\]\w\[\e[0m\] \[\e[38;5;208m\]>\[\e[0m\] '
