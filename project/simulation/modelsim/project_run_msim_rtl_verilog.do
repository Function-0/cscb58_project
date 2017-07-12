transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/DAVID/Documents/GitHub/cscb58_project/project/vga_adapter {C:/Users/DAVID/Documents/GitHub/cscb58_project/project/vga_adapter/vga_pll.v}
vlog -vlog01compat -work work +incdir+C:/Users/DAVID/Documents/GitHub/cscb58_project/project/vga_adapter {C:/Users/DAVID/Documents/GitHub/cscb58_project/project/vga_adapter/vga_controller.v}
vlog -vlog01compat -work work +incdir+C:/Users/DAVID/Documents/GitHub/cscb58_project/project/vga_adapter {C:/Users/DAVID/Documents/GitHub/cscb58_project/project/vga_adapter/vga_address_translator.v}
vlog -vlog01compat -work work +incdir+C:/Users/DAVID/Documents/GitHub/cscb58_project/project/vga_adapter {C:/Users/DAVID/Documents/GitHub/cscb58_project/project/vga_adapter/vga_adapter.v}
vlog -vlog01compat -work work +incdir+C:/Users/DAVID/Documents/GitHub/cscb58_project/project {C:/Users/DAVID/Documents/GitHub/cscb58_project/project/project.v}

