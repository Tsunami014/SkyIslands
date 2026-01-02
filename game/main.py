import os
os.environ['PYGAME_HIDE_SUPPORT_PROMPT'] = '1'
try:
    import pygame
except ImportError:
    print("Pygame not installed! Attempting to install...")
    import sys
    if os.system(sys.executable + " -m pip install pygame") != 0:
        raise Exception(
            'Install command failed!'
        )
    print("Installed, attempting to start again...")
    import pygame
import math

print("Running...")
pygame.init()

MAP = None
def loadMap(name):
    global MAP
    MAP = pygame.image.load(f"map/simplified/{name}/_composite.png")
loadMap("Level_0")

WIN = pygame.display.set_mode()
scale = 20*16
MainSur = pygame.Surface((scale, int(scale/WIN.get_width() * WIN.get_height())))
pygame.display.toggle_fullscreen()
c = pygame.time.Clock()

player = pygame.image.load("assets/player.png")
playerImgs = [player.subsurface(16*i, 0, 16, 16) for i in range(player.get_width()//16)]
playerAnim = 0
playerAnimSpeed = 8

Tileset = pygame.image.load("assets/tileset.png")
BG_TILE = Tileset.subsurface((0, 0), (32, 32))

realx, realy = 0, 0
x, y = 0, 0
dir = True

run = True
while run:
    for ev in pygame.event.get():
        if ev.type == pygame.QUIT or \
          (ev.type == pygame.KEYDOWN and ev.key == pygame.K_ESCAPE):
            run = False

    inps = pygame.key.get_pressed()
    dx, dy = 0, 0
    if inps[pygame.K_UP]:
        dy -= 1
    if inps[pygame.K_DOWN]:
        dy += 1
    if inps[pygame.K_LEFT]:
        dx -= 1
    if inps[pygame.K_RIGHT]:
        dx += 1
    if dx != 0 or dy != 0:
        playerAnim = (playerAnim + 1) % (3*playerAnimSpeed)
        if dy != 0:
            realy -= dy
            y = math.floor(realy)
        if dx != 0:
            realx -= dx
            x = math.floor(realx)
            dir = dx > 0
    else:
        playerAnim = 0

    for x1 in range(x%32-32, x+32, 32):
        for y1 in range(y%32-32, MainSur.get_height()+32, 32):
            MainSur.blit(BG_TILE, (x1, y1))
    for x1 in range(MAP.get_width()+x, MainSur.get_width()+32, 32):
        for y1 in range(y%32-32, MainSur.get_height()+32, 32):
            MainSur.blit(BG_TILE, (x1, y1))
    for y1 in range(y%32-32, y+32, 32):
        for x1 in range(x, MAP.get_width()+32*2, 32):
            MainSur.blit(BG_TILE, (x1, y1))
    for y1 in range(MAP.get_height()+y, MainSur.get_height()+32, 32):
        for x1 in range(x%32-32, MAP.get_width()+32*2, 32):
            MainSur.blit(BG_TILE, (x1, y1))
    MainSur.blit(MAP, (x, y))
    MainSur.blit(pygame.transform.flip(playerImgs[math.floor(playerAnim/playerAnimSpeed)], dir, False),
                 (MainSur.get_width()//2-8, MainSur.get_height()//2-8))
    WIN.blit(pygame.transform.scale(MainSur, WIN.get_size()),
             (realx%1 * (WIN.get_width()/scale) * 16, realy%1 * (WIN.get_height()/MainSur.get_height()) * 16))
    pygame.display.update()
    c.tick(60)

