#!/usr/bin/env python
# coding: utf-8

# In[ ]:


# Threshold Analysis: Predicting Implantation Failure
# Using Nuclear Diameter and Circularity from Embryo Data


# In[2]:


import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.metrics import roc_curve, auc, classification_report
import numpy as np


# In[8]:


df = pd.read_excel(r"C:\Users\HP\Documents\Embryo_data.xlsx", sheet_name="All Human embryos", skiprows=1)


# In[10]:


df.columns = ["Stage", "Average_diameter", "Circularity", "Outcome"]


# In[11]:


df.dropna(inplace=True)


# In[14]:


df["Outcome_binary"] = df["Outcome"].map({"Successful": 1, "Unsuccessful": 0})


# In[15]:


sns.boxplot(data=df, x="Outcome", y="Average_diameter", palette="Set2")
plt.title("Nuclear Diameter by Outcome")
plt.show()


# In[31]:


sns.boxplot(data=df, x="Outcome", y="Circularity", palette="Set1")
plt.title("Circularity by Outcome")
plt.show()


# In[23]:


def evaluate_threshold(feature, label="Outcome_binary"):
    print(f"\n--- ROC Curve for {feature} ---")
    fpr, tpr, thresholds = roc_curve(df[label], df[feature])
    roc_auc = auc(fpr, tpr)

    # Plot ROC
    plt.figure()
    plt.plot(fpr, tpr, label=f"AUC = {roc_auc:.2f}")
    plt.plot([0, 1], [0, 1], linestyle="--", color='gray')
    plt.xlabel("False Positive Rate")
    plt.ylabel("True Positive Rate")
    plt.title(f"ROC Curve: {feature}")
    plt.legend()
    plt.grid(True)
    plt.show()
    #Best threshold using Youden's index
    youden_index = tpr - fpr
    best_idx = np.argmax(youden_index)
    best_threshold = thresholds[best_idx]
    print(f"Best threshold for {feature} (Youden’s Index): {best_threshold:.2f}")
    return best_threshold


# In[24]:


threshold_diameter = evaluate_threshold("Average_diameter")


# In[25]:


threshold_circularity = evaluate_threshold("Circularity")


# In[26]:


df["Diameter_Predicted_Failure"] = (df["Average_diameter"] > threshold_diameter).astype(int)


# In[27]:


df["Circularity_Predicted_Failure"] = (df["Circularity"] < threshold_circularity).astype(int)


# In[28]:


print("\n--- Evaluation for Diameter Threshold ---")
print(classification_report(df["Outcome_binary"], df["Diameter_Predicted_Failure"]))


# In[29]:


print("\n--- Evaluation for Circularity Threshold ---")
print(classification_report(df["Outcome_binary"], df["Circularity_Predicted_Failure"]))

