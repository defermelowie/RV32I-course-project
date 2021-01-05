import sys
import re

def print_help():
    print("Usage: python hex2mif.py \"depth of memory (int)\" \"path to hex_file.hex\" \"path to mif_file.mif\"")

def convert_to_mif(hex_content, depth):
    lines = hex_content.splitlines()
    mif_content = "------------------------------------------\n"
    mif_content += "--   Intel memory initialization file   --\n"
    mif_content += "------------------------------------------\n"
    mif_content += "\n"
    mif_content += "DEPTH = " + depth + ";\n"
    mif_content += "WIDTH = 32;\n"
    mif_content += "ADDRESS_RADIX = HEX;\n"
    mif_content += "DATA_RADIX = HEX;\n"
    mif_content += "\n"
    mif_content += "CONTENT BEGIN\n"
    address = 0;
    for line in lines:
        if line:    # If line not empty
            # Extract data
            line = re.split("//", line)
            data = line[0].strip()
            # Add address & data
            mif_content += ("%03X" % address)
            mif_content += " : "
            mif_content += data
            mif_content += ";"
            if (len(line) > 1): # Add comment if available
                comment = line[1].strip()
                mif_content += " \t-- " + comment
            mif_content += "\n"
            address+=1;
    mif_content += "END;\n"
    return mif_content

if __name__ == "__main__":
    if (len(sys.argv) == 2 and sys.argv[1].lower() == "help"):
        print("Python tool to convert hex file to Intel mif")
        print_help()
    elif (len(sys.argv) == 4):
        # Extract paths
        mem_depth = sys.argv[1]
        hex_file_path = sys.argv[2]
        mif_file_path = sys.argv[3]
        # Check arguments
        try:
            int(mem_depth)
        except ValueError:
            print("ERROR: \"" + mem_depth + "\" is not a valid memory depth. Expected a positive integer")
            sys.exit()
        # Read hex file
        try:
            hex_file = open(hex_file_path, "r")
        except IOError:
            print("ERROR: Hex file not found: " + hex_file_path)
            sys.exit()
        hex_file_content = hex_file.read()
        hex_file.close()
        # Convert
        mif_file_content = convert_to_mif(hex_file_content, mem_depth)
        # Write mif file
        try:
            mif_file = open(mif_file_path, "r")
        except IOError:
            print("WARNING: Mif file did not exist, creating new file at: " + mif_file_path)
        mif_file = open(mif_file_path, "w")
        mif_file.write(mif_file_content)
        mif_file.close()
    else:
        print("ERROR: Wrong number of arguments")
        print_help()
sys.exit()