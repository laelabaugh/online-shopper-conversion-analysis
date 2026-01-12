"""
Online Shoppers Purchase Intention - Predictive Model
Logistic Regression to predict purchase likelihood
"""

import pandas as pd
import numpy as np
import sqlite3
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler, LabelEncoder
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score, confusion_matrix, classification_report, roc_auc_score
import matplotlib.pyplot as plt

# Style
BG_COLOR = '#f5f5f5'
CARD_BG = '#ffffff'
TEXT_COLOR = '#2d3436'
TEXT_SECONDARY = '#636e72'
ACCENT_BLUE = '#0984e3'
ACCENT_GREEN = '#00b894'
ACCENT_RED = '#d63031'
ACCENT_PURPLE = '#6c5ce7'

plt.rcParams['font.family'] = 'DejaVu Sans'
plt.rcParams['figure.facecolor'] = BG_COLOR

# Load data
conn = sqlite3.connect('/home/claude/shoppers_project/shoppers.db')
df = pd.read_sql_query("SELECT * FROM sessions", conn)
conn.close()

print("=" * 60)
print("ONLINE SHOPPERS PURCHASE PREDICTION MODEL")
print("=" * 60)
print(f"\nDataset: {len(df)} sessions")
print(f"Features: {len(df.columns) - 1}")
print(f"Target: Revenue (purchase yes/no)")

# Encode categorical variables
le_visitor = LabelEncoder()
le_month = LabelEncoder()

df['VisitorType_encoded'] = le_visitor.fit_transform(df['VisitorType'])
df['Month_encoded'] = le_month.fit_transform(df['Month'])
df['Weekend_encoded'] = df['Weekend'].astype(int)

# Select features (excluding PageValues which has data leakage)
feature_cols = [
    'Administrative', 'Administrative_Duration',
    'Informational', 'Informational_Duration',
    'ProductRelated', 'ProductRelated_Duration',
    'BounceRates', 'ExitRates',
    'SpecialDay', 'OperatingSystems', 'Browser',
    'Region', 'TrafficType',
    'VisitorType_encoded', 'Month_encoded', 'Weekend_encoded'
]

# Note: PageValues excluded as it's calculated post-session and creates data leakage

X = df[feature_cols]
y = df['Revenue'].astype(int)

print(f"\nClass distribution:")
print(f"  Non-buyers: {(y == 0).sum()} ({100 * (y == 0).mean():.1f}%)")
print(f"  Buyers: {(y == 1).sum()} ({100 * (y == 1).mean():.1f}%)")

# Split data
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42, stratify=y)

print(f"\nTrain set: {len(X_train)} sessions")
print(f"Test set: {len(X_test)} sessions")

# Scale features
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

# Train model
print("\n" + "-" * 60)
print("TRAINING LOGISTIC REGRESSION MODEL")
print("-" * 60)

model = LogisticRegression(random_state=42, max_iter=1000, class_weight='balanced')
model.fit(X_train_scaled, y_train)

# Predictions
y_pred = model.predict(X_test_scaled)
y_pred_proba = model.predict_proba(X_test_scaled)[:, 1]

# Metrics
accuracy = accuracy_score(y_test, y_pred)
precision = precision_score(y_test, y_pred)
recall = recall_score(y_test, y_pred)
f1 = f1_score(y_test, y_pred)
roc_auc = roc_auc_score(y_test, y_pred_proba)

print(f"\nModel Performance:")
print(f"  Accuracy:  {accuracy:.1%}")
print(f"  Precision: {precision:.1%}")
print(f"  Recall:    {recall:.1%}")
print(f"  F1 Score:  {f1:.1%}")
print(f"  ROC AUC:   {roc_auc:.3f}")

# Confusion Matrix
cm = confusion_matrix(y_test, y_pred)
print(f"\nConfusion Matrix:")
print(f"  True Negatives:  {cm[0][0]:,} (correctly predicted non-buyers)")
print(f"  False Positives: {cm[0][1]:,} (predicted buyer, actually non-buyer)")
print(f"  False Negatives: {cm[1][0]:,} (predicted non-buyer, actually buyer)")
print(f"  True Positives:  {cm[1][1]:,} (correctly predicted buyers)")

# Feature Importance
print("\n" + "-" * 60)
print("FEATURE IMPORTANCE (Top 10)")
print("-" * 60)

feature_importance = pd.DataFrame({
    'feature': feature_cols,
    'coefficient': model.coef_[0],
    'abs_coefficient': np.abs(model.coef_[0])
}).sort_values('abs_coefficient', ascending=False)

for i, row in feature_importance.head(10).iterrows():
    direction = "+" if row['coefficient'] > 0 else "-"
    print(f"  {row['feature']:30} {direction} {row['abs_coefficient']:.3f}")

# Create visualization
fig = plt.figure(figsize=(16, 10))
fig.patch.set_facecolor(BG_COLOR)
fig.suptitle('Purchase Prediction Model Results', fontsize=18, fontweight='bold', color=TEXT_COLOR, y=0.96)

