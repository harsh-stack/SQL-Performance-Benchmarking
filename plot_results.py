import pandas as pd
import matplotlib.pyplot as plt
import os

df = pd.read_csv('results_raw.csv')

# map dataset filenames to numeric sizes
def size_from_name(name):
    if '1MB' in name:
        return 1
    if '10MB' in name:
        return 10
    if '100MB' in name:
        return 100
    # fallback: try to parse digits
    for part in name.split('_'):
        if part.endswith('MB'):
            try:
                return int(part.replace('MB',''))
            except:
                pass
    return 0

df['size_mb'] = df['dataset'].apply(size_from_name)

# pivot so each query is a separate line
pivot = df.pivot_table(index='size_mb', columns='query_id', values='time_seconds', aggfunc='mean').sort_index()

plt.figure(figsize=(8,5))
for col in pivot.columns:
    plt.plot(pivot.index, pivot[col], marker='o', label=f'Query {col}')

plt.xlabel('Dataset Size (MB)')
plt.ylabel('Execution Time (s)')
plt.title('Query timings per dataset size')
plt.grid(True)
plt.legend()
os.makedirs('results_graphs', exist_ok=True)
plt.savefig('results_graphs/query_times.png')
print('Saved results_graphs/query_times.png')
