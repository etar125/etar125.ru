#!/bin/env tclsh
# etar125's site generator v0.25.11_07
# Copyright (c) 2025 etar125
# 
# Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
# 
# THE SOFTWARE IS PROVIDED “AS IS” AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

proc usage {} {
	puts "etar125's site generator v0.25.11_07"
	puts "[info script] /path/to/site"
exit 1
}

set root [lindex $argv 0]

if {$argc != 1} { usage }
if {!([file exists $root] && [file isdirectory $root])} { usage }	

# puts [pwd]
cd $root
# puts [pwd]

if {![file exists "e1sg.conf"]} {
	puts "e1sg.conf not found"
	exit 1
}

source "e1sg.conf"

if {[file exists ".static"]} {
	file delete -force ".static"
}
file mkdir .static
foreach file [glob -nocomplain * .*] {
    if {$file == "e1sg.conf" || $file == ".static" ||
		$file == "." || $file == ".."} { continue }
    file copy -force $file .static/
}
cd .static

# Converting all .md files to .html

# proc exec_file {path} {
# 	if {[file isfile $path]} {
# 		if {[catch {exec $path} error_msg]} {
# 			puts stderr "${path} error: ${error_msg}"
# 		}
# 	} else {
# 		puts "${path} isn't a file"
# 	}
# }

proc convert_dir {dir} {
	global ignore_convert md_handler
	if {$dir != ""} {
		set proc_name [file join $dir ".convert"]
		set preproc_name [file join $dir ".preconvert"]
		set postproc_name [file join $dir ".postconvert"]
	} else {
		set proc_name ".convert"
		set preproc_name ".preconvert"
		set postproc_name ".postconvert"
	}
	
	if {[file exists $preproc_name]} {
		source $preproc_name
		file delete $preproc_name
	}

	if {[file exists $proc_name]} {
		source $proc_name
		file delete $proc_name
	} else {
		foreach f [glob -nocomplain -directory $dir -type f *.md] {
			if {[lsearch -exact $ignore_convert $f] != -1} { continue }
			if {[catch {exec {*}$md_handler $f > [file rootname $f].html} error_msg]} {
				puts "error while converting ${f}: ${error_msg}"
			}
			file delete $f
		}
	}

	if {[file exists $postproc_name]} {
		source $postproc_name
		file delete $postproc_name
	}

	foreach d [glob -nocomplain -directory $dir -type d *] {
		if {$dir != ""} {
			set dir_name [file join $dir $d]
		} else {
			set dir_name $d
		}
		if {[lsearch -exact $ignore_convert $dir_name] != -1} { continue }
		convert_dir $dir_name
	}
}

convert_dir ""

set html_menu ""

# Logo

append html_menu "<div id=\"logo\">\n"
append html_menu "<span id=\"name\">${site_name}:<<section>></span>\n"
if {[info exists site_shortdesc]} {
	append html_menu "<span id=\"desc\">${site_shortdesc}</span>\n"
}
if {[info exists site_other_text]} {
	append html_menu "<span id=\"text\">${site_other_text}</span>\n"
}
append html_menu "</div>\n"

# Navigation

append html_menu "<div id=\"nav\">
<ul>\n"

proc get_vname {vnames name} {
	foreach a $vnames {
		if {[lindex $a 0] == $name} {
			return [lindex $a 1]
		}
	}
	return file rootname [file tail $name]
}

if {![info exists html_nav_menu]} {

	## Files (*.html) and directories (*)

	foreach f [glob -nocomplain -type f *.html] {
		if {[lsearch -exact $ignore_nav $f] != -1} {continue}
		append html_menu "<li><a href=\"/$f\">[get_vname $aliases $f]</a>
	<!--/$f-->
	</li>\n"
	}

	foreach d [glob -nocomplain -type d *] {
		if {[lsearch -exact $ignore_nav $d] != -1} {continue}
		append html_menu "<li><a href=\"/$d/\">[get_vname $aliases $d]</a>
	<!--/$d/-->
	</li>\n"
	}
} else { append html_menu $html_nav_menu }
append html_menu "</ul>\n</div>\n"

set html_body "<!DOCTYPE html>
<html>
<head>
<meta charset=\"UTF-8\"/>
<title>${site_name}:<<section>></title>
<link rel=\"stylesheet\" type=\"text/css\" href=\"/style.css\"/>
</head>
<body>
${html_menu}
<div id=\"main\">
<<main>>
</div>
</body>
</html>
"


set html_menu_bak {}

proc process_dir {dir} {
	global ignore_process md_handler html_body html_menu aliases html_menu_bak
	if {$dir != ""} {
		set preproc_name [file join $dir ".preprocess"]
		set postproc_name [file join $dir ".postprocess"]
		set conf_name [file join $dir ".conf"]
	} else {
		set preproc_name ".preprocess"
		set postproc_name ".postprocess"
		set conf_name ".conf"
	}
	
	if {[file exists $preproc_name]} {
		source $preproc_name
		file delete $preproc_name
	}
	
	set new_aliases {}
	
	if {[file exists $conf_name]} {
		source $conf_name
		file delete $conf_name
	}

	foreach f [glob -nocomplain -directory $dir -type f *.html] {
		puts "processing file ${f}"
		if {[lsearch -exact $ignore_process $f] != -1} { continue }
		set fp [open $f r]
		set data [read $fp]
		close $fp
		set new_data $html_body
		set c_aliases [list {*}$aliases {*}$new_aliases]
		set vname [get_vname $c_aliases $f]
		set new_data [string map [list "<<section>>" $vname "<<main>>" ${data}] $new_data]
		set fp [open $f w]
		puts -nonewline $fp $new_data
		close $fp
	}

	if {[file exists $postproc_name]} {
		source $postproc_name
		file delete $postproc_name
	}

	foreach d [glob -nocomplain -directory $dir -type d *] {
		if {$dir != ""} {
			set dir_name [file join $dir $d]
		} else {
			set dir_name $d
		}
		if {[lsearch -exact $ignore_process $dir_name] != -1} { continue }
		process_dir $dir_name
	}
	if {[llength $html_menu_bak] != 0} {
		set html_menu [lindex $html_menu_bak end]
		set html_menu_bak [lrange $html_menu_bak 0 end-1]
	}
}

process_dir ""

# foreach f [concat [glob -nocomplain -tails -path [file join * *] *.html] [glob -nocomplain -type f *.html]] {
# 	puts "processing file ${f}"
# 	if {[lsearch -exact $ignore $f] != -1} { continue }
# 	set fp [open $f r]
# 	set data [read $fp]
# 	close $fp
# 	set new_data $html_body
# 	set new_data [string map [list "<<section>>" [get_vname $aliases $f] "<<main>>" ${data}] $new_data]
# 	set fp [open $f w]
# 	puts -nonewline $fp $new_data
# 	# puts "--- old data ---\n\n${data}\n\n--- new data --- \n\n${new_data}\n\n--- end ---"
# 	close $fp
# }

if {$start_server == "yes"} {
	puts "starting server"
	exec {*}$server_cmd
}
