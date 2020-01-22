function res = normalizeMinMax(data)

res = (data - min(data)) / (max(data) - min(data));