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

function fish_prompt
	echo -n (hostname)
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
	set_color --bold blue
	echo '» '
end

function fish_right_prompt
  __theme_hashiline
end
