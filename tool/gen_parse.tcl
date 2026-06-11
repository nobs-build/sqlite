set lemon [lindex $argv 0]
set root [lindex $argv 1]

file mkdir [file join $root generated]
file copy -force [file join $root src parse.y] [file join $root generated parse.y]

exec $lemon -T[file join $root tool lempar.c] [file join $root generated parse.y]
