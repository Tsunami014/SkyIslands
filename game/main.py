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
