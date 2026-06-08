## Step 2. Running the analysis

### Description

The installation of **fastStructure** and its underlying dependencies (NumPy, SciPy, Cython, and GSL) was managed using an isolated **Miniconda** 
environment, since the `bioconda` channel provides precompiled packages for it to install the tool optimally and avoid any compatibility conflicts.

The dataset is then analyzed using a range of potential clusters (K=1 to K=10) through a loop. Once completed, the optimal number of clusters was identified using the built-in `chooseK.py` utility, which outputs both the K that maximizes marginal likelihood and the minimum K required to explain the population structure.

### Usage

```bash
# Create the environment and install fastStructure with its dependencies
conda create -n faststruct -c bioconda faststructure -y

# Activate the environment
conda activate faststruct

# Run fastStructure for K=1 through K=10
for k in 1 2 3 4 5 6 7 8 9 10; do
    structure.py -K $k --input=final_dataset --output=results_faststr --format=bed
done

# Determine the ideal K value
chooseK.py --input=results_faststr
```

### Inputs

- Pruned dataset converted to binary PLINK format (BED/BIM/FAM)

### Outputs

For every evaluated K: 

- Q-matrix containing the estimated ancestry proportions `.meanQ`
- Variance of the Q-matrix `.varQ`

### Tools

- fastSTRUCTURE `v1.0` available at [bioconda/faststructure](https://bioconda.github.io/recipes/faststructure/README.html)
