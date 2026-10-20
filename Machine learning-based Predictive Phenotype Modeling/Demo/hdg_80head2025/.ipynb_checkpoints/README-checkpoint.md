# Rice Heading Date Prediction Demo

## Overview

This repository contains a demonstration of using machine learning to predict rice heading dates based on genetic markers. The heading date (time from sowing to flowering) is a critical agricultural trait that affects adaptation to different environments and growing seasons. This demo shows how a pre-trained model can be used to predict heading dates for rice varieties based on their genetic information.

## Contents

- `Heading_Date_Demo.ipynb`: Jupyter notebook with the complete prediction workflow
- `best_trained_model_hdg_80head2025.pkl`: Pre-trained machine learning model
- `hdg_80head2025_to_predict_preprocessed_combined_top_1000_features.csv`: Dataset with genetic markers for prediction
- Output files: `y_pred_new_samples_with_ID_using_ultimate_model.csv` and `rice_heading_date_distribution_predicted.pdf`

## Requirements

- Python 3.7+
- Required Python packages:
  - pandas
  - numpy
  - joblib
  - matplotlib
  - cudf (for GPU acceleration, optional)

## Installation

### Option 1: Install dependencies manually

1. Clone this repository:
   ```
   git clone https://github.com/yourusername/rice-heading-date-prediction.git
   cd rice-heading-date-prediction
   ```

2. Install required dependencies:
   ```
   pip install pandas numpy joblib matplotlib
   ```

3. For GPU acceleration (optional):
   ```
   pip install cudf-cuda11
   ```

### Option 2: Use pre-configured Docker container (Recommended)

A ready-to-use Docker image with all dependencies pre-installed is available. This container includes GPU support and all necessary libraries:

1. Clone this repository and navigate to the directory:
   ```
   git clone https://github.com/yourusername/rice-heading-date-prediction.git
   cd rice-heading-date-prediction
   ```

2. Run the Docker container with GPU support:
   ```
   docker run --gpus all --ipc=host --ulimit memlock=-1 --ulimit stack=67108864 --rm -p 10000:8888 -p 8501:8501 -v ${PWD}:/workspace/mycode abdelghafour1/ngc_tf_rapids_25_01_vscode_torch:2025-v3 jupyter lab --ip=0.0.0.0 --allow-root --NotebookApp.custom_display_url=http://$(hostname):10000
   ```

3. Open the provided URL in your browser to access JupyterLab with the repository mounted at `/workspace/mycode`

## Usage

You can run this demo in two ways: interactively using the Jupyter notebook or directly using the Python script.

### Option 1: Interactive Jupyter Notebook

1. Start Jupyter Lab/Notebook:
   - If using the Docker container:
     ```
     # The JupyterLab instance is already running when you start the container
     # Just open the URL displayed in the terminal
     ```
   - If using local installation:
     ```
     jupyter notebook
     ```

2. Open the notebook:
   ```
   Heading_Date_Demo.ipynb
   ```

3. Run the cells in sequence to:
   - Load the pre-trained model
   - Process the input data
   - Make heading date predictions
   - Visualize the distribution of predicted dates
   - Export the results as PDF and CSV

### Option 2: Run the Python Script

1. Run the script directly from the terminal:
   ```
   python heading_date_predictor.py
   ```

2. The script will automatically:
   - Load the model and data
   - Generate predictions
   - Create a visualization
   - Save both the visualization as PDF and data as CSV in the 'output' folder

## Demo Purpose

This demonstration serves several purposes:

1. **Educational**: Shows a complete ML prediction workflow from data loading to visualization
2. **Research**: Demonstrates how genetic markers can predict important agricultural traits
3. **Practical**: Provides a template for applying similar models to new rice varieties
4. **Visualization**: Illustrates effective ways to visualize prediction distributions

## Data Description

The input data (`hdg_80head2025_to_predict_preprocessed_combined_top_1000_features.csv`) contains:
- **IID**: Unique identifiers for rice varieties/samples
- **Phenotype**: Actual heading date values (days from sowing to heading)
- **Genetic Markers**: The top 1000 genetic markers (SNPs) selected during feature engineering

## Model Information

The pre-trained model (`best_trained_model_hdg_80head2025.pkl`) was trained on a comprehensive dataset of rice varieties with known heading dates. It uses genetic marker information to predict the number of days from sowing to heading for any rice variety with available genetic data.

## Visualization

The notebook includes interactive visualizations that show:
- The distribution of predicted heading dates
- Mean and median values as reference points
- Outlier varieties with extremely early or late heading dates

## Output

The final output is a CSV file containing:
- Rice variety identifiers (IID)
- Predicted heading dates in days


## License

[Include your preferred license information here]

## Citation

If you use this demo in your research, please cite:
[Include citation information for the underlying research, if applicable]

## Contact

[Your contact information]
