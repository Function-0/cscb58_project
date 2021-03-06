CSCB58 Project File: Summer 2017

Team Member A
-------------
First Name: David
Last Name: Yau
Student Number: 1002567563
UofT E-mail Address: david.yau@mail.utoronto.ca


Team Member B
-------------
First Name: Ibrahim
Last Name: Jomaa
Student Number: 1003441411
UofT E-mail Address: ibrahim.jomaa@mail.utoronto.ca

Team Member C (Optional)
-------------
First Name:
Last Name:
Student Number:
UofT E-mail Address:

Team Member D (Optional)
-------------
First Name:
Last Name:
Student Number:
UofT E-mail Address:

Project Details
---------------
Project Title: Impossible Game

Project Description: We will be recreating the Impossible Game which is most commonly played on mobile devices or consoles.
                     This game involves a fast moving square that jumps given the user input and the main goal is to avoid
                     or dodge obstacles by jumping.

Video URL: https://youtu.be/7ztvgNu7B-k

Code URL (please upload a copy of this file to your repository at the end of the project as well, it will
serve as a useful resource for future development): https://github.com/davidy327/cscb58_project


Proposal
--------

What do you plan to have completed by the end of the first lab session?:
  - think of a design plan for the project
  - figure out what we would need to build this project
  - assign tasks to do for each individual and make deadlines

What do you plan to have completed by the end of the second lab session?:
  - get the basics done and discuss any problems

What do you plan to have completed by the end of the third lab session?:
  - should at least have the basic game running at this point but try to go beyond
  - fix any errors we had from previous sessions (ie. screen glitches out when player is moving)

What is your backup plan if things don’t work out as planned?
  - we would probably have to make this game much simpler if things don't go as planned
    ie. making it only with only objects on the ground level.

What hardware will you need beyond the DE2 board
(be sure to e-mail Brian if it’s anything beyond the basics to make sure there’s enough to go around)
  - None

Motivations
-----------
How does this project relate to the material covered in CSCB58?:
  It uses a variety of concepts learned in lectures/labs such as:
  - Rate Divider(FPS Counter)
  - VGA Adapter and Drawing Pixels onto VGA Screen
  - Pseudo-FSM (used multiple inputs to change states of the game)
  - Mux to decide colour and frame rate
  - RAM (mif file)
  - hierarchy model
  - hex decoder/display
Why is this project interesting/cool (for CSCB58 students, and for non CSCB58 students?):
  The Impossible Game is an incredibly addicting game on mobile devices and many students would probably enjoy
  it as much as we did when we played the mobile version.
Why did you personally choose this project?:
  We chose this as our project because we thought it would be a fun experience to recreate a game
  that we both enjoyed when this game was popular. Also, this game seems like it could give us some difficulties
  while recreating it using Verilog and the DE2 board.

Attributions
------------
Provide a complete list of any external resources your project used (attributions should also be included in your
code).
- used an online mif converter from a uoft course site.

Updates
-------
Week 1: We managed to produce the overall flow of the game using finite state machines. As well as drawing the shapes needed for the game.
        During the lab, we had trouble debugging the code where we tried to draw the simple shapes for our game.
        Should try to have the game running by Week 2, but its fine if it doesn't work the way we want to yet.

Week 2: We managed to make the 'level' of the game move from right to left with the 60 FPS counter module which uses the CLOCK_50 port.
        However, on the VGA screen some objects would not display as well as extra pixels being drawn during the process.
        This could be caused by the update screen module or the counter.
        By next lab, we should resolve these problems and finish about 80% of the game. Also, try going to Makerspace to test Verilog code.

Week 3: We managed to add an attempt counter which is outputted on the HEX displays. Also, we managed to fix the jumping problem, and the other
        problems we had in the previous week.
        We should have the overall map/level implemented by Monday and try to test it at the Makerspace on the same day.

Week 4: In the end, we implemented the level for the game. But the jump and collision wasn't working properly.
        And we were very ambitious about this project.
