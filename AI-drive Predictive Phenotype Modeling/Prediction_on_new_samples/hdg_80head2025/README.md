# Rice Heading Date Prediction Demo

## Project Overview

This repository contains a demonstration of using machine learning to predict rice heading dates from genetic markers (SNPs). Heading date is a critical agricultural trait that determines when rice plants flower and subsequently produce grain. Accurate prediction of heading dates can help breeders develop new varieties with optimal growing seasons for different regions.

## Repository Structure

- `Prediction_on_new_samples.ipynb` - Notebook for applying trained models to new rice samples
- `best_trained_model_hdg_80head2025.pkl` - Pre-trained model for heading date prediction
- `combined_selected_features_top_1000.csv` - List of selected genetic markers
- `most_freq_imputer_hdg_80head2025.pkl` - Imputer for handling missing genetic data

## Prerequisites

This project requires the following dependencies:

- Python 3.7+
- RAPIDS cuDF (for GPU acceleration)
- pandas
- numpy
- matplotlib
- scikit-learn
- joblib

You'll also need the following data files :
- `best_trained_model_hdg_80head2025.pkl` - Pre-trained model for heading date prediction
- `combined_selected_features_top_1000.csv` - List of selected genetic markers
- `most_freq_imputer_hdg_80head2025.pkl` - Imputer for handling missing genetic data
- Genotype files in HapMap format (`.hmp`) containing rice genetic markers (not included in this repository)

## Running with Docker (Recommended)

The easiest way to run this project is using our pre-configured Docker container that includes all dependencies and GPU support:

1. Install Docker and NVIDIA Container Toolkit (for GPU support)

2. Run the Docker container:
```bash
docker run --gpus all --ipc=host --ulimit memlock=-1 --ulimit stack=67108864 \
    --rm -p 10000:8888 -p 8501:8501 \
    -v ${PWD}:/workspace/mycode \
    abdelghafour1/ngc_tf_rapids_25_01_vscode_torch:2025-v3 \
    jupyter lab --ip=0.0.0.0 --allow-root \
    --NotebookApp.custom_display_url=http://$(hostname):10000
```

This command:
- Enables GPU support (`--gpus all`)
- Maps port 10000 to JupyterLab
- Mounts your current directory to /workspace/mycode
- Includes all required dependencies
- Provides a ready-to-use JupyterLab environment

## Manual Installation (Alternative)

If you prefer not to use Docker, you can install dependencies manually:

1. Clone this repository:
```bash
git clone https://github.com/your-username/rice-heading-date-prediction.git
cd rice-heading-date-prediction
```

2. Create a conda environment with required dependencies:
```bash
conda create -n rice-prediction python=3.9
conda activate rice-prediction
conda install -c rapids -c conda-forge cudf pandas numpy matplotlib scikit-learn joblib
```

## Using the Prediction Notebook

The `Prediction_on_new_samples.ipynb` notebook demonstrates how to predict rice heading dates for new samples:

1. **Setup**: First cells load necessary libraries and the pre-trained model
2. **Data Import**: Load new genotype data in HapMap format
3. **Feature Selection**: Apply feature selection to focus on relevant genetic markers
4. **Preprocessing**: Handle missing values through imputation
5. **Prediction**: Generate heading date predictions for all samples
6. **Visualization**: Create a histogram showing the distribution of predicted heading dates
7. **Export**: Save results as CSV file and visualization as PDF

## Data Format Requirements

Input genotype files should be in HapMap format with:
- An 'ID' column containing unique sample identifiers
- SNP marker columns with values typically coded as 0, 1, 2 (representing allele dosages)
- Missing values coded as -9

## Example Usage Workflow

1. Prepare your genotype file in HapMap format
2. Update the file path in cell 3 of the prediction notebook
3. Run all cells in the notebook
4. Find results in the 'output' directory:
   - `heading_date_predictions_on_new_samples_with_ID_using_ultimate_model.csv`
   - `rice_heading_date_distribution_predicted.pdf`

## Interpreting Results

The predicted heading dates represent the estimated number of days from planting to heading. These values:
- Typically range from 60-120 days depending on rice variety
- May vary based on genetic background (e.g., indica vs. japonica)
- Should be interpreted within the genetic context of your samples

## Technical Details

- **Model**: The pre-trained model was developed using machine learning techniques on a large rice diversity panel
- **Feature Selection**: The top 1,000 most informative genetic markers were selected from genome-wide data
- **Imputation**: Missing values are imputed using a frequency-based approach
- **GPU Acceleration**: RAPIDS cuDF is used to accelerate pandas operations where possible

## Citation

If using this code or model in your research, please cite:
[Include citation information for the underlying research]


## License

[MIT License](LICENSE)

## Author

Dr. Abdelghafour HALIMI

## Contact

For questions or collaboration opportunities, please contact [your-email@example.com]
