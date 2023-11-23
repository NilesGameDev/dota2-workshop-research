## Advanced Navigation System in Dota 2
Let's first issue some disadvantages of using Source 2's GridNav system implemented in Dota 2:
- The GridNav is generated from the top-down view, thus resulting in very simple 2d plane map for NPCs to navigate upon
- This makes floating platforms (such as bridges - most common use cases) will only be able to navigate on top, not underneath
**Painful! And too bad for games that need such system!**

So, a custom solution can be implemented to tackle this problem:
- Allow GridNav to generate navigation on Terrain only, completely ignore all floating platforms setup in the map -> This immediately solves the underneath navigation problem
- Build a custom navmesh system, that `copy` the GridNav data. Also, add additional floating platforms to "layers" in navmesh -> Multi-layered navmesh, with each layer contain a specific "ground"
- Finally a pathfinding algorithm must be implemented as well, here I use A-star

## WIP custom pathfinding using A-star algorithm
![Dota 2 WIP Custom Pathfinding](https://github.com/NilesGameDev/dota2-workshop-research/assets/22948637/b08cb004-18a3-4d11-abe6-48ebf5970711)

More updates coming soon!

