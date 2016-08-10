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
		set -l dirty (test (count $git_status) -gt 0; and echo -n "*")
		echo -n " $argv[1]$ref$dirty$argv[2]"
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

function __theme_vault_addr
  set -l vault_addr ""
  if [ ! -z "$VAULT_ADDR" ]
    write_in_brackets $VAULT_ADDR
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
	__theme_git_prompt "‹" "›"
  set_color purple
  __theme_aws_role
	echo
	set_color --bold blue
	echo '» '
end

function fish_right_prompt
  __theme_vault_addr
end
