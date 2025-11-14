import numpy as np
import matplotlib.pyplot as plt
from scipy.stats import norm

# --- paramètres ---
s = 2
sigma = 1
alpha = 0.05

# seuil selon alpha
seuil = norm.ppf(1 - alpha, loc=0, scale=sigma)

# observation testée
x_obs = 1.7

# distributions
x = np.linspace(-4, 6, 1000)
pdf_H0 = norm.pdf(x, 0, sigma)
pdf_H1 = norm.pdf(x, s, sigma)

# affichage
plt.figure(figsize=(10,6))
plt.plot(x, pdf_H0, label="H0 : bruit seul", color='blue')
plt.plot(x, pdf_H1, label="H1 : signal + bruit", color='red')

# zones colorées
plt.fill_between(x, 0, pdf_H0, where=(x > seuil), color='blue', alpha=0.2, label="fausse alarme")
plt.fill_between(x, 0, pdf_H1, where=(x > seuil), color='red', alpha=0.2, label="détection")

# seuil
plt.axvline(seuil, color='black', linestyle='--', label=f"Seuil = {seuil:.2f}")

# observation testée
plt.scatter(x_obs, norm.pdf(x_obs, 0, sigma), color='blue', s=100, marker='o', edgecolors='black')
plt.scatter(x_obs, norm.pdf(x_obs, s, sigma), color='red', s=100, marker='o', edgecolors='black')
plt.axvline(x_obs, color='green', linestyle='--', label=f"Observation x = {x_obs}")

plt.title("Test de Neyman–Pearson : observation réelle sur les distributions")
plt.xlabel("Valeur observée x")
plt.ylabel("Densité de probabilité")
plt.legend()
plt.grid(True)
plt.show()

# Décision logique
if x_obs > seuil:
    print(f"x_obs = {x_obs} > {seuil:.2f} → Signal détecté (H1)")
else:
    print(f"x_obs = {x_obs} <= {seuil:.2f} → Pas de signal (H0)")
