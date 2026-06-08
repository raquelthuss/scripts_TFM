## Step 2. Running the analysis

The installation of **fastStructure** and its underlying dependencies (NumPy, SciPy, Cython, and GSL) was managed using an isolated **Miniconda** 
environment, since the `bioconda` channel provides precompiled packages for it to install the tool optimally and avoid any compatibility conflicts.

conda create -n faststruct -c bioconda faststructure -y
conda activate faststruct

for k in 1 2 3 4 5 6 7 8 9 10; do
    structure.py -K $k --input=dataset_filtered --output=results_faststr --format=bed
done

chooseK.py --input=results_faststr

distruct.py -K 5 --input=results_faststr --output=fast_structure_k5.svg --title="Population structure analysis (K=5)"

```bash
# Create the environment and install fastStructure with its dependencies
conda create -n faststruct -c bioconda faststructure -y
