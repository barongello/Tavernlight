// DISCLAIMER
// 
// I am no expert at shaders and it is my first attempt to create such effect. So,
// as long as I replicated the desired effect, it is probably not the right way of
// achieving it. I hope my efforts are taken into account (laughing with a tear)
// 
// The vortex's texture has its width and height as multiples of the tileSize. It
// is 96x64 pixels, meaning a 3x2 tileset with 32x32 pixels each tile. This info is
// kinda hardcoded in this code for the sake of simplicity, but all these values
// can be passed to the shader through uniforms to make the shader more versatile
// and value independent



uniform sampler2D u_Tex0;                  // Game texture
uniform sampler2D u_Tex1;                  // Vortex textures
varying vec2      v_TexCoord;              // Texture coordinates
uniform float     u_Time;                  // Ellapsed time

const int         tileSize     = 32;       // Tile size, used to subdivide the game screen
const vec2        tileOffset   = vec2(8);  // Tile offset to get the player correct position on screen
const ivec2       spritesCount = ivec2(3); // Vortex's sprites count
const int         radius       = 3;        // Radius of the vortex effect, from player position

vec2              middleTile;              // Will hold the middle tile, aka player position



// Check if tile is the bottom part of the vortex
bool isVortexBottom(ivec2 tile)
{
  // Do not consider the player position to have a vortex
  if (tile == middleTile)
  {
    return false;
  }

  // Check if the tile is within the effect radius
  return (distance(tile, middleTile) <= radius);
}

// Check if tile is the upper part of the vortex
bool isVortexTop(ivec2 tile)
{
  // It is, if the bottom tile is the vortex bottom
  return isVortexBottom(tile + ivec2(0, 1));
}

// Check if the vortex is visible based on time, just to not show all at once or
// at the same time
bool isVortexVisible(ivec2 tile)
{
  float c = cos(tile.x * tile.y * (u_Time + 1337) / 100);

  return (c > -0.35 && c < 0.25);
}

// Get a "random" vortex row to draw, to animate it
int getVortexRow(ivec2 tile)
{
  return ((tile.x * 1117 + tile.y * 73 * (int(u_Time) % 5)) % spritesCount.y);
}

// Get a "random" vortex sprite to draw, to animate it
int getVortexIndex(ivec2 tile)
{
  return (int(tile.x * 73 + tile.y * 1117 * u_Time / 1000) % spritesCount.x);
}

void main(void)
{
  // Store game and vortex textures' size
  ivec2 gameSize    = textureSize(u_Tex0, 0);
  ivec2 vortexSize  = textureSize(u_Tex1, 0);

  // Calculate how many tiles fit in the game screen
  ivec2 tiles       = gameSize / tileSize;

  // Get the middle screen tile, indexing from 0
  middleTile        = tiles / 2 - 1;

  // Convert from bottom left (0, 0) with (0..1, 0..1) space to
  // top left with (0..gameSize.x, 0.gameSize.y) space
  ivec2 coord       = (vec2(0.0, 1.0) - v_TexCoord * vec2(-1.0, 1.0)) * gameSize + tileOffset;

  // Get the current working tile and its bottom tile
  ivec2 tile        = coord / tileSize;
  ivec2 tileBottom  = tile + ivec2(0, 1);

  // Get the remaining pixels inside the tile to sample from the vortex texture
  ivec2 offset      = coord % tileSize;

  // Get the current color to start blending
  vec4 gameColor    = texture2D(u_Tex0, v_TexCoord);

  // Check if the current tile is part of the effect
  bool isTileTop    = isVortexTop(tile);
  bool isTileBottom = isVortexBottom(tile);

  // Already set the output color as the current read color
  gl_FragColor      = vec4(gameColor.rgb, 1.0);

  // If the tile is not part of the effect, skip it
  if (!isTileTop && !isTileBottom)
  {
    return;
  }

  // If the tile is part of the effect, is vortex's bottom part, sample from
  // vortex's texture and, if the sampled color is not transparent, blend it into
  // the output color
  if (isTileBottom && isVortexVisible(tile))
  {
    // Get a "random" sprite index for the vortex's texture
    int  row   = getVortexRow(tile);
    int  index = getVortexIndex(tile);

    // Sample from the vortex's texture
    vec4 color = texture2D(u_Tex1, (vec2(index * tileSize, row * tileSize * 2 + tileSize) + offset) / vortexSize);

    // If the color is not transparent, blend it to the output color
    if (color.a > 0)
    {
      gl_FragColor += color;
    }
  }

  // If the tile is part of the effect, is vortex's upper part, sample from
  // vortex's texture and, if the sampled color is not transparent, blend it into
  // the output color
  if (isTileTop && isVortexVisible(tileBottom))
  {
    // Get a "random" sprite index for the vortex's texture
    int  row   = getVortexRow(tileBottom);
    int  index = getVortexIndex(tileBottom);

    // Sample from the vortex's texture
    vec4 color = texture2D(u_Tex1, (vec2(index * tileSize, row * tileSize * 2) + offset) / vortexSize);

    // If the color is not transparent, blend it to the output color
    if (color.a > 0)
    {
      gl_FragColor += color;
    }
  }

  // Ensure the alpha is opaque
  gl_FragColor.a = 1.0;
}
