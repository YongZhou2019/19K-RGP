# AI-driven Predictive Phenotype Modeling

## Project Overview

This repository contains tools and demonstrations for predicting rice heading dates using machine learning models trained on genetic markers (SNPs). Heading date, the time from sowing to flowering, is a critical agricultural trait that determines adaptation to different environments and growing seasons.

The project is organized into two main components:

1. **Demo** - A simplified demonstration of the prediction workflow
2. **Prediction_on_new_samples** - A complete toolkit for applying model to new rice heading date samples

## Repository Structure

```
Demo/
├── hdg_80head2025/
│   ├── best_trained_model_hdg_80head2025.pkl       # Pre-trained ML model
│   ├── hdg_80head2025_to_predict_preprocessed_combined_top_1000_features.csv  # Example dataset
│   ├── Heading_Date_Demo.ipynb                     # Interactive demo notebook
│   ├── heading_date_predictor.py                   # Standalone prediction script
│   ├── README.md                                   # Demo documentation
│   └── output/                                     # Example output files
│       ├── heading_date_predictions_on_new_samples_with_ID_using_ultimate_model.csv
│       └── rice_heading_date_distribution_predicted.pdf

Prediction_on_new_samples/
├── hdg_80head2025/
│   ├── best_trained_model_hdg_80head2025.pkl       # Pre-trained ML model
│   ├── combined_selected_features_top_1000.csv     # Selected genetic markers
│   ├── most_freq_imputer_hdg_80head2025.pkl        # Imputer for missing data
│   ├── Prediction_on_new_samples.ipynb             # Notebook for new predictions
│   ├── README.md                                   # Detailed documentation
│   └── output/                                     # Output files
│       ├── heading_date_predictions_on_new_samples_with_ID_using_ultimate_model.csv
│       └── rice_heading_date_distribution_predicted.pdf
```

## Demo Folder

The `Demo` folder contains a simplified demonstration of the heading date prediction workflow:

- Interactive Jupyter notebook showing the complete prediction process
- Pre-trained model and example dataset for immediate testing
- Standalone Python script for automated prediction
- Visualization tools to interpret prediction results

This is ideal for users who want to understand the prediction workflow or quickly test the model with provided data.

## Prediction_on_new_samples Folder

The `Prediction_on_new_samples` folder provides a complete toolkit for applying the trained models to new rice trait samples:

- Comprehensive Jupyter notebook for processing new genotype data
- Tools for data preprocessing, including feature selection and missing value imputation
- Visualization functions for analyzing prediction distributions
- Detailed documentation on data requirements and interpretation

This is designed for researchers who need to apply the model to their own rice varieties with genotype data.

## Key Features

- **GPU-accelerated** processing using RAPIDS cuDF for handling large genetic datasets
- **Production-ready** Docker container with all dependencies pre-installed
- **Visualization tools** for interpreting prediction results
- **Feature selection** to focus on the most informative genetic markers
- **Missing data handling** through sophisticated imputation techniques

## Requirements

- Python 3.7+
- Required Python packages:
  - pandas
  - numpy
  - joblib
  - matplotlib
  - scikit-learn
  - cudf (for GPU acceleration, optional)

## Docker Support

Both components include support for a pre-configured Docker container with all dependencies:

```bash
docker run --gpus all --ipc=host --ulimit memlock=-1 --ulimit stack=67108864 \
  --rm -p 10000:8888 -p 8501:8501 \
  -v ${PWD}:/workspace/mycode \
  abdelghafour1/ngc_tf_rapids_25_01_vscode_torch:2025-v3 \
  jupyter lab --ip=0.0.0.0 --allow-root \
  --NotebookApp.custom_display_url=http://$(hostname):10000
```

## Getting Started

1. Choose the appropriate component:
   - For a quick demo with provided data: Use the `Demo` folder
   - For predictions on your own rice varieties: Use the `Prediction_on_new_samples` folder

2. Follow the instructions in the respective README.md files

## Model Information

The pre-trained model was developed using machine learning techniques trained on a diverse panel of rice varieties with known heading dates. It uses the top 1,000 most informative genetic markers selected during feature engineering.

## Citation

If you use this project in your research, please cite:
[Include citation information for the underlying research]

## License

[MIT License](LICENSE)

## Author

Dr. Abdelghafour HALIMI

## Contact

For questions or collaboration opportunities, please contact [your-email@example.com]