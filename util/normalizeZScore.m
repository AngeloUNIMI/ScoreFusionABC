function res = normalizeZScore(data)

res = (data - mean(data)) / std(data);