function write_in_brackets
    echo -n " ‹"$argv[1]"›"
end

function __theme_short_pwd
    pwd | sed -e 's>'"$HOME"'>~>' | tr / \n | tac | head -n 3 | tac | tr \n / | sed -e 's/\/$//'
end

function __theme_git_prompt
    set -l git_status (git status -z --porcelain 2>&1)
    if test $status -eq 0
        set -l raw_ref (command git symbolic-ref HEAD 2> /dev/null; or command git rev-parse --short HEAD 2> /dev/null)
        set -l ref (echo -n $raw_ref | sed -e 's|refs/heads/||')
        set -l dirty (test (count $git_status) -gt 0; and echo -n "●")
        set -l cistatus ""
        if [ ! -z "$FISH_GITHUB_STATUS" ]
            set cistatus (__theme_github_status)
        end
        echo -n " $argv[1]$ref $dirty$cistatus$argv[2]"
    end
end

function __theme_date
    echo -n "["(date '+%H:%M:%S')"]"
end

function __theme_aws_env
    if [ ! -z "$AWS_VAULT" ]
        echo -n " ‹"$AWS_VAULT"›"
    end
end

function __theme_terraform_env
    set -l env_file .terraform/environment
    if [ -e $env_file ]
        set terraform_env (cat $env_file)
    end

    if [ ! -z "$terraform_env" ]
        echo -n " ‹"$terraform_env"›"
    end
end

function __theme_aws_role
    set -l config_file ~/.config/aws/last_assumed_role
    if [ ! -z "$AWS_ASSUMED_ROLE" ]
        set aws_role $AWS_ASSUMED_ROLE
    else if [ -e $config_file ]
        set aws_role (cat $config_file)
    end

    if [ ! -z "$aws_role" ]
        echo -n " ‹"$aws_role"›"
    end
end

function __theme_kubernetes
    [ -z "$KUBECTL_PROMPT_ICON" ]
    and set -l KUBECTL_PROMPT_ICON "⎈"
    [ -z "$KUBECTL_PROMPT_SEPARATOR" ]
    and set -l KUBECTL_PROMPT_SEPARATOR "/"
    set -l config $KUBECONFIG
    [ -z "$config" ]
    and set -l config "$HOME/.kube/config"
    if [ ! -f $config ]
        echo (set_color red)$KUBECTL_PROMPT_ICON" "(set_color white)"no config"
        return
    end
    set -l ctx (kubectl config current-context 2>/dev/null)
    if [ $status -ne 0 ]
        echo (set_color red)$KUBECTL_PROMPT_ICON" "(set_color white)"no context"
        return
    end

    set -l ns (kubectl config view -o "jsonpath={.contexts[?(@.name==\"$ctx\")].context.namespace}")
    [ -z $ns ]
    and set -l KUBECTL_PROMPT_SEPARATOR ""

    echo (set_color blue)$KUBECTL_PROMPT_ICON" "(set_color white)"$ctx$KUBECTL_PROMPT_SEPARATOR$ns"
end

function __theme_hashiline
    hashiline
end

function __theme_github_status
    # If hub is installed
    if type -q hub
        set -l res (git ci-status 2>&1)

        switch "$res"
            case "success"
                set_color green
                echo -n "●"
            case "pending"
                set_color orange
                echo -n "●"
            case "Aborted: the origin remote doesn't point to a GitHub repository."
                echo -n ""
            case "*"
                set_color red
                echo -n "●"
        end
    end
end

function __theme_prompt_char
    if test "$argv[1]" -eq 0
        set_color --bold blue
        echo -n '» '
    else
        set_color --bold red
        echo -n '✘ '
    end
end

function fish_prompt
    set -l last_status $status

    set_color blue
    __theme_date
    set_color --bold blue
    echo -n " :: "
    set_color normal
    set_color green
    echo -n (__theme_short_pwd)
    set_color yellow
    __theme_git_prompt "" ""
    set_color blue
    __theme_aws_env
    set_color blue
    __theme_terraform_env
    set_color purple
    __theme_aws_role
    echo
    __theme_prompt_char "$last_status"
    set_color normal
end

function fish_right_prompt
    set_color blue
    __theme_kubernetes
    set_color normal
end
