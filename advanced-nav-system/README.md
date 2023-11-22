## Advanced Navigation System in Dota 2
Let's first issue some disadvantages of using Source 2's GridNav system implemented in Dota 2:
- The GridNav is generated as top-down view, thus result in very simple 2d plan map for NPCs to navigate upon
- This makes floating platforms (such as bridges - most common use cases) will only be able to navigate on top, not underneath
**Painful!**

Thus, a simple solutions can be implemented to tackle this problem:
- Allow GridNav to generate navigation on Terrain only, completely ignore all floating platforms setup in the map -> This immediately solves the underneath navigation problem
- Secondly, to able to walk on the bridge, apply a modifier to the corresponding NPC to update the Z-axis position upward by each frame, meaning make sure the `NPC height = platform height`

Although there's more to come, like how can we update the navigation data acknowledging the above approach? Tune in as I may update the repositor with some gifs soon!

## WIP custom pathfinding using A-star algorithm
![Dota 2 WIP Custom Pathfinding](https://github.com/NilesGameDev/dota2-workshop-research/assets/22948637/b08cb004-18a3-4d11-abe6-48ebf5970711)

More updates coming soon!

