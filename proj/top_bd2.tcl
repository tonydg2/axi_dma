
################################################################
# This is a generated script based on design: top_bd
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2023.1
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_gid_msg -ssname BD::TCL -id 2041 -severity "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source top_bd_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xczu3eg-sbva484-1-i
   set_property BOARD_PART avnet.com:ultra96v2:part0:1.2 [current_project]
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name top_bd

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_gid_msg -ssname BD::TCL -id 2001 -severity "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_gid_msg -ssname BD::TCL -id 2002 -severity "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_gid_msg -ssname BD::TCL -id 2003 -severity "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_gid_msg -ssname BD::TCL -id 2004 -severity "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_gid_msg -ssname BD::TCL -id 2005 -severity "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_gid_msg -ssname BD::TCL -id 2006 -severity "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:ip:axi_bram_ctrl:4.1\
xilinx.com:ip:blk_mem_gen:8.4\
xilinx.com:ip:smartconnect:1.0\
xilinx.com:ip:axi_mcdma:1.1\
"

   set list_ips_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2011 -severity "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2012 -severity "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

if { $bCheckIPsPassed != 1 } {
  common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set S_AXIS_S2MM [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S_AXIS_S2MM ]
  set_property -dict [ list \
   CONFIG.HAS_TKEEP {1} \
   CONFIG.HAS_TLAST {1} \
   CONFIG.HAS_TREADY {1} \
   CONFIG.HAS_TSTRB {0} \
   CONFIG.LAYERED_METADATA {undef} \
   CONFIG.TDATA_NUM_BYTES {4} \
   CONFIG.TDEST_WIDTH {0} \
   CONFIG.TID_WIDTH {0} \
   CONFIG.TUSER_WIDTH {0} \
   ] $S_AXIS_S2MM

  set S_AXIL [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXIL ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {32} \
   CONFIG.ARUSER_WIDTH {0} \
   CONFIG.AWUSER_WIDTH {0} \
   CONFIG.BUSER_WIDTH {0} \
   CONFIG.DATA_WIDTH {32} \
   CONFIG.HAS_BRESP {1} \
   CONFIG.HAS_BURST {0} \
   CONFIG.HAS_CACHE {0} \
   CONFIG.HAS_LOCK {0} \
   CONFIG.HAS_PROT {0} \
   CONFIG.HAS_QOS {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.HAS_RRESP {1} \
   CONFIG.HAS_WSTRB {0} \
   CONFIG.ID_WIDTH {0} \
   CONFIG.MAX_BURST_LENGTH {1} \
   CONFIG.NUM_READ_OUTSTANDING {1} \
   CONFIG.NUM_READ_THREADS {1} \
   CONFIG.NUM_WRITE_OUTSTANDING {1} \
   CONFIG.NUM_WRITE_THREADS {1} \
   CONFIG.PROTOCOL {AXI4LITE} \
   CONFIG.READ_WRITE_MODE {READ_WRITE} \
   CONFIG.RUSER_BITS_PER_BYTE {0} \
   CONFIG.RUSER_WIDTH {0} \
   CONFIG.SUPPORTS_NARROW_BURST {0} \
   CONFIG.WUSER_BITS_PER_BYTE {0} \
   CONFIG.WUSER_WIDTH {0} \
   ] $S_AXIL

  set M_AXIS_MM2S [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M_AXIS_MM2S ]


  # Create ports
  set aclk [ create_bd_port -dir I -type clk aclk ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S_AXIS_S2MM:S_AXIL:M_AXIS_MM2S} \
   CONFIG.ASSOCIATED_RESET {arstn} \
 ] $aclk
  set arstn [ create_bd_port -dir I -type rst arstn ]

  # Create instance: MEM_BRAM_CTRL, and set properties
  set MEM_BRAM_CTRL [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 MEM_BRAM_CTRL ]

  # Create instance: MEMORY_BRAM, and set properties
  set MEMORY_BRAM [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 MEMORY_BRAM ]
  set_property CONFIG.Memory_Type {True_Dual_Port_RAM} $MEMORY_BRAM


  # Create instance: axi_smc, and set properties
  set axi_smc [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 axi_smc ]
  set_property -dict [list \
    CONFIG.NUM_MI {2} \
    CONFIG.NUM_SI {2} \
  ] $axi_smc


  # Create instance: SG_BRAM_CTRL, and set properties
  set SG_BRAM_CTRL [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 SG_BRAM_CTRL ]

  # Create instance: SG_BRAM, and set properties
  set SG_BRAM [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 SG_BRAM ]
  set_property -dict [list \
    CONFIG.Assume_Synchronous_Clk {true} \
    CONFIG.Memory_Type {True_Dual_Port_RAM} \
  ] $SG_BRAM


  # Create instance: axi_mcdma_0, and set properties
  set axi_mcdma_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_mcdma:1.1 axi_mcdma_0 ]
  set_property -dict [list \
    CONFIG.c_num_mm2s_channels {2} \
    CONFIG.c_num_s2mm_channels {2} \
  ] $axi_mcdma_0


  # Create instance: axi_smc1, and set properties
  set axi_smc1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 axi_smc1 ]
  set_property -dict [list \
    CONFIG.NUM_MI {1} \
    CONFIG.NUM_SI {2} \
  ] $axi_smc1


  # Create interface connections
  connect_bd_intf_net -intf_net S_AXIL_1 [get_bd_intf_ports S_AXIL] [get_bd_intf_pins axi_smc/S00_AXI]
  set_property SIM_ATTRIBUTE.MARK_SIM "true" [get_bd_intf_nets /S_AXIL_1]
  connect_bd_intf_net -intf_net S_AXIS_S2MM_1 [get_bd_intf_ports S_AXIS_S2MM] [get_bd_intf_pins axi_mcdma_0/S_AXIS_S2MM]
  set_property SIM_ATTRIBUTE.MARK_SIM "true" [get_bd_intf_nets /S_AXIS_S2MM_1]
  connect_bd_intf_net -intf_net axi_bram_ctrl_0_BRAM_PORTA [get_bd_intf_pins MEMORY_BRAM/BRAM_PORTA] [get_bd_intf_pins MEM_BRAM_CTRL/BRAM_PORTA]
  connect_bd_intf_net -intf_net axi_bram_ctrl_0_BRAM_PORTB [get_bd_intf_pins MEMORY_BRAM/BRAM_PORTB] [get_bd_intf_pins MEM_BRAM_CTRL/BRAM_PORTB]
  connect_bd_intf_net -intf_net axi_bram_ctrl_1_BRAM_PORTA [get_bd_intf_pins SG_BRAM_CTRL/BRAM_PORTA] [get_bd_intf_pins SG_BRAM/BRAM_PORTA]
  connect_bd_intf_net -intf_net axi_bram_ctrl_1_BRAM_PORTB [get_bd_intf_pins SG_BRAM_CTRL/BRAM_PORTB] [get_bd_intf_pins SG_BRAM/BRAM_PORTB]
  connect_bd_intf_net -intf_net axi_mcdma_0_M_AXIS_MM2S [get_bd_intf_ports M_AXIS_MM2S] [get_bd_intf_pins axi_mcdma_0/M_AXIS_MM2S]
  set_property SIM_ATTRIBUTE.MARK_SIM "true" [get_bd_intf_nets /axi_mcdma_0_M_AXIS_MM2S]
  connect_bd_intf_net -intf_net axi_mcdma_0_M_AXI_MM2S [get_bd_intf_pins axi_smc1/S00_AXI] [get_bd_intf_pins axi_mcdma_0/M_AXI_MM2S]
  set_property SIM_ATTRIBUTE.MARK_SIM "true" [get_bd_intf_nets /axi_mcdma_0_M_AXI_MM2S]
  connect_bd_intf_net -intf_net axi_mcdma_0_M_AXI_S2MM [get_bd_intf_pins axi_mcdma_0/M_AXI_S2MM] [get_bd_intf_pins axi_smc1/S01_AXI]
  set_property SIM_ATTRIBUTE.MARK_SIM "true" [get_bd_intf_nets /axi_mcdma_0_M_AXI_S2MM]
  connect_bd_intf_net -intf_net axi_mcdma_0_M_AXI_SG [get_bd_intf_pins axi_mcdma_0/M_AXI_SG] [get_bd_intf_pins axi_smc/S01_AXI]
  set_property SIM_ATTRIBUTE.MARK_SIM "true" [get_bd_intf_nets /axi_mcdma_0_M_AXI_SG]
  connect_bd_intf_net -intf_net axi_smc1_M00_AXI [get_bd_intf_pins axi_smc1/M00_AXI] [get_bd_intf_pins MEM_BRAM_CTRL/S_AXI]
  connect_bd_intf_net -intf_net axi_smc_M00_AXI [get_bd_intf_pins SG_BRAM_CTRL/S_AXI] [get_bd_intf_pins axi_smc/M00_AXI]
  set_property SIM_ATTRIBUTE.MARK_SIM "true" [get_bd_intf_nets /axi_smc_M00_AXI]
  connect_bd_intf_net -intf_net axi_smc_M01_AXI [get_bd_intf_pins axi_mcdma_0/S_AXI_LITE] [get_bd_intf_pins axi_smc/M01_AXI]
  set_property SIM_ATTRIBUTE.MARK_SIM "true" [get_bd_intf_nets /axi_smc_M01_AXI]

  # Create port connections
  connect_bd_net -net axi_resetn_0_1 [get_bd_ports arstn] [get_bd_pins MEM_BRAM_CTRL/s_axi_aresetn] [get_bd_pins axi_smc/aresetn] [get_bd_pins SG_BRAM_CTRL/s_axi_aresetn] [get_bd_pins axi_mcdma_0/axi_resetn] [get_bd_pins axi_smc1/aresetn]
  connect_bd_net -net s_axi_lite_aclk_0_1 [get_bd_ports aclk] [get_bd_pins axi_smc/aclk] [get_bd_pins MEM_BRAM_CTRL/s_axi_aclk] [get_bd_pins SG_BRAM_CTRL/s_axi_aclk] [get_bd_pins axi_mcdma_0/s_axi_aclk] [get_bd_pins axi_mcdma_0/s_axi_lite_aclk] [get_bd_pins axi_smc1/aclk]

  # Create address segments
  assign_bd_address -offset 0xC0000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces axi_mcdma_0/Data_MM2S] [get_bd_addr_segs MEM_BRAM_CTRL/S_AXI/Mem0] -force
  assign_bd_address -offset 0xC0000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces axi_mcdma_0/Data_S2MM] [get_bd_addr_segs MEM_BRAM_CTRL/S_AXI/Mem0] -force
  assign_bd_address -offset 0x00010000 -range 0x00010000 -target_address_space [get_bd_addr_spaces axi_mcdma_0/Data_SG] [get_bd_addr_segs SG_BRAM_CTRL/S_AXI/Mem0] -force
  assign_bd_address -offset 0x00010000 -range 0x00010000 -target_address_space [get_bd_addr_spaces S_AXIL] [get_bd_addr_segs SG_BRAM_CTRL/S_AXI/Mem0] -force
  assign_bd_address -offset 0x00000000 -range 0x00001000 -target_address_space [get_bd_addr_spaces S_AXIL] [get_bd_addr_segs axi_mcdma_0/S_AXI_LITE/Reg] -force

  # Exclude Address Segments
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces S_AXIL] [get_bd_addr_segs MEM_BRAM_CTRL/S_AXI/Mem0]
  exclude_bd_addr_seg -offset 0x00010000 -range 0x00010000 -target_address_space [get_bd_addr_spaces axi_mcdma_0/Data_MM2S] [get_bd_addr_segs SG_BRAM_CTRL/S_AXI/Mem0]
  exclude_bd_addr_seg -offset 0x44A00000 -range 0x00010000 -target_address_space [get_bd_addr_spaces axi_mcdma_0/Data_MM2S] [get_bd_addr_segs axi_mcdma_0/S_AXI_LITE/Reg]
  exclude_bd_addr_seg -offset 0x00010000 -range 0x00010000 -target_address_space [get_bd_addr_spaces axi_mcdma_0/Data_S2MM] [get_bd_addr_segs SG_BRAM_CTRL/S_AXI/Mem0]
  exclude_bd_addr_seg -offset 0x44A00000 -range 0x00010000 -target_address_space [get_bd_addr_spaces axi_mcdma_0/Data_S2MM] [get_bd_addr_segs axi_mcdma_0/S_AXI_LITE/Reg]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces axi_mcdma_0/Data_SG] [get_bd_addr_segs MEM_BRAM_CTRL/S_AXI/Mem0]
  exclude_bd_addr_seg -offset 0x44A00000 -range 0x00010000 -target_address_space [get_bd_addr_spaces axi_mcdma_0/Data_SG] [get_bd_addr_segs axi_mcdma_0/S_AXI_LITE/Reg]


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""

