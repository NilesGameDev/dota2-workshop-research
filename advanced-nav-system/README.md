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
![Dota 2 WIP Custom Pathfinding - Trim](https://github.com/NilesGameDev/dota2-workshop-research/assets/22948637/15722d8e-692f-4369-97d6-f003191c32f4)

More updates coming soon!

