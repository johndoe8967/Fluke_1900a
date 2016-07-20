
########## Tcl recorder starts at 07/04/16 21:10:26 ##########

set version "2.0"
set proj_dir "C:/Projekt/ESPFluke"
cd $proj_dir

# Get directory paths
set pver $version
regsub -all {\.} $pver {_} pver
set lscfile "lsc_"
append lscfile $pver ".ini"
set lsvini_dir [lindex [array get env LSC_INI_PATH] 1]
set lsvini_path [file join $lsvini_dir $lscfile]
if {[catch {set fid [open $lsvini_path]} msg]} {
	 puts "File Open Error: $lsvini_path"
	 return false
} else {set data [read $fid]; close $fid }
foreach line [split $data '\n'] { 
	set lline [string tolower $line]
	set lline [string trim $lline]
	if {[string compare $lline "\[paths\]"] == 0} { set path 1; continue}
	if {$path && [regexp {^\[} $lline]} {set path 0; break}
	if {$path && [regexp {^bin} $lline]} {set cpld_bin $line; continue}
	if {$path && [regexp {^fpgapath} $lline]} {set fpga_dir $line; continue}
	if {$path && [regexp {^fpgabinpath} $lline]} {set fpga_bin $line}}

set cpld_bin [string range $cpld_bin [expr [string first "=" $cpld_bin]+1] end]
regsub -all "\"" $cpld_bin "" cpld_bin
set cpld_bin [file join $cpld_bin]
set install_dir [string range $cpld_bin 0 [expr [string first "ispcpld" $cpld_bin]-2]]
regsub -all "\"" $install_dir "" install_dir
set install_dir [file join $install_dir]
set fpga_dir [string range $fpga_dir [expr [string first "=" $fpga_dir]+1] end]
regsub -all "\"" $fpga_dir "" fpga_dir
set fpga_dir [file join $fpga_dir]
set fpga_bin [string range $fpga_bin [expr [string first "=" $fpga_bin]+1] end]
regsub -all "\"" $fpga_bin "" fpga_bin
set fpga_bin [file join $fpga_bin]

if {[string match "*$fpga_bin;*" $env(PATH)] == 0 } {
   set env(PATH) "$fpga_bin;$env(PATH)" }

if {[string match "*$cpld_bin;*" $env(PATH)] == 0 } {
   set env(PATH) "$cpld_bin;$env(PATH)" }

lappend auto_path [file join $install_dir "ispcpld" "tcltk" "lib" "ispwidget" "runproc"]
package require runcmd

# Commands to make the Process: 
# Synplify Synthesize VHDL File
if [catch {open I2C_slave.cmd w} rspFile] {
	puts stderr "Cannot create response file I2C_slave.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: I2C_slave
VHDL_FILE_LIST: i2c_slave.vhd
OUTPUT_FILE_NAME: I2C_slave
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e I2C_slave -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete I2C_slave.cmd

########## Tcl recorder end at 07/04/16 21:10:26 ###########


########## Tcl recorder starts at 07/04/16 21:11:19 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "I2C_slave.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj I2C_slave -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1024-80LJ68 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1024-80LJ68 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1024-80LJ68 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/04/16 21:11:19 ###########


########## Tcl recorder starts at 07/04/16 21:12:25 ##########

# Commands to make the Process: 
# Timing Analysis
if [runCmd "\"$cpld_bin/synta\" -proj espfluke -pd \"$proj_dir\" -dpm_only "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/04/16 21:12:25 ###########


########## Tcl recorder starts at 07/04/16 21:13:27 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/04/16 21:13:27 ###########


########## Tcl recorder starts at 07/04/16 21:20:31 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/04/16 21:20:31 ###########


########## Tcl recorder starts at 07/04/16 21:21:49 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/04/16 21:21:49 ###########


########## Tcl recorder starts at 07/04/16 21:22:21 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/04/16 21:22:21 ###########


########## Tcl recorder starts at 07/04/16 21:25:39 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/04/16 21:25:39 ###########


########## Tcl recorder starts at 07/04/16 21:25:58 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/04/16 21:25:58 ###########


########## Tcl recorder starts at 07/04/16 21:26:32 ##########

# Commands to make the Process: 
# Synplify Synthesize VHDL File
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd

########## Tcl recorder end at 07/04/16 21:26:32 ###########


########## Tcl recorder starts at 07/04/16 21:26:58 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1024-80LJ68 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1024-80LJ68 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1024-80LJ68 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/04/16 21:26:58 ###########


########## Tcl recorder starts at 07/04/16 21:29:21 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/04/16 21:29:21 ###########


########## Tcl recorder starts at 07/04/16 21:29:25 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1024-80LJ68 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1024-80LJ68 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1024-80LJ68 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/04/16 21:29:25 ###########


########## Tcl recorder starts at 07/04/16 21:29:54 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/04/16 21:29:54 ###########


########## Tcl recorder starts at 07/04/16 21:29:57 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1024-80LJ68 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1024-80LJ68 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1024-80LJ68 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/04/16 21:29:57 ###########


########## Tcl recorder starts at 07/04/16 21:31:18 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/04/16 21:31:18 ###########


########## Tcl recorder starts at 07/04/16 21:31:22 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1024-80LJ68 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1024-80LJ68 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1024-80LJ68 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/04/16 21:31:22 ###########


########## Tcl recorder starts at 07/04/16 21:33:31 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/04/16 21:33:31 ###########


########## Tcl recorder starts at 07/04/16 21:33:35 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/04/16 21:33:35 ###########


########## Tcl recorder starts at 07/04/16 21:33:38 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1024-80LJ68 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1024-80LJ68 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1024-80LJ68 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/04/16 21:33:38 ###########


########## Tcl recorder starts at 07/04/16 21:36:47 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/04/16 21:36:47 ###########


########## Tcl recorder starts at 07/04/16 21:44:16 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/04/16 21:44:16 ###########


########## Tcl recorder starts at 07/04/16 21:44:24 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1024-80LJ68 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1024-80LJ68 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1024-80LJ68 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/04/16 21:44:24 ###########


########## Tcl recorder starts at 07/04/16 21:45:03 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/04/16 21:45:03 ###########


########## Tcl recorder starts at 07/04/16 21:45:05 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1024-80LJ68 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1024-80LJ68 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1024-80LJ68 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/04/16 21:45:05 ###########


########## Tcl recorder starts at 07/04/16 21:45:36 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/04/16 21:45:36 ###########


########## Tcl recorder starts at 07/04/16 21:45:45 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/04/16 21:45:45 ###########


########## Tcl recorder starts at 07/04/16 21:45:48 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1024-80LJ68 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1024-80LJ68 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1024-80LJ68 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/04/16 21:45:48 ###########


########## Tcl recorder starts at 07/04/16 21:49:34 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/04/16 21:49:34 ###########


########## Tcl recorder starts at 07/04/16 21:49:38 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1024-80LJ68 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1024-80LJ68 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1024-80LJ68 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/04/16 21:49:38 ###########


########## Tcl recorder starts at 07/04/16 21:51:07 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/04/16 21:51:07 ###########


########## Tcl recorder starts at 07/04/16 21:51:10 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1024-80LJ68 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1024-80LJ68 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1024-80LJ68 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/04/16 21:51:10 ###########


########## Tcl recorder starts at 07/04/16 21:54:40 ##########

# Commands to make the Process: 
# Timing Analysis
if [runCmd "\"$cpld_bin/synta\" -proj espfluke -pd \"$proj_dir\" -dpm_only "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/04/16 21:54:40 ###########


########## Tcl recorder starts at 07/04/16 21:56:12 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/04/16 21:56:12 ###########


########## Tcl recorder starts at 07/04/16 21:58:11 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/04/16 21:58:11 ###########


########## Tcl recorder starts at 07/04/16 21:58:18 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1024-80LJ68 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1024-80LJ68 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1024-80LJ68 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/04/16 21:58:18 ###########


########## Tcl recorder starts at 07/04/16 21:58:44 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/04/16 21:58:44 ###########


########## Tcl recorder starts at 07/04/16 21:58:55 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1024-80LJ68 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1024-80LJ68 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1024-80LJ68 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/04/16 21:58:55 ###########


########## Tcl recorder starts at 07/04/16 22:00:15 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"i2c_slave.vhd\" -o \"i2c_slave.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/04/16 22:00:15 ###########


########## Tcl recorder starts at 07/04/16 22:00:36 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"i2c_slave.vhd\" -o \"i2c_slave.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/04/16 22:00:36 ###########


########## Tcl recorder starts at 07/04/16 22:00:57 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/04/16 22:00:57 ###########


########## Tcl recorder starts at 07/04/16 22:01:23 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/04/16 22:01:23 ###########


########## Tcl recorder starts at 07/04/16 22:02:14 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/04/16 22:02:14 ###########


########## Tcl recorder starts at 07/04/16 22:02:21 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1024-80LJ68 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1024-80LJ68 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1024-80LJ68 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/04/16 22:02:21 ###########


########## Tcl recorder starts at 07/04/16 22:02:45 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/04/16 22:02:45 ###########


########## Tcl recorder starts at 07/04/16 22:02:51 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1024-80LJ68 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1024-80LJ68 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1024-80LJ68 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/04/16 22:02:51 ###########


########## Tcl recorder starts at 07/04/16 22:04:47 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/04/16 22:04:47 ###########


########## Tcl recorder starts at 07/04/16 22:04:52 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1024-80LJ68 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1024-80LJ68 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1024-80LJ68 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/04/16 22:04:52 ###########


########## Tcl recorder starts at 07/04/16 22:05:26 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/04/16 22:05:26 ###########


########## Tcl recorder starts at 07/04/16 22:05:29 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1024-80LJ68 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1024-80LJ68 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1024-80LJ68 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/04/16 22:05:29 ###########


########## Tcl recorder starts at 07/04/16 22:07:16 ##########

# Commands to make the Process: 
# Timing Analysis
if [runCmd "\"$cpld_bin/synta\" -proj espfluke -pd \"$proj_dir\" -dpm_only "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/04/16 22:07:16 ###########


########## Tcl recorder starts at 07/04/16 22:29:10 ##########

# Commands to make the Process: 
# Generate Schematic Symbol
if [runCmd "\"$cpld_bin/naf2sym\" \"espfluke\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/04/16 22:29:10 ###########


########## Tcl recorder starts at 07/04/16 22:48:33 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/04/16 22:48:33 ###########


########## Tcl recorder starts at 07/04/16 22:48:40 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1024-80LJ68 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1024-80LJ68 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1024-80LJ68 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/04/16 22:48:40 ###########


########## Tcl recorder starts at 07/06/16 21:37:48 ##########

# Commands to make the Process: 
# Constraint Editor
# - none -
# Application to view the Process: 
# Constraint Editor
if [catch {open ce.rsp w} rspFile] {
	puts stderr "Cannot create response file ce.rsp: $rspFile"
} else {
	puts $rspFile "-devfile \"$install_dir/ispcpld/data/lc1k/l1024_68j.dev\"
-lci espfluke.lct
-touch espfluke.ir0
-src espfluke.emf
-type EDIF
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @ce.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/06/16 21:37:48 ###########


########## Tcl recorder starts at 07/06/16 21:39:23 ##########

# Commands to make the Process: 
# Constraint Editor
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
# Application to view the Process: 
# Constraint Editor
if [catch {open ce.rsp w} rspFile] {
	puts stderr "Cannot create response file ce.rsp: $rspFile"
} else {
	puts $rspFile "-devfile \"$install_dir/ispcpld/data/lc1k/le1032_84j.dev\"
-lci espfluke.lct
-touch espfluke.ir0
-src espfluke.emf
-type EDIF
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @ce.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/06/16 21:39:23 ###########


########## Tcl recorder starts at 07/06/16 21:41:17 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/06/16 21:41:17 ###########


########## Tcl recorder starts at 07/06/16 21:42:33 ##########

# Commands to make the Process: 
# Timing Analysis
if [runCmd "\"$cpld_bin/synta\" -proj espfluke -pd \"$proj_dir\" -dpm_only "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/06/16 21:42:33 ###########


########## Tcl recorder starts at 07/06/16 21:43:51 ##########

# Commands to make the Process: 
# Constraint Editor
# - none -
# Application to view the Process: 
# Constraint Editor
if [catch {open ce.rsp w} rspFile] {
	puts stderr "Cannot create response file ce.rsp: $rspFile"
} else {
	puts $rspFile "-devfile \"$install_dir/ispcpld/data/lc1k/le1032_84j.dev\"
-lci espfluke.lct
-touch espfluke.ir0
-src espfluke.emf
-type EDIF
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @ce.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/06/16 21:43:51 ###########


########## Tcl recorder starts at 07/06/16 21:48:53 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/06/16 21:48:53 ###########


########## Tcl recorder starts at 07/10/16 10:29:18 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 10:29:18 ###########


########## Tcl recorder starts at 07/10/16 10:29:28 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 10:29:28 ###########


########## Tcl recorder starts at 07/10/16 10:29:41 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 10:29:41 ###########


########## Tcl recorder starts at 07/10/16 10:29:47 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 10:29:47 ###########


########## Tcl recorder starts at 07/10/16 10:37:09 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"i2c_slave.vhd\" -o \"i2c_slave.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 10:37:09 ###########


########## Tcl recorder starts at 07/10/16 10:37:50 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 10:37:50 ###########


########## Tcl recorder starts at 07/10/16 10:38:00 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 10:38:00 ###########


########## Tcl recorder starts at 07/10/16 10:38:23 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 10:38:23 ###########


########## Tcl recorder starts at 07/10/16 10:39:57 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 10:39:57 ###########


########## Tcl recorder starts at 07/10/16 10:40:23 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 10:40:23 ###########


########## Tcl recorder starts at 07/10/16 10:40:35 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 10:40:35 ###########


########## Tcl recorder starts at 07/10/16 10:40:39 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 10:40:39 ###########


########## Tcl recorder starts at 07/10/16 10:40:42 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 10:40:42 ###########


########## Tcl recorder starts at 07/10/16 10:41:05 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 10:41:05 ###########


########## Tcl recorder starts at 07/10/16 10:41:10 ##########

# Commands to make the Process: 
# Constraint Editor
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
# Application to view the Process: 
# Constraint Editor
if [catch {open ce.rsp w} rspFile] {
	puts stderr "Cannot create response file ce.rsp: $rspFile"
} else {
	puts $rspFile "-devfile \"$install_dir/ispcpld/data/lc1k/le1032_84j.dev\"
-lci espfluke.lct
-touch espfluke.ir0
-src espfluke.emf
-type EDIF
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @ce.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 10:41:10 ###########


########## Tcl recorder starts at 07/10/16 10:41:35 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 10:41:35 ###########


########## Tcl recorder starts at 07/10/16 10:41:37 ##########

# Commands to make the Process: 
# Constraint Editor
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
# Application to view the Process: 
# Constraint Editor
if [catch {open ce.rsp w} rspFile] {
	puts stderr "Cannot create response file ce.rsp: $rspFile"
} else {
	puts $rspFile "-devfile \"$install_dir/ispcpld/data/lc1k/le1032_84j.dev\"
-lci espfluke.lct
-touch espfluke.ir0
-src espfluke.emf
-type EDIF
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @ce.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 10:41:37 ###########


########## Tcl recorder starts at 07/10/16 10:44:17 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 10:44:17 ###########


########## Tcl recorder starts at 07/10/16 10:44:27 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 10:44:27 ###########


########## Tcl recorder starts at 07/10/16 10:45:22 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 10:45:22 ###########


########## Tcl recorder starts at 07/10/16 10:46:03 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 10:46:03 ###########


########## Tcl recorder starts at 07/10/16 10:46:07 ##########

# Commands to make the Process: 
# Synplify Synthesize VHDL File
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd

########## Tcl recorder end at 07/10/16 10:46:07 ###########


########## Tcl recorder starts at 07/10/16 10:46:24 ##########

# Commands to make the Process: 
# Constraint Editor
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
# Application to view the Process: 
# Constraint Editor
if [catch {open ce.rsp w} rspFile] {
	puts stderr "Cannot create response file ce.rsp: $rspFile"
} else {
	puts $rspFile "-devfile \"$install_dir/ispcpld/data/lc1k/le1032_84j.dev\"
-lci espfluke.lct
-touch espfluke.ir0
-src espfluke.emf
-type EDIF
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @ce.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 10:46:24 ###########


########## Tcl recorder starts at 07/10/16 10:46:45 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 10:46:45 ###########


########## Tcl recorder starts at 07/10/16 10:49:44 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 10:49:44 ###########


########## Tcl recorder starts at 07/10/16 10:52:27 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 10:52:27 ###########


########## Tcl recorder starts at 07/10/16 10:52:47 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 10:52:47 ###########


########## Tcl recorder starts at 07/10/16 10:53:05 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 10:53:05 ###########


########## Tcl recorder starts at 07/10/16 10:53:09 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 10:53:09 ###########


########## Tcl recorder starts at 07/10/16 10:53:40 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 10:53:40 ###########


########## Tcl recorder starts at 07/10/16 10:53:43 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 10:53:43 ###########


########## Tcl recorder starts at 07/10/16 10:54:15 ##########

# Commands to make the Process: 
# Constraint Editor
# - none -
# Application to view the Process: 
# Constraint Editor
if [catch {open ce.rsp w} rspFile] {
	puts stderr "Cannot create response file ce.rsp: $rspFile"
} else {
	puts $rspFile "-devfile \"$install_dir/ispcpld/data/lc1k/le1032_84j.dev\"
-lci espfluke.lct
-touch espfluke.ir0
-src espfluke.emf
-type EDIF
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @ce.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 10:54:15 ###########


########## Tcl recorder starts at 07/10/16 11:01:52 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 11:01:52 ###########


########## Tcl recorder starts at 07/10/16 11:06:02 ##########

# Commands to make the Process: 
# Constraint Editor
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
# Application to view the Process: 
# Constraint Editor
if [catch {open ce.rsp w} rspFile] {
	puts stderr "Cannot create response file ce.rsp: $rspFile"
} else {
	puts $rspFile "-devfile \"$install_dir/ispcpld/data/lc1k/le1032_84j.dev\"
-lci espfluke.lct
-touch espfluke.ir0
-src espfluke.emf
-type EDIF
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @ce.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 11:06:02 ###########


########## Tcl recorder starts at 07/10/16 11:07:13 ##########

# Commands to make the Process: 
# Fitter Report
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 11:07:13 ###########


########## Tcl recorder starts at 07/10/16 11:18:31 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 11:18:31 ###########


########## Tcl recorder starts at 07/10/16 11:18:35 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 11:18:35 ###########


########## Tcl recorder starts at 07/10/16 11:19:33 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 11:19:33 ###########


########## Tcl recorder starts at 07/10/16 11:19:47 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 11:19:47 ###########


########## Tcl recorder starts at 07/10/16 11:19:52 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 11:19:52 ###########


########## Tcl recorder starts at 07/10/16 11:19:58 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 11:19:58 ###########


########## Tcl recorder starts at 07/10/16 11:22:28 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 11:22:28 ###########


########## Tcl recorder starts at 07/10/16 11:22:36 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 11:22:36 ###########


########## Tcl recorder starts at 07/10/16 11:22:39 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 11:22:39 ###########


########## Tcl recorder starts at 07/10/16 11:22:44 ##########

# Commands to make the Process: 
# Constraint Editor
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
# Application to view the Process: 
# Constraint Editor
if [catch {open ce.rsp w} rspFile] {
	puts stderr "Cannot create response file ce.rsp: $rspFile"
} else {
	puts $rspFile "-devfile \"$install_dir/ispcpld/data/lc1k/le1032_84j.dev\"
-lci espfluke.lct
-touch espfluke.ir0
-src espfluke.emf
-type EDIF
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @ce.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 11:22:44 ###########


########## Tcl recorder starts at 07/10/16 11:23:18 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 11:23:18 ###########


########## Tcl recorder starts at 07/10/16 11:27:16 ##########

# Commands to make the Process: 
# Constraint Editor
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
# Application to view the Process: 
# Constraint Editor
if [catch {open ce.rsp w} rspFile] {
	puts stderr "Cannot create response file ce.rsp: $rspFile"
} else {
	puts $rspFile "-devfile \"$install_dir/ispcpld/data/lc1k/le1032_84j.dev\"
-lci espfluke.lct
-touch espfluke.ir0
-src espfluke.emf
-type EDIF
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @ce.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 11:27:16 ###########


########## Tcl recorder starts at 07/10/16 11:27:25 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 11:27:25 ###########


########## Tcl recorder starts at 07/10/16 11:30:55 ##########

# Commands to make the Process: 
# Fitter Report
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 11:30:55 ###########


########## Tcl recorder starts at 07/10/16 11:41:00 ##########

# Commands to make the Process: 
# Constraint Editor
# - none -
# Application to view the Process: 
# Constraint Editor
if [catch {open ce.rsp w} rspFile] {
	puts stderr "Cannot create response file ce.rsp: $rspFile"
} else {
	puts $rspFile "-devfile \"$install_dir/ispcpld/data/lc1k/le1032_84j.dev\"
-lci espfluke.lct
-touch espfluke.ir0
-src espfluke.emf
-type EDIF
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @ce.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 11:41:00 ###########


########## Tcl recorder starts at 07/10/16 11:42:53 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 11:42:53 ###########


########## Tcl recorder starts at 07/10/16 11:43:52 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 11:43:52 ###########


########## Tcl recorder starts at 07/10/16 11:43:56 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 11:43:56 ###########


########## Tcl recorder starts at 07/10/16 13:23:25 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 13:23:25 ###########


########## Tcl recorder starts at 07/10/16 13:25:36 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"i2c_slave.vhd\" -o \"i2c_slave.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 13:25:36 ###########


########## Tcl recorder starts at 07/10/16 13:26:01 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 13:26:01 ###########


########## Tcl recorder starts at 07/10/16 13:48:47 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"i2c_slave.vhd\" -o \"i2c_slave.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 13:48:47 ###########


########## Tcl recorder starts at 07/10/16 13:48:54 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"i2c_slave.vhd\" -o \"i2c_slave.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 13:48:54 ###########


########## Tcl recorder starts at 07/10/16 13:49:19 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"i2c_slave.vhd\" -o \"i2c_slave.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 13:49:19 ###########


########## Tcl recorder starts at 07/10/16 13:50:08 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"i2c_slave.vhd\" -o \"i2c_slave.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 13:50:08 ###########


########## Tcl recorder starts at 07/10/16 13:50:10 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 13:50:10 ###########


########## Tcl recorder starts at 07/10/16 13:51:40 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"i2c_slave.vhd\" -o \"i2c_slave.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 13:51:40 ###########


########## Tcl recorder starts at 07/10/16 13:51:55 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 13:51:55 ###########


########## Tcl recorder starts at 07/10/16 13:58:20 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"i2c_slave.vhd\" -o \"i2c_slave.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 13:58:20 ###########


########## Tcl recorder starts at 07/10/16 13:58:22 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 13:58:22 ###########


########## Tcl recorder starts at 07/10/16 13:58:48 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"i2c_slave.vhd\" -o \"i2c_slave.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 13:58:48 ###########


########## Tcl recorder starts at 07/10/16 13:58:51 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 13:58:51 ###########


########## Tcl recorder starts at 07/10/16 14:00:56 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"i2c_slave.vhd\" -o \"i2c_slave.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 14:00:56 ###########


########## Tcl recorder starts at 07/10/16 14:00:58 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 14:00:58 ###########


########## Tcl recorder starts at 07/10/16 14:01:27 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"i2c_slave.vhd\" -o \"i2c_slave.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 14:01:27 ###########


########## Tcl recorder starts at 07/10/16 14:01:29 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 14:01:29 ###########


########## Tcl recorder starts at 07/10/16 14:05:06 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"i2c_slave.vhd\" -o \"i2c_slave.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 14:05:06 ###########


########## Tcl recorder starts at 07/10/16 14:06:14 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"i2c_slave.vhd\" -o \"i2c_slave.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 14:06:14 ###########


########## Tcl recorder starts at 07/10/16 14:06:32 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 14:06:32 ###########


########## Tcl recorder starts at 07/10/16 14:08:12 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"i2c_slave.vhd\" -o \"i2c_slave.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 14:08:12 ###########


########## Tcl recorder starts at 07/10/16 14:08:21 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 14:08:21 ###########


########## Tcl recorder starts at 07/10/16 14:10:15 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"i2c_slave.vhd\" -o \"i2c_slave.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 14:10:15 ###########


########## Tcl recorder starts at 07/10/16 14:10:18 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 14:10:18 ###########


########## Tcl recorder starts at 07/10/16 14:11:10 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"i2c_slave.vhd\" -o \"i2c_slave.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 14:11:10 ###########


########## Tcl recorder starts at 07/10/16 14:11:16 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"i2c_slave.vhd\" -o \"i2c_slave.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 14:11:16 ###########


########## Tcl recorder starts at 07/10/16 14:11:20 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 14:11:20 ###########


########## Tcl recorder starts at 07/10/16 14:14:50 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 14:14:50 ###########


########## Tcl recorder starts at 07/10/16 14:14:58 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 14:14:58 ###########


########## Tcl recorder starts at 07/10/16 14:16:12 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"i2c_slave.vhd\" -o \"i2c_slave.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 14:16:12 ###########


########## Tcl recorder starts at 07/10/16 14:16:17 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 14:16:17 ###########


########## Tcl recorder starts at 07/10/16 14:26:50 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"i2c_slave.vhd\" -o \"i2c_slave.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 14:26:50 ###########


########## Tcl recorder starts at 07/10/16 14:26:50 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 14:26:50 ###########


########## Tcl recorder starts at 07/10/16 14:28:17 ##########

# Commands to make the Process: 
# Constraint Editor
# - none -
# Application to view the Process: 
# Constraint Editor
if [catch {open ce.rsp w} rspFile] {
	puts stderr "Cannot create response file ce.rsp: $rspFile"
} else {
	puts $rspFile "-devfile \"$install_dir/ispcpld/data/lc1k/le1032_84j.dev\"
-lci espfluke.lct
-touch espfluke.ir0
-src espfluke.emf
-type EDIF
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @ce.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 14:28:17 ###########


########## Tcl recorder starts at 07/10/16 14:29:40 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 14:29:40 ###########


########## Tcl recorder starts at 07/10/16 14:29:43 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 14:29:43 ###########


########## Tcl recorder starts at 07/10/16 14:30:38 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 14:30:38 ###########


########## Tcl recorder starts at 07/10/16 14:30:41 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 14:30:41 ###########


########## Tcl recorder starts at 07/10/16 14:31:58 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"i2c_slave.vhd\" -o \"i2c_slave.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 14:31:58 ###########


########## Tcl recorder starts at 07/10/16 14:32:01 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 14:32:01 ###########


########## Tcl recorder starts at 07/10/16 14:40:22 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 14:40:22 ###########


########## Tcl recorder starts at 07/10/16 14:40:25 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 14:40:25 ###########


########## Tcl recorder starts at 07/10/16 14:43:44 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 14:43:44 ###########


########## Tcl recorder starts at 07/10/16 14:43:48 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 14:43:48 ###########


########## Tcl recorder starts at 07/10/16 14:55:38 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 14:55:38 ###########


########## Tcl recorder starts at 07/10/16 14:55:47 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 14:55:47 ###########


########## Tcl recorder starts at 07/10/16 14:57:11 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 14:57:11 ###########


########## Tcl recorder starts at 07/10/16 14:58:20 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"i2c_slave.vhd\" -o \"i2c_slave.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 14:58:20 ###########


########## Tcl recorder starts at 07/10/16 14:58:31 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"i2c_slave.vhd\" -o \"i2c_slave.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 14:58:31 ###########


########## Tcl recorder starts at 07/10/16 14:58:36 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 14:58:36 ###########


########## Tcl recorder starts at 07/10/16 15:14:58 ##########

# Commands to make the Process: 
# Constraint Editor
# - none -
# Application to view the Process: 
# Constraint Editor
if [catch {open ce.rsp w} rspFile] {
	puts stderr "Cannot create response file ce.rsp: $rspFile"
} else {
	puts $rspFile "-devfile \"$install_dir/ispcpld/data/lc1k/le1032_84j.dev\"
-lci espfluke.lct
-touch espfluke.ir0
-src espfluke.emf
-type EDIF
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @ce.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 15:14:58 ###########


########## Tcl recorder starts at 07/10/16 15:15:48 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 15:15:48 ###########


########## Tcl recorder starts at 07/10/16 15:17:45 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 15:17:45 ###########


########## Tcl recorder starts at 07/10/16 15:18:06 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 15:18:06 ###########


########## Tcl recorder starts at 07/10/16 15:27:50 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"i2c_slave.vhd\" -o \"i2c_slave.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 15:27:50 ###########


########## Tcl recorder starts at 07/10/16 15:28:03 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"i2c_slave.vhd\" -o \"i2c_slave.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 15:28:03 ###########


########## Tcl recorder starts at 07/10/16 15:28:06 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 15:28:06 ###########


########## Tcl recorder starts at 07/10/16 15:32:54 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 15:32:54 ###########


########## Tcl recorder starts at 07/10/16 15:33:04 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 15:33:04 ###########


########## Tcl recorder starts at 07/10/16 15:33:21 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 15:33:21 ###########


########## Tcl recorder starts at 07/10/16 15:33:33 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 15:33:33 ###########


########## Tcl recorder starts at 07/10/16 15:33:35 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 15:33:35 ###########


########## Tcl recorder starts at 07/10/16 15:50:13 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"i2c_slave.vhd\" -o \"i2c_slave.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 15:50:13 ###########


########## Tcl recorder starts at 07/10/16 15:50:15 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 15:50:15 ###########


########## Tcl recorder starts at 07/10/16 15:51:24 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"i2c_slave.vhd\" -o \"i2c_slave.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 15:51:24 ###########


########## Tcl recorder starts at 07/10/16 15:51:29 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 15:51:29 ###########


########## Tcl recorder starts at 07/10/16 15:55:10 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 15:55:10 ###########


########## Tcl recorder starts at 07/10/16 15:57:37 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 15:57:37 ###########


########## Tcl recorder starts at 07/10/16 16:12:41 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"i2c_slave.vhd\" -o \"i2c_slave.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 16:12:41 ###########


########## Tcl recorder starts at 07/10/16 16:13:09 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 16:13:09 ###########


########## Tcl recorder starts at 07/10/16 16:20:07 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 16:20:07 ###########


########## Tcl recorder starts at 07/10/16 16:20:14 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 16:20:14 ###########


########## Tcl recorder starts at 07/10/16 16:22:05 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 16:22:05 ###########


########## Tcl recorder starts at 07/10/16 16:22:09 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 16:22:09 ###########


########## Tcl recorder starts at 07/10/16 16:23:45 ##########

# Commands to make the Process: 
# Timing Analysis
if [runCmd "\"$cpld_bin/synta\" -proj espfluke -pd \"$proj_dir\" -dpm_only "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 16:23:45 ###########


########## Tcl recorder starts at 07/10/16 16:26:30 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"i2c_slave.vhd\" -o \"i2c_slave.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 16:26:30 ###########


########## Tcl recorder starts at 07/10/16 16:26:33 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 16:26:33 ###########


########## Tcl recorder starts at 07/10/16 16:47:56 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 16:47:56 ###########


########## Tcl recorder starts at 07/10/16 16:48:14 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 16:48:14 ###########


########## Tcl recorder starts at 07/10/16 16:51:26 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 16:51:26 ###########


########## Tcl recorder starts at 07/10/16 16:52:49 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 16:52:49 ###########


########## Tcl recorder starts at 07/10/16 16:53:29 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 16:53:29 ###########


########## Tcl recorder starts at 07/10/16 17:11:59 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 17:11:59 ###########


########## Tcl recorder starts at 07/10/16 17:14:06 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 17:14:06 ###########


########## Tcl recorder starts at 07/10/16 17:14:38 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 17:14:38 ###########


########## Tcl recorder starts at 07/10/16 17:16:38 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 17:16:38 ###########


########## Tcl recorder starts at 07/10/16 17:16:52 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 17:16:52 ###########


########## Tcl recorder starts at 07/10/16 17:22:24 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 17:22:24 ###########


########## Tcl recorder starts at 07/10/16 17:24:59 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 17:24:59 ###########


########## Tcl recorder starts at 07/10/16 17:25:07 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 17:25:07 ###########


########## Tcl recorder starts at 07/10/16 17:25:33 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 17:25:33 ###########


########## Tcl recorder starts at 07/10/16 17:25:35 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 17:25:35 ###########


########## Tcl recorder starts at 07/10/16 17:26:04 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 17:26:04 ###########


########## Tcl recorder starts at 07/10/16 17:26:06 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 17:26:06 ###########


########## Tcl recorder starts at 07/10/16 17:27:55 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 17:27:55 ###########


########## Tcl recorder starts at 07/10/16 17:28:03 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 17:28:03 ###########


########## Tcl recorder starts at 07/10/16 17:29:13 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 17:29:13 ###########


########## Tcl recorder starts at 07/10/16 17:29:15 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 17:29:15 ###########


########## Tcl recorder starts at 07/10/16 17:32:05 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 17:32:05 ###########


########## Tcl recorder starts at 07/10/16 17:32:24 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 17:32:24 ###########


########## Tcl recorder starts at 07/10/16 17:32:28 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 17:32:28 ###########


########## Tcl recorder starts at 07/10/16 17:32:32 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 17:32:32 ###########


########## Tcl recorder starts at 07/10/16 17:34:01 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 17:34:01 ###########


########## Tcl recorder starts at 07/10/16 17:34:03 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 17:34:03 ###########


########## Tcl recorder starts at 07/10/16 17:34:37 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 17:34:37 ###########


########## Tcl recorder starts at 07/10/16 17:34:41 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 17:34:41 ###########


########## Tcl recorder starts at 07/10/16 17:34:45 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 17:34:45 ###########


########## Tcl recorder starts at 07/10/16 17:36:03 ##########

# Commands to make the Process: 
# Constraint Editor
# - none -
# Application to view the Process: 
# Constraint Editor
if [catch {open ce.rsp w} rspFile] {
	puts stderr "Cannot create response file ce.rsp: $rspFile"
} else {
	puts $rspFile "-devfile \"$install_dir/ispcpld/data/lc1k/le1032_84j.dev\"
-lci espfluke.lct
-touch espfluke.ir0
-src espfluke.emf
-type EDIF
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @ce.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 17:36:03 ###########


########## Tcl recorder starts at 07/10/16 17:38:12 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 17:38:12 ###########


########## Tcl recorder starts at 07/10/16 17:38:38 ##########

# Commands to make the Process: 
# Constraint Editor
# - none -
# Application to view the Process: 
# Constraint Editor
if [catch {open ce.rsp w} rspFile] {
	puts stderr "Cannot create response file ce.rsp: $rspFile"
} else {
	puts $rspFile "-devfile \"$install_dir/ispcpld/data/lc1k/le1032_84j.dev\"
-lci espfluke.lct
-touch espfluke.ir0
-src espfluke.emf
-type EDIF
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @ce.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 17:38:38 ###########


########## Tcl recorder starts at 07/10/16 17:47:54 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 17:47:54 ###########


########## Tcl recorder starts at 07/10/16 17:56:34 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 17:56:34 ###########


########## Tcl recorder starts at 07/10/16 17:56:44 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 17:56:44 ###########


########## Tcl recorder starts at 07/10/16 17:56:51 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 17:56:51 ###########


########## Tcl recorder starts at 07/10/16 17:56:57 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 17:56:57 ###########


########## Tcl recorder starts at 07/10/16 17:59:00 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 17:59:00 ###########


########## Tcl recorder starts at 07/10/16 17:59:04 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 17:59:04 ###########


########## Tcl recorder starts at 07/10/16 18:01:25 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 18:01:25 ###########


########## Tcl recorder starts at 07/10/16 18:02:27 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 18:02:27 ###########


########## Tcl recorder starts at 07/10/16 18:02:30 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 18:02:30 ###########


########## Tcl recorder starts at 07/10/16 18:03:07 ##########

# Commands to make the Process: 
# Constraint Editor
# - none -
# Application to view the Process: 
# Constraint Editor
if [catch {open ce.rsp w} rspFile] {
	puts stderr "Cannot create response file ce.rsp: $rspFile"
} else {
	puts $rspFile "-devfile \"$install_dir/ispcpld/data/lc1k/le1032_84j.dev\"
-lci espfluke.lct
-touch espfluke.ir0
-src espfluke.emf
-type EDIF
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @ce.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 18:03:07 ###########


########## Tcl recorder starts at 07/10/16 18:03:14 ##########

# Commands to make the Process: 
# Constraint Editor
# - none -
# Application to view the Process: 
# Constraint Editor
if [catch {open ce.rsp w} rspFile] {
	puts stderr "Cannot create response file ce.rsp: $rspFile"
} else {
	puts $rspFile "-devfile \"$install_dir/ispcpld/data/lc1k/le1032_84j.dev\"
-lci espfluke.lct
-touch espfluke.ir0
-src espfluke.emf
-type EDIF
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @ce.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 18:03:15 ###########


########## Tcl recorder starts at 07/10/16 18:04:18 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 18:04:18 ###########


########## Tcl recorder starts at 07/10/16 18:21:43 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 18:21:43 ###########


########## Tcl recorder starts at 07/10/16 18:22:04 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 18:22:04 ###########


########## Tcl recorder starts at 07/10/16 18:24:12 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 18:24:12 ###########


########## Tcl recorder starts at 07/10/16 18:24:54 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 18:24:54 ###########


########## Tcl recorder starts at 07/10/16 18:25:02 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 18:25:02 ###########


########## Tcl recorder starts at 07/10/16 18:26:48 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 18:26:48 ###########


########## Tcl recorder starts at 07/10/16 18:30:59 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 18:30:59 ###########


########## Tcl recorder starts at 07/10/16 18:31:02 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 18:31:02 ###########


########## Tcl recorder starts at 07/10/16 18:32:09 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 18:32:09 ###########


########## Tcl recorder starts at 07/10/16 18:34:33 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 18:34:33 ###########


########## Tcl recorder starts at 07/10/16 18:34:45 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 18:34:45 ###########


########## Tcl recorder starts at 07/10/16 18:34:52 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 18:34:52 ###########


########## Tcl recorder starts at 07/10/16 18:35:39 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 18:35:39 ###########


########## Tcl recorder starts at 07/10/16 18:36:49 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 18:36:49 ###########


########## Tcl recorder starts at 07/10/16 18:37:32 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 18:37:32 ###########


########## Tcl recorder starts at 07/10/16 18:38:26 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"i2c_slave.vhd\" -o \"i2c_slave.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 18:38:26 ###########


########## Tcl recorder starts at 07/10/16 18:38:34 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"i2c_slave.vhd\" -o \"i2c_slave.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 18:38:34 ###########


########## Tcl recorder starts at 07/10/16 18:39:08 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"i2c_slave.vhd\" -o \"i2c_slave.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 18:39:08 ###########


########## Tcl recorder starts at 07/10/16 18:39:25 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 18:39:25 ###########


########## Tcl recorder starts at 07/10/16 18:39:43 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 18:39:43 ###########


########## Tcl recorder starts at 07/10/16 18:39:56 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 18:39:56 ###########


########## Tcl recorder starts at 07/10/16 18:40:08 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 18:40:09 ###########


########## Tcl recorder starts at 07/10/16 18:40:42 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 18:40:42 ###########


########## Tcl recorder starts at 07/10/16 18:41:02 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 18:41:02 ###########


########## Tcl recorder starts at 07/10/16 18:41:12 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 18:41:12 ###########


########## Tcl recorder starts at 07/10/16 18:41:26 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 18:41:26 ###########


########## Tcl recorder starts at 07/10/16 18:41:45 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 18:41:45 ###########


########## Tcl recorder starts at 07/10/16 18:42:04 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 18:42:04 ###########


########## Tcl recorder starts at 07/10/16 18:42:37 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 18:42:37 ###########


########## Tcl recorder starts at 07/10/16 18:43:25 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"i2c_slave.vhd\" -o \"i2c_slave.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 18:43:25 ###########


########## Tcl recorder starts at 07/10/16 18:43:28 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 18:43:28 ###########


########## Tcl recorder starts at 07/10/16 18:44:13 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"i2c_slave.vhd\" -o \"i2c_slave.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 18:44:13 ###########


########## Tcl recorder starts at 07/10/16 18:44:43 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"i2c_slave.vhd\" -o \"i2c_slave.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 18:44:43 ###########


########## Tcl recorder starts at 07/10/16 18:44:48 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"i2c_slave.vhd\" -o \"i2c_slave.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 18:44:48 ###########


########## Tcl recorder starts at 07/10/16 18:44:51 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 18:44:51 ###########


########## Tcl recorder starts at 07/10/16 18:50:59 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 18:50:59 ###########


########## Tcl recorder starts at 07/10/16 18:51:02 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 18:51:02 ###########


########## Tcl recorder starts at 07/10/16 18:58:52 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"i2c_slave.vhd\" -o \"i2c_slave.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 18:58:52 ###########


########## Tcl recorder starts at 07/10/16 19:01:40 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 19:01:40 ###########


########## Tcl recorder starts at 07/10/16 19:01:45 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 19:01:45 ###########


########## Tcl recorder starts at 07/10/16 19:03:21 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 19:03:21 ###########


########## Tcl recorder starts at 07/10/16 19:03:26 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 19:03:26 ###########


########## Tcl recorder starts at 07/10/16 19:07:03 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 19:07:03 ###########


########## Tcl recorder starts at 07/10/16 19:07:34 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 19:07:34 ###########


########## Tcl recorder starts at 07/10/16 19:07:39 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 19:07:39 ###########


########## Tcl recorder starts at 07/10/16 19:09:21 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 19:09:21 ###########


########## Tcl recorder starts at 07/10/16 19:09:23 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 19:09:23 ###########


########## Tcl recorder starts at 07/10/16 19:09:26 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 19:09:26 ###########


########## Tcl recorder starts at 07/10/16 19:10:01 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 19:10:01 ###########


########## Tcl recorder starts at 07/10/16 19:10:20 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 19:10:20 ###########


########## Tcl recorder starts at 07/10/16 19:10:28 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 19:10:28 ###########


########## Tcl recorder starts at 07/10/16 19:22:48 ##########

# Commands to make the Process: 
# Fitter Report
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 19:22:48 ###########


########## Tcl recorder starts at 07/10/16 19:24:48 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 19:24:48 ###########


########## Tcl recorder starts at 07/10/16 19:26:32 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"i2c_slave.vhd\" -o \"i2c_slave.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 19:26:33 ###########


########## Tcl recorder starts at 07/10/16 19:27:19 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 19:27:19 ###########


########## Tcl recorder starts at 07/10/16 19:27:26 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 19:27:26 ###########


########## Tcl recorder starts at 07/10/16 19:28:14 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 19:28:14 ###########


########## Tcl recorder starts at 07/10/16 19:28:34 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 19:28:34 ###########


########## Tcl recorder starts at 07/10/16 19:28:39 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 19:28:39 ###########


########## Tcl recorder starts at 07/10/16 19:29:07 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"i2c_slave.vhd\" -o \"i2c_slave.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 19:29:07 ###########


########## Tcl recorder starts at 07/10/16 19:29:34 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 19:29:35 ###########


########## Tcl recorder starts at 07/10/16 19:29:37 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 19:29:37 ###########


########## Tcl recorder starts at 07/10/16 19:30:39 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 19:30:39 ###########


########## Tcl recorder starts at 07/10/16 19:30:44 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 19:30:44 ###########


########## Tcl recorder starts at 07/10/16 19:31:09 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 19:31:09 ###########


########## Tcl recorder starts at 07/10/16 19:31:11 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 19:31:11 ###########


########## Tcl recorder starts at 07/10/16 19:31:59 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 19:31:59 ###########


########## Tcl recorder starts at 07/10/16 19:32:06 ##########

# Commands to make the Process: 
# Constraint Editor
# - none -
# Application to view the Process: 
# Constraint Editor
if [catch {open ce.rsp w} rspFile] {
	puts stderr "Cannot create response file ce.rsp: $rspFile"
} else {
	puts $rspFile "-devfile \"$install_dir/ispcpld/data/lc1k/le1032_84j.dev\"
-lci espfluke.lct
-touch espfluke.ir0
-src espfluke.emf
-type EDIF
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @ce.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/10/16 19:32:06 ###########


########## Tcl recorder starts at 07/11/16 21:25:36 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/11/16 21:25:36 ###########


########## Tcl recorder starts at 07/11/16 21:31:01 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/11/16 21:31:01 ###########


########## Tcl recorder starts at 07/11/16 21:33:17 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/11/16 21:33:17 ###########


########## Tcl recorder starts at 07/11/16 21:33:54 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/11/16 21:33:54 ###########


########## Tcl recorder starts at 07/11/16 21:33:56 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/11/16 21:33:56 ###########


########## Tcl recorder starts at 07/11/16 21:34:18 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/11/16 21:34:18 ###########


########## Tcl recorder starts at 07/11/16 21:35:05 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/11/16 21:35:05 ###########


########## Tcl recorder starts at 07/11/16 21:36:08 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/11/16 21:36:08 ###########


########## Tcl recorder starts at 07/11/16 21:36:11 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/11/16 21:36:11 ###########


########## Tcl recorder starts at 07/11/16 21:36:16 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/11/16 21:36:16 ###########


########## Tcl recorder starts at 07/11/16 21:36:54 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/11/16 21:36:54 ###########


########## Tcl recorder starts at 07/11/16 21:36:57 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/11/16 21:36:57 ###########


########## Tcl recorder starts at 07/11/16 21:37:23 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/11/16 21:37:23 ###########


########## Tcl recorder starts at 07/11/16 21:37:29 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/11/16 21:37:29 ###########


########## Tcl recorder starts at 07/11/16 21:37:31 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/11/16 21:37:31 ###########


########## Tcl recorder starts at 07/11/16 21:38:06 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/11/16 21:38:06 ###########


########## Tcl recorder starts at 07/11/16 21:38:10 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/11/16 21:38:10 ###########


########## Tcl recorder starts at 07/11/16 21:38:38 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/11/16 21:38:38 ###########


########## Tcl recorder starts at 07/11/16 21:38:40 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/11/16 21:38:40 ###########


########## Tcl recorder starts at 07/11/16 21:40:50 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/11/16 21:40:50 ###########


########## Tcl recorder starts at 07/11/16 21:40:53 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/11/16 21:40:53 ###########


########## Tcl recorder starts at 07/11/16 21:42:12 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/11/16 21:42:12 ###########


########## Tcl recorder starts at 07/11/16 21:42:14 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/11/16 21:42:14 ###########


########## Tcl recorder starts at 07/11/16 21:44:29 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/11/16 21:44:29 ###########


########## Tcl recorder starts at 07/11/16 21:44:33 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/11/16 21:44:33 ###########


########## Tcl recorder starts at 07/11/16 21:45:39 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/11/16 21:45:39 ###########


########## Tcl recorder starts at 07/11/16 21:45:41 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/11/16 21:45:41 ###########


########## Tcl recorder starts at 07/11/16 21:46:18 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/11/16 21:46:18 ###########


########## Tcl recorder starts at 07/11/16 21:46:21 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/11/16 21:46:21 ###########


########## Tcl recorder starts at 07/11/16 21:51:35 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/11/16 21:51:35 ###########


########## Tcl recorder starts at 07/11/16 21:51:52 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/11/16 21:51:52 ###########


########## Tcl recorder starts at 07/15/16 20:03:44 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/15/16 20:03:44 ###########


########## Tcl recorder starts at 07/15/16 20:06:46 ##########

# Commands to make the Process: 
# Fitter Report
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/15/16 20:06:46 ###########


########## Tcl recorder starts at 07/15/16 20:08:57 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/15/16 20:08:57 ###########


########## Tcl recorder starts at 07/15/16 20:08:59 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/15/16 20:08:59 ###########


########## Tcl recorder starts at 07/15/16 20:10:59 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/15/16 20:10:59 ###########


########## Tcl recorder starts at 07/15/16 20:11:01 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/15/16 20:11:01 ###########


########## Tcl recorder starts at 07/15/16 20:17:20 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/15/16 20:17:20 ###########


########## Tcl recorder starts at 07/15/16 20:18:52 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/15/16 20:18:53 ###########


########## Tcl recorder starts at 07/15/16 20:19:04 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/15/16 20:19:04 ###########


########## Tcl recorder starts at 07/15/16 20:19:19 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/15/16 20:19:19 ###########


########## Tcl recorder starts at 07/15/16 20:19:22 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/15/16 20:19:22 ###########


########## Tcl recorder starts at 07/15/16 20:19:44 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/15/16 20:19:44 ###########


########## Tcl recorder starts at 07/15/16 20:19:48 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/15/16 20:19:48 ###########


########## Tcl recorder starts at 07/15/16 20:20:09 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/15/16 20:20:09 ###########


########## Tcl recorder starts at 07/15/16 20:20:13 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/15/16 20:20:13 ###########


########## Tcl recorder starts at 07/15/16 20:22:03 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"i2c_slave.vhd\" -o \"i2c_slave.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/15/16 20:22:03 ###########


########## Tcl recorder starts at 07/15/16 20:22:08 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/15/16 20:22:08 ###########


########## Tcl recorder starts at 07/15/16 20:22:36 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/15/16 20:22:36 ###########


########## Tcl recorder starts at 07/15/16 20:22:41 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/15/16 20:22:42 ###########


########## Tcl recorder starts at 07/15/16 20:22:46 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/15/16 20:22:46 ###########


########## Tcl recorder starts at 07/15/16 20:22:54 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/15/16 20:22:54 ###########


########## Tcl recorder starts at 07/15/16 20:23:23 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"i2c_slave.vhd\" -o \"i2c_slave.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/15/16 20:23:23 ###########


########## Tcl recorder starts at 07/15/16 20:23:28 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/15/16 20:23:28 ###########


########## Tcl recorder starts at 07/15/16 20:25:01 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"i2c_slave.vhd\" -o \"i2c_slave.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/15/16 20:25:01 ###########


########## Tcl recorder starts at 07/15/16 20:25:24 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"i2c_slave.vhd\" -o \"i2c_slave.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/15/16 20:25:24 ###########


########## Tcl recorder starts at 07/15/16 20:25:32 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/15/16 20:25:33 ###########


########## Tcl recorder starts at 07/15/16 20:25:36 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/15/16 20:25:36 ###########


########## Tcl recorder starts at 07/15/16 20:25:57 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/15/16 20:25:57 ###########


########## Tcl recorder starts at 07/15/16 20:25:59 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/15/16 20:25:59 ###########


########## Tcl recorder starts at 07/15/16 20:30:56 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/15/16 20:30:56 ###########


########## Tcl recorder starts at 07/15/16 20:31:00 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/15/16 20:31:00 ###########


########## Tcl recorder starts at 07/15/16 20:33:43 ##########

# Commands to make the Process: 
# Maximum Frequency Report
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synta\" -proj espfluke -pd \"$proj_dir\" -dpm_only "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/15/16 20:33:43 ###########


########## Tcl recorder starts at 07/16/16 12:12:35 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/16/16 12:12:35 ###########


########## Tcl recorder starts at 07/16/16 12:15:41 ##########

# Commands to make the Process: 
# Constraint Editor
# - none -
# Application to view the Process: 
# Constraint Editor
if [catch {open ce.rsp w} rspFile] {
	puts stderr "Cannot create response file ce.rsp: $rspFile"
} else {
	puts $rspFile "-devfile \"$install_dir/ispcpld/data/lc1k/le1032_84j.dev\"
-lci espfluke.lct
-touch espfluke.ir0
-src espfluke.emf
-type EDIF
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @ce.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/16/16 12:15:41 ###########


########## Tcl recorder starts at 07/16/16 12:17:12 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/16/16 12:17:12 ###########


########## Tcl recorder starts at 07/16/16 13:12:38 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/16/16 13:12:38 ###########


########## Tcl recorder starts at 07/16/16 13:13:14 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/16/16 13:13:14 ###########


########## Tcl recorder starts at 07/16/16 13:13:21 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/16/16 13:13:21 ###########


########## Tcl recorder starts at 07/16/16 13:14:23 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/16/16 13:14:23 ###########


########## Tcl recorder starts at 07/16/16 13:14:46 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/16/16 13:14:46 ###########


########## Tcl recorder starts at 07/16/16 13:15:53 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/16/16 13:15:53 ###########


########## Tcl recorder starts at 07/16/16 13:15:54 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/16/16 13:15:54 ###########


########## Tcl recorder starts at 07/16/16 13:16:14 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/16/16 13:16:14 ###########


########## Tcl recorder starts at 07/16/16 13:16:15 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/16/16 13:16:16 ###########


########## Tcl recorder starts at 07/16/16 13:17:06 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/16/16 13:17:06 ###########


########## Tcl recorder starts at 07/16/16 13:17:12 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/16/16 13:17:12 ###########


########## Tcl recorder starts at 07/16/16 13:18:07 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/16/16 13:18:07 ###########


########## Tcl recorder starts at 07/16/16 13:18:09 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/16/16 13:18:09 ###########


########## Tcl recorder starts at 07/16/16 13:19:18 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"i2c_slave.vhd\" -o \"i2c_slave.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/16/16 13:19:18 ###########


########## Tcl recorder starts at 07/16/16 13:20:45 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"i2c_slave.vhd\" -o \"i2c_slave.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/16/16 13:20:45 ###########


########## Tcl recorder starts at 07/16/16 13:20:50 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/16/16 13:20:50 ###########


########## Tcl recorder starts at 07/16/16 13:21:14 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"i2c_slave.vhd\" -o \"i2c_slave.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/16/16 13:21:14 ###########


########## Tcl recorder starts at 07/16/16 13:21:18 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/16/16 13:21:18 ###########


########## Tcl recorder starts at 07/16/16 13:21:50 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"i2c_slave.vhd\" -o \"i2c_slave.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/16/16 13:21:50 ###########


########## Tcl recorder starts at 07/16/16 13:22:05 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/16/16 13:22:05 ###########


########## Tcl recorder starts at 07/16/16 13:22:29 ##########

# Commands to make the Process: 
# Timing Analysis
if [runCmd "\"$cpld_bin/synta\" -proj espfluke -pd \"$proj_dir\" -dpm_only "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/16/16 13:22:29 ###########


########## Tcl recorder starts at 07/16/16 13:24:52 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/16/16 13:24:52 ###########


########## Tcl recorder starts at 07/16/16 13:24:56 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/16/16 13:24:56 ###########


########## Tcl recorder starts at 07/16/16 13:31:06 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/16/16 13:31:06 ###########


########## Tcl recorder starts at 07/16/16 13:31:10 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/16/16 13:31:10 ###########


########## Tcl recorder starts at 07/16/16 15:34:13 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/16/16 15:34:13 ###########


########## Tcl recorder starts at 07/16/16 15:34:41 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/16/16 15:34:41 ###########


########## Tcl recorder starts at 07/16/16 15:34:59 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/16/16 15:34:59 ###########


########## Tcl recorder starts at 07/16/16 15:35:04 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/16/16 15:35:04 ###########


########## Tcl recorder starts at 07/16/16 15:36:36 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/16/16 15:36:36 ###########


########## Tcl recorder starts at 07/16/16 15:36:49 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/16/16 15:36:49 ###########


########## Tcl recorder starts at 07/16/16 15:37:01 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/16/16 15:37:01 ###########


########## Tcl recorder starts at 07/16/16 15:40:42 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/16/16 15:40:42 ###########


########## Tcl recorder starts at 07/16/16 15:43:19 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/16/16 15:43:19 ###########


########## Tcl recorder starts at 07/16/16 15:43:36 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/16/16 15:43:36 ###########


########## Tcl recorder starts at 07/16/16 15:43:59 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/16/16 15:43:59 ###########


########## Tcl recorder starts at 07/16/16 15:44:01 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/16/16 15:44:01 ###########


########## Tcl recorder starts at 07/16/16 15:44:42 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/16/16 15:44:42 ###########


########## Tcl recorder starts at 07/16/16 15:44:44 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/16/16 15:44:44 ###########


########## Tcl recorder starts at 07/16/16 15:46:19 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/16/16 15:46:19 ###########


########## Tcl recorder starts at 07/16/16 15:46:26 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/16/16 15:46:26 ###########


########## Tcl recorder starts at 07/16/16 15:49:59 ##########

# Commands to make the Process: 
# Fitter Report
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/16/16 15:49:59 ###########


########## Tcl recorder starts at 07/16/16 15:54:21 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/16/16 15:54:21 ###########


########## Tcl recorder starts at 07/16/16 15:54:44 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/16/16 15:54:44 ###########


########## Tcl recorder starts at 07/16/16 15:56:01 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/16/16 15:56:01 ###########


########## Tcl recorder starts at 07/16/16 15:56:11 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/16/16 15:56:11 ###########


########## Tcl recorder starts at 07/16/16 15:57:50 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/16/16 15:57:50 ###########


########## Tcl recorder starts at 07/16/16 15:57:57 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/16/16 15:57:57 ###########


########## Tcl recorder starts at 07/16/16 15:58:13 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/16/16 15:58:13 ###########


########## Tcl recorder starts at 07/16/16 21:40:56 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/16/16 21:40:56 ###########


########## Tcl recorder starts at 07/16/16 21:41:09 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/16/16 21:41:09 ###########


########## Tcl recorder starts at 07/16/16 21:44:22 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/16/16 21:44:22 ###########


########## Tcl recorder starts at 07/16/16 21:44:40 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/16/16 21:44:40 ###########


########## Tcl recorder starts at 07/16/16 21:45:57 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/16/16 21:45:57 ###########


########## Tcl recorder starts at 07/16/16 21:46:13 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/16/16 21:46:13 ###########


########## Tcl recorder starts at 07/16/16 21:47:36 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/16/16 21:47:36 ###########


########## Tcl recorder starts at 07/16/16 21:48:27 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"i2c_slave.vhd\" -o \"i2c_slave.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/16/16 21:48:27 ###########


########## Tcl recorder starts at 07/16/16 21:48:42 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"i2c_slave.vhd\" -o \"i2c_slave.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/16/16 21:48:42 ###########


########## Tcl recorder starts at 07/16/16 21:49:44 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/16/16 21:49:44 ###########


########## Tcl recorder starts at 07/16/16 21:49:58 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/16/16 21:49:58 ###########


########## Tcl recorder starts at 07/16/16 21:50:16 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/16/16 21:50:16 ###########


########## Tcl recorder starts at 07/16/16 21:50:28 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/16/16 21:50:28 ###########


########## Tcl recorder starts at 07/16/16 21:50:30 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/16/16 21:50:30 ###########


########## Tcl recorder starts at 07/16/16 21:50:50 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/16/16 21:50:50 ###########


########## Tcl recorder starts at 07/16/16 21:50:52 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/16/16 21:50:52 ###########


########## Tcl recorder starts at 07/18/16 10:55:44 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/18/16 10:55:44 ###########


########## Tcl recorder starts at 07/18/16 11:25:25 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/18/16 11:25:26 ###########


########## Tcl recorder starts at 07/18/16 11:25:26 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/18/16 11:25:26 ###########


########## Tcl recorder starts at 07/19/16 12:15:00 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/19/16 12:15:00 ###########


########## Tcl recorder starts at 07/19/16 12:15:07 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/19/16 12:15:07 ###########


########## Tcl recorder starts at 07/19/16 14:39:41 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"espfluke.vhd\" -o \"espfluke.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/19/16 14:39:41 ###########


########## Tcl recorder starts at 07/19/16 14:39:47 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open espfluke.cmd w} rspFile] {
	puts stderr "Cannot create response file espfluke.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: espfluke.sty
PROJECT: espfluke
WORKING_PATH: \"$proj_dir\"
MODULE: espfluke
VHDL_FILE_LIST: i2c_slave.vhd espfluke.vhd
OUTPUT_FILE_NAME: espfluke
SUFFIX_NAME: edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e espfluke -target PLSI1K -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.cmd
if [catch {open espfluke.efl w} rspFile] {
	puts stderr "Cannot create response file espfluke.efl: $rspFile"
} else {
	puts $rspFile "espfluke.edn
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/edfmerge\" -i espfluke.efl -prj espfluke -inc \"$install_dir/ispcpld/plsi/map/plsi_bse.ecf\" -flib \"$install_dir/ispcpld/plsi/map/plsi_map.ecf\" -fixname -family plsi -o espfluke.emf"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete espfluke.efl
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.ir0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.emf -if edif -prop espfluke.prp -p ispLSI1032E-70LJ84 -pre "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$install_dir/ispcomp/bin/impsrclever\" -prj espfluke -log espfluke.irs -noPrp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/syndpm\" -i espfluke.laf -if laf -p ispLSI1032E-70LJ84 -pd \"$proj_dir\"  -of vhdl -of verilog"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj espfluke -if espfluke.jed -j2s -log espfluke.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/19/16 14:39:47 ###########

