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

Tileset = pygame.image.load("assets/tileset.png")
BG_TILE = Tileset.subsurface((0, 0), (32, 32))

run = True
while run:
    for ev in pygame.event.get():
        if ev.type == pygame.QUIT or \
          (ev.type == pygame.KEYDOWN and ev.key == pygame.K_ESCAPE):
            run = False

    for x in range(MAP.get_width(), MainSur.get_width()+32, 32):
        for y in range(0, MainSur.get_height()+32, 32):
            MainSur.blit(BG_TILE, (x, y))
    for y in range(MAP.get_height(), MainSur.get_height()+32, 32):
        for x in range(0, MAP.get_width(), 32):
            MainSur.blit(BG_TILE, (x, y))
    MainSur.blit(MAP, (0, 0))
    WIN.blit(pygame.transform.scale(MainSur, WIN.get_size()), (0, 0))
    pygame.display.update()
    c.tick(60)

