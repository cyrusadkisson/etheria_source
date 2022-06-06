6/6/2022

What is this folder?

When I deployed the Etheria smart contracts in October 2015, I was very keen on the "virtual world" part: a 3-dimensional space with physical rules. 

To this end, the original tile build mechanics for Etheria involved farming for bricks (of various shapes), then coloring and stacking them into shapes. 
Each time a "player" placed a brick, it was checked for three things:

1. Does it stack on the ground or another brick? (i.e. gravity)
2. Does it conflict with any other bricks? (i.e. collision detection)
3. Does it stay within its own boundaries?

I'd like to say these build mechanics were just fine and dandy back when ETH was $0.50 and the network was empty, but that's not even the case. The build mechanics
were very inefficient from the beginning and not really suitable for a blockchain. (This is why we do experiments, people!) The more bricks a player placed, 
the more gas had to be spent to check the previous bricks, and the player very quickly ran into the block gas size limit. (This is the reason the "headless horse" had no head
for a long part of its early life. There wasn't enough gas in an entire block to place one. This was eventually corrected when the block gas limit was raised.)

In any case, the original build mechanics got even more inefficient as time wore on, ETH rose in price and the blocks became clogged.

So, in 2021, I developed an entirely new build scheme. Each tile is simply a 3D image up to 128 layers in the z direction with 9901 voxels per layer. This build data
is created and compressed off-chain, then pushed to the chain for storage. Then, for rendering, it is decompressed into its voxel-by-voxel "bitmap" form, then rendered into 
Three.js shapes for inclusion in the Etheria "scene". (Note the lack of physical rules. The tile is simply a canvas now.)

All builds you see on the etheria.world website are rendered using these new build mechanics. To recreate the old mechanics' builds, I simply recreated them under the new 
build mechanics and render them that way. It's a small sleight-of-hand to make my (and anybody wishing to recreate Etheria's) life easier.

SO WHAT IS THIS FOLDER FOR?!?!?!

This folder is a standalone instance of a website that can render how Etheria looked USING THE OLD BUILD MECHANICS.

It serves as verification that the old mechanics did work (at least somewhat), so nobody has to take my word for it.
