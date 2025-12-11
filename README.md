# Flight Delay Network Analysis Using Statistical Network Models

This repository contains the code, analysis, and report for a project exploring **route-level flight delay prediction** using **statistical network models**. The goal is to determine whether the network structure among U.S. airports can improve the prediction of delay propagation beyond simple baseline models.

The project constructs a directed airport network using BTS flight data and applies several models—including **SBM**, **ERGMM**, and **ERGM**—to evaluate how structural dependencies influence delays.

---

## 🚀 Project Overview

Flight delays often propagate through the national air transportation system due to route connectivity, shared aircraft rotations, weather exposure, and operational dependencies.

This project asks:

> **Can network-based statistical models improve the prediction of which routes will experience delays?**

Models evaluated:

- **Independent Edge Model**  
- **Stochastic Block Model (SBM)**  
- **Latent Space Model (ERGMM)**  
- **Exponential Random Graph Model (ERGM)**  

Training month: **January 2024**  
Testing month: **February 2024**

---

## 📊 Dataset

Data source: **U.S. Bureau of Transportation Statistics (BTS)** — On-Time Performance dataset.

Key details:

- ~525K flights in training, ~515K in testing  
- Top **150 busiest airports** selected  
- **4,728 directed routes** (edges in network)  
- Binary delay label: `ARR_DELAY > 15` minutes  

Each route is aggregated using:

- number of flights  
- number of delayed flights  
- delay proportion  
- majority-delay indicator (binary)

---

## 🧹 Preprocessing

Steps performed:

1. Load BTS CSV files  
2. Normalize column names  
3. Remove cancelled or invalid records  
4. Extract origin, destination, and delay fields  
5. Construct binary delay indicator  
6. Select the top 150 U.S. airports  
7. Aggregate flight-level data into route-level statistics  
8. Build adjacency matrices and network objects (`igraph`, `network`)

---

## 🧠 Models Implemented

### **1. Independent Edge Model**  
Baseline assuming all routes share the same delay probability.

### **2. Stochastic Block Model (SBM)**  
- Clusters airports into latent communities  
- Fits models for **K = 2 to 5**  
- Selects best K using **ICL**  
- Captures region-level or operational similarities

### **3. Latent Space Model (ERGMM)**  
- Embeds airports in a **2D latent Euclidean space**  
- Delay probability decreases with latent distance  
- **Best performing model (AUC = 0.629)**

### **4. Exponential Random Graph Model (ERGM)**  
- Includes terms for:
  - edges  
  - reciprocity  
  - clustering (GWESP)  
- Provides structural insight though weaker predictive performance

---

## 📈 Key Results

| Model | AUC | Accuracy |
|-------|------|----------|
| **ERGMM** | **0.6290** | 0.9925 |
| Independent Edge | 0.5000 | 0.9925 |
| ERGM | 0.4591 | 0.9925 |
| SBM | 0.3586 | 0.2366 |

**ERGMM significantly outperforms all other models**, showing that latent operational similarity among airports is the strongest structural predictor of delays.

---

## ⚠️ Limitations

- Binary delay label (loses granularity)  
- No weather, carrier, or aircraft rotation features  
- ERGM scaling limitations for large networks  
- Only two months of data analyzed  

---

## 🚧 Future Work

- Include weather and operational covariates  
- Build multi-month dynamic network models  
- Predict continuous delay values  
- Explore Graph Neural Networks (GNNs)  
- Real-time delay forecasting using streaming data  

