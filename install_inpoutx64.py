"""
    Puts the inpoutx64.dll in the System32 folder and registers it. 
    Python and MATLAB should be able to find it there.

    This script must be run with admin privileges.
"""


import os
import shutil
from ctypes import windll

# This does not necessarily need to be the actual address. It will still work if
# the address is incorrect, or if the PC does not have an LPT port.
lpt_addr = '0x378'

assert os.name == 'nt', 'This only works on Windows.'
assert windll.shell32.IsUserAnAdmin(), 'You must run this as administrator.'

inpoutx64_fn = "inpoutx64.dll"
inpoutx64_src_pathfn = "./inpout/" + inpoutx64_fn
inpoutx64_dest_path = "C:/Windows/System32/"
assert os.path.exists(inpoutx64_src_pathfn), f"The {inpoutx64_fn} was not where it was expected to be ({inpoutx64_src_pathfn})."
if not os.path.exists(inpoutx64_dest_path + inpoutx64_fn):
    shutil.copy2(inpoutx64_src_pathfn, inpoutx64_dest_path)
    print(f"Copied {inpoutx64_fn} to {inpoutx64_dest_path}.")
else:
    # If the file already exists, overwrite it anyways. This will crash if the file is in use, which shouldn't
    # be the case if it still needs to be installed.
    shutil.copy2(inpoutx64_src_pathfn, inpoutx64_dest_path)
    print(f"{inpoutx64_dest_path + inpoutx64_fn} already existed, but was overwritten.")
assert os.path.exists(inpoutx64_dest_path + inpoutx64_fn), f"The {inpoutx64_fn} did not make it to {inpoutx64_dest_path}."

# Run the DLL to automatically register it.
dll_obj = windll.LoadLibrary(inpoutx64_fn)
dll_obj.DlPortWritePortUchar(int(lpt_addr,0), 0)

del dll_obj

print(f"{inpoutx64_fn} driver installed successfully.")
