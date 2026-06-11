set script [lindex $argv 0]
set stdoutFile [lindex $argv 1]
set inputFiles [lindex $argv 2]
set scriptArgs [lindex $argv 3]
set mksourceid [lindex $argv 4]

if {$stdoutFile eq "-"} {
  set stdoutFile ""
}
if {$inputFiles eq "-"} {
  set inputFiles ""
}
if {$scriptArgs eq "-"} {
  set scriptArgs ""
}
if {$mksourceid eq "-"} {
  set mksourceid ""
} else {
  set mksourceid [string map {\\ /} $mksourceid]
}

proc split_list {text} {
  if {$text eq ""} {
    return {}
  }
  set result {}
  foreach item [split $text ,] {
    if {$item ne ""} {
      lappend result [string map {\\ /} $item]
    }
  }
  return $result
}

proc mkdir_for_generated_output {path} {
  if {$path eq ""} {
    return
  }
  set normalized [string map {\\ /} $path]
  if {[string match "generated/*" $normalized] || [string match "*/generated/*" $normalized]} {
    file mkdir [file dirname $path]
  }
}

set runArgs [split_list $scriptArgs]
set inputs [split_list $inputFiles]

mkdir_for_generated_output $stdoutFile
foreach item $runArgs {
  mkdir_for_generated_output $item
}

set previousDir [pwd]
if {$mksourceid ne ""} {
  cd [file dirname $mksourceid]
}

set tclsh [info nameofexecutable]
set cmd [list $tclsh $script]
foreach item $runArgs {
  lappend cmd $item
}

if {[llength $inputs] > 0} {
  set tmp [file join [pwd] nobs-tcl-input-[clock milliseconds].tmp]
  set out [open $tmp wb]
  foreach input $inputs {
    set in [open $input rb]
    puts -nonewline $out [read $in]
    close $in
  }
  close $out
  if {$stdoutFile ne ""} {
    exec {*}$cmd < $tmp > $stdoutFile
  } else {
    puts -nonewline [exec {*}$cmd < $tmp]
  }
  file delete -force $tmp
} elseif {$stdoutFile ne ""} {
  exec {*}$cmd > $stdoutFile
} else {
  set result [exec {*}$cmd]
  if {$result ne ""} {
    puts $result
  }
}

cd $previousDir
