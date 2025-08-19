#!/usr/bin/env python3
#
# A script to generate a .f file list for Yosys with path prefix replacement.
#

from ipstools import IPDatabase
import argparse
import os

def export_yosys(self, script_path="./yosys_script.f", root='.', path_prefix=None):
    """Exports a script for Yosys with path prefix replacement."""
    all_defines, all_incdirs, all_files = set(), set(), []
    standard_defines = [
        "TARGET_ASIC", "TARGET_FLIST", "TARGET_IHP13", "TARGET_RTL",
        "TARGET_SYNTHESIS", "VERILATOR=1", "SYNTHESIS=1", "COMMON_CELLS_ASSERTS_OFF=1"
    ]
    all_defines.update(standard_defines)
    original_prefix = os.path.abspath(root)
    for source in ['ips', 'rtl']:
        ip_dic = self.ip_dic if source == 'ips' else self.rtl_dic
        source_dir = self.ips_dir if source == 'ips' else self.rtl_dir
        for ip_name, ip_config in ip_dic.items():
            for sub_ip_name, sub_ip_config in ip_config.sub_ips.items():
                all_defines.update(sub_ip_config.defines)
                for incdir in sub_ip_config.incdirs:
                    all_incdirs.add(os.path.join(original_prefix, source_dir, ip_config.ip_path, incdir))
                for f in sub_ip_config.files:
                    all_files.append(os.path.join(original_prefix, source_dir, ip_config.ip_path, f))
    yosys_script_parts = []
    for incdir in sorted(list(all_incdirs)):
        yosys_script_parts.append(f"+incdir+{incdir.replace(original_prefix, path_prefix) if path_prefix else incdir}")
    for define in sorted(list(all_defines)):
        yosys_script_parts.append(f"+define+{define}")
    for f in all_files:
        yosys_script_parts.append(f.replace(original_prefix, path_prefix) if path_prefix else f)
    with open(script_path, "w") as f:
        f.write("\n".join(yosys_script_parts))

def main():
    """Main function to generate the Yosys .f file."""

    parser = argparse.ArgumentParser(
        prog='generate_yosys_flist',
        description="A script to generate a Yosys-compatible file list (.f) with path prefix replacement."
    )

    parser.add_argument('--output-file', type=str, default="yosys.f",
                        help='The name of the output file for the Yosys file list.')
    parser.add_argument('--path-prefix', type=str, default="/foss/designs/pulpissimo",
                        help='The new path prefix to use in the generated file list.')
    parser.add_argument('--verbose', action='store_true',
                        help='Show more information during script execution.')

    args = parser.parse_args()

    try:
        ipdb = IPDatabase(
            rtl_dir='rtl',
            ips_dir='ips',
            vsim_dir='sim',
            load_cache=True,
            verbose=args.verbose
        )
    except Exception as e:
        print(f"Error: Could not initialize the IPDatabase.")
        print(f"Details: {e}")
        print("Please ensure you have run the IP update script to create a cache file.")
        return

    # Dynamically add the export_yosys method to the IPDatabase class
    IPDatabase.export_yosys = export_yosys

    print(f"Generating Yosys file list: {args.output_file}")
    
    # *** FIXED THE CALL HERE ***
    # No need to pass 'ipdb' as an argument; it's passed automatically as 'self'
    ipdb.export_yosys(
        script_path=args.output_file,
        path_prefix=args.path_prefix
    )

    print(f"\nSuccessfully generated {args.output_file} with the new path prefix!")

if __name__ == '__main__':
    main()
