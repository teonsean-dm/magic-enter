# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/magic-enter
if ! typeset -f magic-enter-cmd > /dev/null; then
    function magic-enter-cmd {
        local cmd
        if [[ "$OSTYPE" == darwin* ]]; then
            cmd="exa -G"
        else
            cmd="l -I=\"bazel-*\" --no-user --no-permissions --no-time -s=type"
        fi
        echo $cmd
    }
fi

magic-enter() {
    # Only run MAGIC_ENTER commands when in PS1 and command line is empty
    # http://zsh.sourceforge.net/Doc/Release/Zsh-Line-Editor.html#User_002dDefined-Widgets
    if [[ -n "$BUFFER" || "$CONTEXT" != start ]]; then
        return
    fi
    BUFFER=$(magic-enter-cmd)
}

# Wrapper for the accept-line zle widget (run when pressing Enter)

# If the wrapper already exists don't redefine it
(( ! ${+functions[_magic-enter_accept-line]} )) || return 0

case "$widgets[accept-line]" in
    # Override the current accept-line widget, calling the old one
    user:*) zle -N _magic-enter_orig_accept-line "${widgets[accept-line]#user:}"
        function _magic-enter_accept-line() {
            magic-enter
            zle _magic-enter_orig_accept-line -- "$@"
        } ;;
    # If no user widget defined, call the original accept-line widget
    builtin) function _magic-enter_accept-line() {
            magic-enter
            zle .accept-line
        } ;;
esac

# zle -N accept-line _magic-enter_accept-line
bindkey '^@' magic-enter-cmd
