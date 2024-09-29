import pygame
import datetime
import time

pygame.init()
win = pygame.display.set_mode((1920, 1080))
pygame.display.set_caption("Game1")

running = True
clock = pygame.time.Clock()
fps = 120

player_x, player_y = 0, 0
deltatime = 0

background = pygame.image.load("Images/Background_Image.png")

Idles = []
Jumps = []
Walks = []

CurrentIdle = 0
CurrentWalk = 0

IdleTimer = time.time()
JumpTimer = time.time()

# Options
GroundLevelY = 335
GravityForce = 250

JumpTime = 0.2
JumpPower = 350

# Conditions
HitGround = False
JumpDelay = False

Jumping = False
Walking = False

Dir = 1

for i in range(0, 3):
    Idles.insert(i, pygame.image.load("Images/idle_" + str(i) + ".png"))

for i in range(0, 3):
    Jumps.insert(i, pygame.image.load("Images/jump_" + str(i) + ".png"))

for i in range(1, 6):
    Walks.insert(i, pygame.image.load("Images/R" + str(i) + ".png"))

while running:
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False
    #Predraw
    Part1 = pygame.draw.rect(win, (255, 255, 255), pygame.Rect(900, 800, 50, 50))
    PlayerCollider = pygame.draw.rect(win, (255, 0, 0), pygame.Rect(player_x, player_y, 120, 120), 2)
    pygame.display.flip()

    collide = pygame.Rect.colliderect(PlayerCollider, Part1)

    #Movement
    keys = pygame.key.get_pressed()
    if keys[pygame.K_w]:
        if JumpDelay == False and Jumping == False:
            Jumping = True
            JumpDelay = True
            JumpTimer = time.time()
    if keys[pygame.K_a] and collide == False:
        Dir = 0
        Walking = True
        player_x -= 300 * deltatime
    if keys[pygame.K_d]:
        Dir = 1
        Walking = True
        player_x += 300 * deltatime

    #Gravity
    if Jumping == False:
        if player_y < 1080-GroundLevelY:
            player_y += GravityForce * deltatime
            HitGround = False
        else:
            JumpDelay = False
            HitGround = True
            player_y = 1080-GroundLevelY

    #Drawing 
    win.blit(background, (0, 0))

    Idle = Idles[CurrentIdle]
    Jump = Jumps[0]
    Walk = Walks[CurrentWalk]

    if Dir == 0:
        Idle = pygame.transform.flip(Idle, True, False)
        Jump = pygame.transform.flip(Jump, True, False)
        Walk = pygame.transform.flip(Walk, True, False)

    if JumpDelay == False:
        if Walking == False:
            win.blit(Idle, (player_x, player_y))
            PlayerCollider = = 
        else:
            win.blit(Walk, (player_x, player_y))
    else:
        win.blit(Jump, (player_x, player_y))
        
    pygame.display.update()

    #Jumping
    CurrentTimer = time.time()
    if Jumping == True and CurrentTimer-JumpTimer >= JumpTime:
        Jumping = False

    if Jumping == True:
        player_y -= JumpPower * deltatime

    #Idle
    CurrentTimer = time.time()
    if CurrentTimer-IdleTimer >= 0.2:
        CurrentIdle = CurrentIdle + 1
        CurrentWalk = CurrentWalk + 1
        if CurrentIdle >= len(Idles):
           CurrentIdle = 0
        if CurrentWalk >= len(Walks):
           CurrentWalk = 0
        IdleTimer = time.time()

    Walking = False
    deltatime = clock.tick(fps) / 1000

pygame.quit()
