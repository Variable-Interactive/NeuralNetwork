# NeuralNetwork

https://github.com/Variable-Interactive/NeuralNetwork/assets/77773850/bc4dfbba-87b8-4835-9ffc-c82acd42c720

this is a simple neural network using my abomination of a genetic algorithm (LoL).

## Motivation:
The main motivation behind this is my personal curiosity. I was curious if it is possible to make a Neural network ENTIRELY in gdscript (Apparently it is).

## Usage:
Note: The code snippets are taken from the `FlappyTest` example game.
1. Use the script in addons/NeuralNetwork/AutoloadAlgorithms/GeneticEvolution.gd as an autoload.
2. In your player script (wherever that is) add a variable to keep track of the `Network`. do not assign anything to it yet (names need not be the same).
   ```
   .
   .
   .
   # other variables
   var ai: Network
   ```
3. Then in `_ready()`, initialize the network as shown
```
########## Initializing the AI Player ###########
if GeneticEvolution.generation_networks.size() == 0:  # If this is the first generation
	ai = Network.new(LAYER_NODES)
else:  # If we have a network provided by genetic algorithm then use it instead
	ai = GeneticEvolution.generation_networks.pop_back()
# you can add a visualizer as well if you want
ai.add_visualizer(GeneticEvolution.visualizer_popup.visualizer_container, modulation)
#################################################
```
   - The array [2, 10, 10, 10, 10, 1] denoted number of node in each layer. The **first** element (2) represents the number of inputs, while the **last** element (1) is the number of outputs/decisions the AI will make. The middle ones are called **Hidden Layers**.
   - The `func add_visualizer(visualizer_parent: Node, color := Color.WHITE)` creates a visual of network and places it as child of `visualizer_parent` (whatever it is).
4. To give input to the AI, so that it can process it and take decision use this code (variable names can be different)
   ```
   #### Setting inputs to the NeuralNetwork ##
	var input = _get_input_points()  # getting the inputs
	var decision = ai.feedforward(input)  # feeding the inputs
	var should_jump = decision[0] > 0.5
	###########################################
   ```
   - The `input` is an array of all inputs the player requires (in float form) to make an informed decision. e.g in case of game flappy bird input can be `[x-coordinate of obstacle opening, y-coordinate of obstacle opening]`
   - The ai will generate an array of `decision` with each element having values between 0 and 1 (In the example the ai only had to decide whether to jump or not so the `decision` contains only one element). We compared it with the jumping threshold (set to 0.5). if `should_jump` comes out to be `true`, the player jumps.
5. Obviously the AI won't work on the 1st attempt. Here's where the GeneticEvolution comes in. when the player fails, submit it's network to the GeneticEvolution
```
########### remove Visualizer ############
ai.destroy_visualizer()
############ Grant a reward based on survival time ###############
ai.give_reward(Time.get_ticks_msec() - initial_time)
# Add to the monitor
GeneticEvolution.submit_network(ai)
###########################################
```
  - In this example the reward was based on survival time so it makes sense to calculate it at the end of the run, but you can give it rewards ar other places as well. To give reward to Network use `func give_reward(amount: int)`. To deduct rewards, use negative sign.
6. Instance the players when the scene is run using
```
# generate amount of players required by players GeneticEvolution algorithm
for _player_idx in GeneticEvolution.players_per_generation:
	var player = player_scene.instantiate()
  ## ...Also add the player to scene using add_child(player)
```