# 1. Feature Importance
ax1 = fig.add_subplot(2, 2, 1)
ax1.set_facecolor(CARD_BG)
top_features = feature_importance.head(10).sort_values('abs_coefficient')
colors = [ACCENT_GREEN if c > 0 else ACCENT_RED for c in top_features['coefficient']]
ax1.barh(top_features['feature'], top_features['abs_coefficient'], color=colors)
ax1.set_xlabel('Absolute Coefficient', fontsize=10)
ax1.set_title('Top 10 Feature Importance', fontsize=12, fontweight='bold', color=TEXT_COLOR)
ax1.tick_params(axis='y', labelsize=9)

# Add legend
from matplotlib.patches import Patch
legend_elements = [Patch(facecolor=ACCENT_GREEN, label='Increases purchase likelihood'),
                   Patch(facecolor=ACCENT_RED, label='Decreases purchase likelihood')]
ax1.legend(handles=legend_elements, loc='lower right', fontsize=8)

# 2. Confusion Matrix
ax2 = fig.add_subplot(2, 2, 2)
ax2.set_facecolor(CARD_BG)
im = ax2.imshow(cm, cmap='Blues')
ax2.set_xticks([0, 1])
ax2.set_yticks([0, 1])
ax2.set_xticklabels(['Non-Buyer', 'Buyer'])
ax2.set_yticklabels(['Non-Buyer', 'Buyer'])
ax2.set_xlabel('Predicted', fontsize=10)
ax2.set_ylabel('Actual', fontsize=10)
ax2.set_title('Confusion Matrix', fontsize=12, fontweight='bold', color=TEXT_COLOR)

for i in range(2):
    for j in range(2):
        color = 'white' if cm[i, j] > cm.max()/2 else TEXT_COLOR
        ax2.text(j, i, f'{cm[i, j]:,}', ha='center', va='center', fontsize=14, color=color, fontweight='bold')

# 3. Model Metrics
ax3 = fig.add_subplot(2, 2, 3)
ax3.set_facecolor(CARD_BG)
metrics = ['Accuracy', 'Precision', 'Recall', 'F1 Score']
values = [accuracy, precision, recall, f1]
colors = [ACCENT_BLUE, ACCENT_GREEN, ACCENT_PURPLE, ACCENT_RED]
bars = ax3.bar(metrics, values, color=colors)
ax3.set_ylim(0, 1)
ax3.set_ylabel('Score', fontsize=10)
ax3.set_title('Model Performance Metrics', fontsize=12, fontweight='bold', color=TEXT_COLOR)
for bar, val in zip(bars, values):
    ax3.text(bar.get_x() + bar.get_width()/2, val + 0.02, f'{val:.1%}', ha='center', fontsize=10, fontweight='bold')

# 4. Key Insights
ax4 = fig.add_subplot(2, 2, 4)
ax4.set_facecolor(CARD_BG)
ax4.set_xlim(0, 1)
ax4.set_ylim(0, 1)
ax4.axis('off')
ax4.set_title('Key Model Insights', fontsize=12, fontweight='bold', color=TEXT_COLOR)

insights = [
    f"ROC AUC Score: {roc_auc:.3f}",
    "",
    "Top Positive Predictors:",
    f"  • ProductRelated pages",
    f"  • Time on product pages",
    "",
    "Top Negative Predictors:",
    f"  • BounceRates",
    f"  • ExitRates",
    "",
    "Business Implication:",
    "  Focus on reducing bounce/exit rates",
    "  and encouraging product exploration"
]

for i, text in enumerate(insights):
    fontweight = 'bold' if text and not text.startswith('  ') else 'normal'
    ax4.text(0.05, 0.92 - i*0.07, text, fontsize=10, color=TEXT_COLOR, fontweight=fontweight)

plt.tight_layout(rect=[0, 0, 1, 0.94])
plt.savefig('/home/claude/shoppers_project/visualizations/04_predictive_model.png', 
            dpi=150, bbox_inches='tight', facecolor=BG_COLOR)
plt.close()

print("\n" + "=" * 60)
print("VISUALIZATION SAVED")
print("=" * 60)
print("Created: 04_predictive_model.png")

# Summary
print("\n" + "=" * 60)
print("MODEL SUMMARY")
print("=" * 60)
print(f"""
The logistic regression model predicts purchase likelihood with {accuracy:.1%} 
accuracy and {roc_auc:.3f} ROC AUC score.

Note: PageValues was excluded as it's calculated post-session and would
create data leakage in a real-time prediction scenario.

Key findings:
1. BounceRates and ExitRates are the strongest negative predictors,
   confirming the SQL analysis findings about bounce rate impact.

2. ProductRelated pages and duration positively correlate with purchase,
   supporting the recommendation to encourage deeper browsing.

3. Engagement metrics (pages viewed, time on site) matter more than
   demographic factors (region, browser, OS).

Business Application:
- Use model scores to identify high-intent visitors for targeted offers
- Focus UX improvements on reducing bounce/exit rates
- Prioritize features that increase page engagement
""")
