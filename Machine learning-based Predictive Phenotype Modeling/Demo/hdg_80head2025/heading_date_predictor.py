#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
Rice Heading Date Prediction Script

This script demonstrates how to use a pre-trained machine learning model to predict 
rice heading dates based on genetic markers. It covers loading a model, making predictions,
visualizing the distribution of predicted values, and saving outputs as PDF and CSV files.

Requirements:
- Python 3.7+
- Required packages: pandas, numpy, joblib, matplotlib
"""

import os
import cudf.pandas
cudf.pandas.install()
import pandas as pd
import numpy as np
import joblib
import matplotlib.pyplot as plt
from datetime import datetime


def main():
    """
    Main function to run the rice heading date prediction workflow.
    """
    print("Rice Heading Date Prediction Demo")
    print("=" * 80)
    
    # Step 2: Load the pre-trained model
    print("\nLoading pre-trained model...")
    try:
        model_path = 'best_trained_model_hdg_80head2025.pkl'
        best_model_for_deployment = joblib.load(model_path)
        print(f"✓ Model loaded from '{model_path}'")
    except Exception as e:
        print(f"❌ Error loading model: {e}")
        return
    
    # Step 3: Load the test dataset
    print("\nLoading test dataset...")
    try:
        data_path = "hdg_80head2025_to_predict_preprocessed_combined_top_1000_features.csv"
        df_to_predict = pd.read_csv(data_path)
        print(f"✓ Dataset loaded from '{data_path}'")
        print(f"  • Total samples: {len(df_to_predict)}")
    except Exception as e:
        print(f"❌ Error loading dataset: {e}")
        return
    
    # Step 4: Display dataset info
    print(f"\nDataset structure:")
    print(f"  • Shape: {df_to_predict.shape}")
    print(f"  • Columns: IID, Phenotype, + {df_to_predict.shape[1]-2} genetic markers")
    
    # Step 5: Prepare data for prediction
    print("\nPreparing data for prediction...")
    try:
        # Extract features and target variables
        y_new = df_to_predict['Phenotype'].values
        X_new = df_to_predict.drop(columns=["IID", "Phenotype"]).values
        
        # Convert to NumPy arrays with float64 data type
        y_new = np.array(y_new, dtype=np.float64)
        X_new = np.array(X_new, dtype=np.float64)
        
        print(f"✓ Data prepared for prediction")
        print(f"  • Features shape: {X_new.shape}")
    except Exception as e:
        print(f"❌ Error preparing data: {e}")
        return
    
    # Step 6: Make predictions
    print("\nMaking predictions with the pre-trained model...")
    try:
        y_pred_new = best_model_for_deployment.predict(X_new)
        print(f"✓ Predictions generated successfully")
    except Exception as e:
        print(f"❌ Error making predictions: {e}")
        return
    
    # Step 7: Create results DataFrame
    print("\nOrganizing predictions into a DataFrame...")
    df_y_pred = pd.DataFrame({
        "IID": df_to_predict["IID"],  # Sample identifiers from original data
        "y_pred_new": y_pred_new      # Predicted heading dates from our model
    })
    
    # Step 8: Visualize the distribution
    print("\nGenerating visualization of heading date distribution...")
    try:
        # Make a copy of the predictions data to avoid modifying the original
        data = df_y_pred.copy()
        
        # Update the DataFrame with modified data
        df_y_pred = pd.DataFrame(data)
        
        # Calculate statistics for annotations
        mean_pred = df_y_pred['y_pred_new'].mean()
        median_pred = df_y_pred['y_pred_new'].median()
        
        # --- Create Matplotlib Figure and Axes ---
        # Set figure size (12x7 inches)
        fig, ax = plt.subplots(figsize=(12, 7))
        
        # --- Create Matplotlib Histogram ---
        # Use 30 bins for the histogram
        n_bins = 30
        counts, bins, patches = ax.hist(df_y_pred['y_pred_new'], bins=n_bins, edgecolor='k', alpha=0.7)
        
        # --- Add Mean and Median Lines ---
        ax.axvline(mean_pred, color='red', linestyle='--', linewidth=2, label=f'Mean: {mean_pred:.2f}')
        ax.axvline(median_pred, color='green', linestyle='--', linewidth=2, label=f'Median: {median_pred:.2f}')
        
        # --- Add Text Annotations for Mean/Median ---
        # Find a suitable y-position for the text annotations
        max_freq = counts.max()
        text_y = max_freq * 1.02  # Position text slightly above the max bar
        
        # Add text annotations
        ax.text(mean_pred, text_y, f'Mean: {mean_pred:.2f}', color='red', ha='center', va='bottom', fontsize=10)
        ax.text(median_pred, text_y * 0.98, f'Median: {median_pred:.2f}', color='green', ha='center', va='top', fontsize=10)
        
        # --- Enhance Layout ---
        ax.set_title('Distribution of Predicted Rice Heading Dates', fontsize=16)
        ax.set_xlabel('Predicted Heading Date', fontsize=12)
        ax.set_ylabel('Frequency', fontsize=12)
        ax.grid(True, linestyle='--', alpha=0.6)
        
        # Add a legend
        ax.legend()
        
        # Ensure layout is tight to prevent labels overlapping
        fig.tight_layout()
        
        print(f"✓ Visualization generated")
        print(f"  • Mean heading date: {mean_pred:.2f} days")
        print(f"  • Median heading date: {median_pred:.2f} days")
        
    except Exception as e:
        print(f"❌ Error generating visualization: {e}")
        return
    
    # Step 9: Save visualization as PDF
    print("\nSaving visualization as PDF...")
    try:
        # Create output directory if it doesn't exist
        os.makedirs('output', exist_ok=True)
        
        # Define filename with timestamp
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        pdf_filename = f"output/rice_heading_date_distribution_predicted.pdf"
        
        # Save the figure as PDF with high resolution
        fig.savefig(pdf_filename, dpi=300, bbox_inches='tight')
        print(f"✓ Figure saved as '{pdf_filename}'")
    except Exception as e:
        print(f"❌ Error saving PDF: {e}")
        return
    
    # Step 10: Export prediction results
    print("\nSaving prediction results to CSV...")
    try:
        csv_filename = f"output/heading_date_predictions_on_new_samples_with_ID_using_ultimate_model.csv"
        df_y_pred.to_csv(csv_filename, index=False)
        print(f"✓ Predictions saved as '{csv_filename}'")
    except Exception as e:
        print(f"❌ Error saving CSV: {e}")
    
    print("\nAll tasks completed successfully!")
    print("=" * 80)
    print("\nSummary of outputs:")
    print(f"  • Figure: '{pdf_filename}'")
    print(f"  • Data: '{csv_filename}'")
    

if __name__ == "__main__":
    main()
