# Idea Scratchpad
Put any random ideas in this section.

- Research Archetypes
	- Arcane
	- Golemancy
	- Alchemy
	- Chronurgy
	- Druidic
 - Some unlocks gained by sending resources through portal to town
 - Some unlocks gained by research

Change all loading bars to use tweeners with callbacks instead of dedicated timer objects and polling. Check out this link for interruption method: https://docs.godotengine.org/en/stable/classes/class_tween.html#class-tween-method-tween-await

## Todo:
- [x] Inventory Handlers
- [x] World Objects
- [x] Destructables
- [x] Individual Object UIs
- [x] Crafting Handlers 
- [ ] Optimize Object UI System
- [ ] Inventory Agents 
- [ ] Item World Objects
- [ ] Item Transporters
- [ ] Unlocks System
- [ ] NPC System

#### Optimize Object UI System
Currently the object UI system has an individual UI that is hidden for every world object. This will likely create lag when expanded out to many objects since there will be quite a bit of extra overhead. 
May need to test to see if Godot is smart enough to automatically optimize these hidden objects.
If they do result in decreased performance, I'll make object UIs that aren't dependent on the objects themselves, but scenes that get instantiated by the player and linked to the object inventory/crafting handlers.

#### Inventory Agents
Nodes that can transfer items to inventories based on proximity.

#### Item World Objects
Make it so that items can be objects in the world with a quantity. These objects can be interacted with by players and inventory agents.

#### Item Transporters
Create world objects that can transport items between other transporters, agents, or inventories. These transporters should have a maximum range and have selectable targets by the player (possibly using a button in their inventory).

#### Unlocks System
Create a system that somehow converts items into points. These points will be used to unlock new buildings and tech.

#### NPC System
Create an NPC system that allows for different behaviors such as hostile, neutral, defensive, programmed, etc.
This system will require NPCs (and the player) to have assigned teams. Teams should be a Godot resource that has a list of responses to other teams. 
Responses will be:
 - Neutral
 - Hostile
 - Interactable

When this system is created, all world objects that should be interactable by NPCs will need an assigned team as well to designate behavior.
