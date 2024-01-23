PROJECT TITLE: Space Invaders, My Version
Version 1.1.0

PROJECT DESCRIPTION: This is my version of the Arcade classic, "Space Invaders". The player controls a tank that fires projectiles upwards toward an oncoming fleet of invaders. You must defeat the invaders before they reach the ground or before they anihilate you with one of their own lasers! This game is designed to have an infinitely scaling difficulty with each level. There is a secret boss battle as well, but that will just remain a mystery for now. The application also saves the user's top 10 high scores across instances of the application and has custom built in GUI elements. This project was created with the intention of testing my skills in Lua and the LOVE2d framework as taught by Harvard's GD50 course.

HOW TO RUN: Download the Love2d engine (https://love2d.org/) and run the directory using the "love.exe" application.

CREDITS: The project implements built-in libraries from Love2d as well as: OOP class library (https://github.com/vrld/hump), a 'push' library that resizes content to fit a window of a different scale than the scale used in game (https://github.com/Ulydev/push), the knife timer management library (https://github.com/airstruck/knife)

DETAILED DESCRIPTION: The rules for this game are a bit different from the actual Space Invaders game. The object of the game remains the same - to try and obtain a high score by defeating wave after wave of enemy spaceships that descend from above. The player is awarded points for destroying ships in a fleet with an upward firing cannon. The Fleet can defeat the player in two ways: (1) If the fleet reaches the horizontal line just above the player onscreen, or (2) if one of the fleet's bullets happpen to hit the player. The player has 3 'lives' which are automatically expended upon player defeat. Once the player is out of lives, the next defeat is GAME OVER.

Each level (other than the boss levels) begins with a randomized fleet of enemy spaceships, as well as shelters for the player to hide under. The fleet will have a random size (not dependent on level number), and each row will be of a random invader type (certain types only appear after so many levels). The starting speed of the fleet is proportional to the level number (starting speed increases as level number increases), and inversely proportional to the size of the fleet (smaller fleets are faster than larger fleets). This results in varied but balanced gameplay - some levels will involve hitting a small fleet moving very quickly, while others will be about managing fleet size as it slowly descends toward the bottom. There are 3 shelters that act as a barricade for the player. They can both help or hinder, as they block both incoming enemy fire as well as player fire. Shelters are regenerated at the start of each level and after every player defeat.

When the level play begins, the Invaders will begin by moving to the left until the rightmost invaders reach the right side of the playing field. This will trigger the invaders to descend a bit before reversing course. A descent will be triggered again when the leftmost invaders reach the left side of the screen. The fleet will repeat this pattern, increasing slightly in speed with each descent until defeating the player or being destroyed. In later levels, it is essential to focus on outer columns of invaders. Since a descent is triggered when the fleet's outside invaders reach an edge, shrinking the fleet width-wise will slow down the fleet's progression as it will have to travel further horizontally each crossing. Invaders are defeated by one hit from the player's cannon, awarding points to the player. Invaders will randomly fire back towards the player, and the rate at which this occurs is proportional to the level number and inversely proportional to the proportion of the current fleet that have not been destroyed (ships will fire more frequently when there is just a few left). The firing rate of invaders is also dependent on invader types. As soon as the player is defeated or destroys the fleet, the appropriate transition animation will play and a new level will begin (either the next level if the player was victorious, or the same level if the player was defeated).

When a player has run out of lives, a GAME OVER occurs. The player is prompted to enter in his or her initials to keep a record of the high score if his or her score was enough to be in the top 10. Scores are saved between play sessions, and can be viewed from an option on the main menu.

The Invader types determine both the score for defeating one as well as one's firing rate:
(1) - The Flying Saucer/Capitol Building: 50 Points, slowest firing rate
(2) - The Brain Invader/Angry Tooth: 100 Points, slow firing rate
(3) - The Tentacle Invader/Squid Thing: 150 Points, fast firing rate
(4) - The Bug Invader/Scorpion Thing: 200 Points, fastest firing rate

Every 12 Levels, the player will face a Boss Level. Boss levels have the same objective of destroying all invaders, only now there is only one mothership. The mothership will move just like normal invaders, from side to side, descending at turns, until reaching the bottom. The mothership has a host of shield drones that must be defeated in order to make the mothership vulnerable. These drones will orbit the mothership and increase their speed as more are defeated. The mothership will reflect back at the player any shots that hit it before the drones are defeated. Once all drones are defeated, the mothership can be destroyed with a single shot.

MIT License

Copyright (c) 2022 Scott Meadows

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
