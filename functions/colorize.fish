function colorize --argument-names 'color' 'pattern'
  ack --passthru --color --flush --color-match $color $pattern
end

