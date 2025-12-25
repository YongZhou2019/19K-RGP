#!/bin/bash
#
# Script to add calcium atoms from PDB 2ZFD to phosphorylated structure
# Usage: ./run_add_calcium.sh [path_to_structure_directory]
#
# If no argument provided, uses the default haplotype directory

# Default directory
DEFAULT_DIR="/ibex/project/c2002/rice_and_af2/data/interim/PDB_to_MD_CA/CBL8_HAP6_Freq.3062_CIPK17_HAP47_Freq.204_NAC77_HAP21_Freq.13677"

# Use provided directory or default
WORK_DIR="${1:-$DEFAULT_DIR}"

# Check if directory exists
if [ ! -d "$WORK_DIR" ]; then
    echo "ERROR: Directory does not exist: $WORK_DIR"
    exit 1
fi

# Check if input file exists
INPUT_FILE="$WORK_DIR/structure_complex_fixed_pymol_phosporilated.pdb"
if [ ! -f "$INPUT_FILE" ]; then
    echo "ERROR: Input file not found: $INPUT_FILE"
    echo "Please ensure the phosphorylated structure exists in the directory"
    exit 1
fi

echo "=========================================="
echo "Adding Calcium Atoms from PDB 2ZFD"
echo "=========================================="
echo "Working directory: $WORK_DIR"
echo "Input file:        $(basename $INPUT_FILE)"
echo ""

# Copy the PyMOL script to current directory
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
if [ ! -f "./add_calcium_from_2zfd.pml" ]; then
    echo "ERROR: PyMOL script not found: $SCRIPT_DIR/add_calcium_from_2zfd.pml"
    exit 1
fi
cp "$SCRIPT_DIR/add_calcium_from_2zfd.pml" "$WORK_DIR/"
echo "Using PyMOL script from: $SCRIPT_DIR/add_calcium_from_2zfd.pml"
echo ""

# Change to working directory
cd "$WORK_DIR" || exit 1

# Check if PyMOL is available
if ! command -v pymol &> /dev/null; then
    echo "ERROR: PyMOL is not found in PATH"
    echo "Please load PyMOL module or ensure it's installed"
    echo ""
    echo "On IBEX/Shaheen, you may need to run:"
    echo "  module load pymol"
    echo "  or"
    echo "  module load anaconda3"
    echo "  conda activate <env_with_pymol>"
    exit 1
fi

# Run PyMOL in command-line mode
echo "Running PyMOL script..."
echo ""
pymol -c add_calcium_from_2zfd.pml

# Check if output was created
OUTPUT_FILE="structure_complex_fixed_pymol_phosporilated_with_Ca.pdb"
if [ -f "$OUTPUT_FILE" ]; then
    echo ""
    echo "=========================================="
    echo "SUCCESS!"
    echo "=========================================="
    echo "Output file created: $OUTPUT_FILE"
    echo ""
    echo "File information:"
    ls -lh "$OUTPUT_FILE"
    echo ""
    
    # Count calcium atoms
    CA_COUNT=$(grep "^ATOM\|^HETATM" "$OUTPUT_FILE" | grep " CA " | grep "CA " | wc -l)
    echo "Calcium atoms found: $CA_COUNT"
    
    # Count total atoms
    TOTAL_ATOMS=$(grep "^ATOM\|^HETATM" "$OUTPUT_FILE" | wc -l)
    echo "Total atoms: $TOTAL_ATOMS"
    echo ""
    echo "You can now use this file for MD simulations with calcium"
    echo "Next step: Use this structure in GROMACS pdb2gmx"
else
    echo ""
    echo "=========================================="
    echo "ERROR: Output file was not created"
    echo "=========================================="
    echo "Check PyMOL output above for errors"
    exit 1
fi
