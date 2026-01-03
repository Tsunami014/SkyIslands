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
COLLISIONS = None
def loadMap(name):
    global MAP, COLLISIONS
    MAP = pygame.image.load(f"map/simplified/{name}/_composite.png")
    with open(f"map/simplified/{name}/TopTiles.csv") as f:
        COLLISIONS = [[i!="0" for i in ln.split(",") if i] for ln in f.readlines()]
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

def check(dx, dy):
    cx, cy = -x + dx + MainSur.get_width()/2, -y + dy + MainSur.get_height()/2
    def check2(x1, y1):
        x1, y1 = math.floor(x1/16), math.floor(y1/16)
        if x1 < 0 or y1 < 0 or y1 >= len(COLLISIONS) or x1 >= len(COLLISIONS[y1]):
            return False
        return COLLISIONS[y1][x1]
    return check2(cx-7, cy-7) and check2(cx+7, cy+8) and check2(cx-7, cy+8) and check2(cx+7, cy-7)

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
        if dy != 0 and check(0, dy):
            realy -= dy
            y = math.floor(realy)
        if dx != 0:
            dir = dx > 0
            if check(dx, 0):
                realx -= dx
                x = math.floor(realx)
    else:
        playerAnim = playerAnimSpeed-1

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

