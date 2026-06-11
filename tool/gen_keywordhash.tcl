set mkkeywordhash [lindex $argv 0]
set root [lindex $argv 1]
set outFile [file join $root generated keywordhash.h]

file mkdir [file dirname $outFile]
exec $mkkeywordhash > $outFile
