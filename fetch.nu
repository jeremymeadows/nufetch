let config = open ~/Projects/nufetch/config | from toml

let functs = {
  user: {||
    whoami
  }
  host: {||
    (uname).nodename
  }
  distro: {||
    (sys host | select name os_version | values | str join ' ')
  }
  kernel: {||
    (uname | select kernel-name kernel-release | values | str join ' ')
  }
  shell: {||
    "Nushell" | append (version).version | str join ' '
  }
  terminal: {||
    $env.TERM
  }
  mem: {||
    (sys mem | select used total | values | str join ' / ')
  }
  cpu: {||
    (sys cpu | first).brand
  }
}

let display = $config.display | each {|field|
  let color = $config | get $field | get color
  { $"(ansi $color)($field)": $"(ansi white)(do ($functs | get $field))" }
} | reduce {|el, acc| $acc | merge $el } | table -i false | lines


let display = $display | append [
    (' ' + ([ black red green yellow blue magenta cyan light_gray ] | each {|color|
      $"(ansi $color)(char -u '2588' '2588' '2588')"
    } | str join '') + (ansi reset))
    (' ' + ([ dark_gray light_red light_green light_yellow light_blue light_magenta light_cyan white ] | each {|color|
      $"(ansi $color)(char -u '2588' '2588' '2588')"
    } | str join '') + (ansi reset))
]


let art = [
  $"(ansi blue)     ⣀⡀  (ansi cyan)⣀⣀⡀ ⢀⣀     ",
  $"(ansi blue)    ⠈⢿⣷⡀ (ansi cyan)⠈⢿⣷⣄⣾⡿⠃    ",
  $"(ansi blue)  ⢀⣶⣶⣾⣿⣿⣶⣶⣮(ansi cyan)⣻⣿⣿⠁ (ansi blue)⢠⡀  ",
  $"(ansi cyan)     ⣩⣭⡍    ⢻⣿⣆(ansi blue)⢠⣿⡗  ",
  $"(ansi cyan)⢠⣤⣤⣤⣴⣿⠟      ⠹(ansi blue)⣳⣿⣿⣤⣤⡄",
  $"(ansi cyan)⠘⠛⠛⣿⣿⢯(ansi blue)⣦      ⣰⣿⠟⠛⠛⠛⠃",
  $"(ansi cyan)  ⢼⣿⠋(ansi blue)⠹⣿⣧(ansi cyan)⢀⣀⣀⣀⣜⣛⣋⣀⣀⡀  ",
  $"(ansi cyan)  ⠈⠃ (ansi blue)⢀⣾⣿⣷(ansi cyan)⡻⠿⠿⢿⣿⡿⠿⠿⠁  ",
  $"(ansi blue)    ⢠⣾⡿⠙⢿⣷⡀ (ansi cyan)⠈⢿⣷⡄    ",
  $"(ansi blue)     ⠉⠁ ⠈⠉⠉  (ansi cyan)⠈⠉     ",
]

let lines = [ ($display | length) ($art | length) ] | math max
let width = [ art.0 | length ]

for row in (seq 0 ($lines - 1)) {
  if $row < ($art | length) {
    print -n ($art | get $row)
  } else {
    print -n "                    "
  }

  if $row < ($display | length) {
    print ($display | get $row)
  } else {
    print ""
  }
}
