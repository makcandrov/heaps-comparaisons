# heaps-comparaisons

Comparaisons entre trois tas : le 2-tas du repo `data-structures`, une version optimisée de ce 2-tas, et un 3-tas (tas à trois branches). Ces trois tas s'utilisent exactement de la même manière, et les tests effectués sur chacuns sont exactement les mêmes pour pouvoir bien comparer.
Le test `testFullHeapSort` vérifie que si `maxSortedUsers` = +inf, on a bien une structure qui trie les données.
Les tests `test2HeapStructure` et `test3HeapStructure` vérifient que la structure voulue est bien respectée avant `heap.size`.
Le meilleur test pour comparer les performances est `testFullHeapSort` :

```
forge test --match-test testFullHeapSort --gas-report
```
## 2-tas

![image](https://user-images.githubusercontent.com/108467407/178146732-5d50bb7c-b013-4bdc-b328-69eda64efe70.png)

## 2-tas optimisé

La principale optimisations est la suppression des swaps. En effet, quand on ajoute un utilisateur, la première version l'ajoute à la fin du tas, puis le buuble up jusqu'à sa bonne position. cette version ne l'ajoute pas directement, mais fait d'abord le bubble up en écrasant les noeuds (pas de swap) puis en ajoutant l'élément. Idem lors de la suppression d'un noeud, on écrase les noeuds lors de la descente/remontée au lieu de faire des échanges. Cela économise jusqu'à 15% de gas sur certaines opérations.

![image](https://user-images.githubusercontent.com/108467407/178146875-e38f0758-067f-49c5-bf58-8f8a0c6aa400.png)

## 3-tas

Le 3-tas est un tas avec 3 branches. D'un point de vue purement théorique, cette structure de données est meilleure que le 2-tas [Pour s'en convaicre, pour un k-tas une suppression / un ajout nécessite de l'ordre de $k * log_k(n) = (k / ln(k)) * ln(n)$ opérations. La complexité asymptotique est donc la même $O(ln(n)$ mais la constante de complexité est de l'ordre de $k / ln(k)$, fonction de k qui atteint son minimum sur N en 3, et non en 2]

Ce tas comprend également les optimisations détaillées précédemment. Cette structure économise jusqu'à 30% de gas par rapport à la première.

![image](https://user-images.githubusercontent.com/108467407/178147115-69408ee2-132e-4d6a-b1bc-b8945bc29088.png)
