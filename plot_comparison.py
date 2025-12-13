import pandas as pd
import matplotlib.pyplot as plt
import os

raw = pd.read_csv('results_raw.csv')
norm = pd.read_csv('results_normalized.csv')

def size_from_name(name):
    if '1MB' in name:
        return 1
    if '10MB' in name:
        return 10
    if '100MB' in name:
        return 100
    for part in name.split('_'):
        if part.endswith('MB'):
            try:
                return int(part.replace('MB',''))
            except:
                pass
    return 0

raw['size_mb'] = raw['dataset'].apply(size_from_name)
norm['size_mb'] = norm['dataset'].apply(size_from_name)

os.makedirs('results_graphs', exist_ok=True)

queries = sorted(raw['query_id'].unique())
for q in queries:
    r = raw[raw['query_id']==q].set_index('size_mb')['time_seconds']
    n = norm[norm['query_id']==q].set_index('size_mb')['time_seconds']
    plt.figure()
    plt.plot(r.index, r.values, marker='o', label='Raw')
    plt.plot(n.index, n.values, marker='o', label='Normalized')
    plt.xlabel('Size (MB)')
    plt.ylabel('Time (s)')
    plt.title(f'Query {q}: Raw vs Normalized')
    plt.legend()
    plt.grid(True)
    plt.savefig(f'results_graphs/query_{q}_comparison.png')
    plt.close()

print('Saved comparison plots in results_graphs/')
