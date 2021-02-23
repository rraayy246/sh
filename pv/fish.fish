
if test -z $DISPLAY
    exec sway
end

if status is-interactive

    alias 1='cd -'
    alias 2='cd -2'
    alias 3='cd -3'
    alias 4='cd -4'
    alias 5='cd -5'
    alias 6='cd -6'
    alias 7='cd -7'
    alias 8='cd -8'
    alias 9='cd -9'
    alias _='sudo '

    alias g=git
    alias ga='git add'
    alias gaa='git add --all'
    alias gcmsg='git commit -m'
    alias gl='git pull'
    alias gp='git push'

    alias fu='fusermount -u ~/gz'
    alias la='ls -a'
    alias nm='nmtui-connect'
    alias nn='nnn'
    alias gx='sudo pacman -Syu'
    alias svi='sudo nvim'
    alias vi='nvim'

    function fish_prompt --description 'Informative prompt'
        #Save the return status of the previous command
        set -l last_pipestatus $pipestatus

        switch "$USER"
            case root toor
                printf '\n%s@%s %s%s%s# ' $USER (prompt_hostname) (set -q fish_color_cwd_root
                                                                 and set_color $fish_color_cwd_root
                                                                 or set_color $fish_color_cwd) \
                    (prompt_pwd) (set_color normal)
            case '*'
                set -l pipestatus_string (__fish_print_pipestatus "[" "] " "|" (set_color $fish_color_status) \
                                          (set_color --bold $fish_color_status) $last_pipestatus)

                printf '\n[%s] %s%s@%s %s%s %s%s%s \f\r> ' (date "+%H:%M:%S") (set_color brblue) \
                    $USER (prompt_hostname) (set_color $fish_color_cwd) $PWD $pipestatus_string \
                    (set_color normal)
        end
    end

end