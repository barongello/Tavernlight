// DISCLAIMER
// 
// I am no expert at shaders and it is my first attempt to create such effect. So,
// as long as I replicated the desired effect, it is probably not the right way of
// achieving it. I hope my efforts are taken into account (laughing with a tear)
// 
// Spent a lot of time trying to pass down to the shader the current player's
// texture, but failed. All my attempts resulted in empty textures (all black).
// So I just copied the player's sillhouete and made a PNG texture for it. Also
// I decided to space it more from the player's position



uniform sampler2D u_Tex0;                             // Game texture
uniform sampler2D u_Tex1;                             // Dash texture
varying vec2      v_TexCoord;                         // Texture coordinates
uniform float     u_Time;                             // Ellapsed time
uniform float     u_MapShaderTime;                    // Shader ellapsed time
uniform int       u_PlayerDirection;                  // Player direction
uniform int       u_PlayerStepDuration;               // Player direction step duration

const int         tileSize   = 32;                    // Tile size, used to subdivide the game screen
const vec2        tileOffset = vec2(8);               // Tile offset to get the player correct position on screen
const int         trailSize  = 4;                     // How many trails will have
const float       fade       = 1.0 / (trailSize + 1); // Fade step for trails
vec2              middleTile;                         // Will hold the middle tile, aka player position

void main(void)
{
  // Store game and dash textures' size
  ivec2 gameSize       = textureSize(u_Tex0, 0);
  ivec2 dashSize       = textureSize(u_Tex1, 0);

  // Calculate how many tiles fit in the game screen
  ivec2 tiles          = gameSize / tileSize;

  // Get the middle screen tile, indexing from 0
  middleTile           = tiles / 2 - 1;

  // Convert from bottom left (0, 0) with (0..1, 0..1) space to
  // top left with (0..gameSize.x, 0.gameSize.y) space
  ivec2 coord          = (vec2(0.0, 1.0) - v_TexCoord * vec2(-1.0, 1.0)) * gameSize + tileOffset;

  // Get the current working tile and its bottom tile
  ivec2 tile           = coord / tileSize;

  // Get the remaining pixels inside the tile to sample from the vortex texture
  ivec2 offset         = coord % tileSize;

  // Start with the current color
  gl_FragColor         = texture2D(u_Tex0, v_TexCoord);

  // Initialize the trail direction vector
  ivec2 trailDirection = ivec2(0);

  // Update the trail direction vector based on player's direction
  // 0 - North
  // 1 - East
  // 2 - South
  // 3 - West
  // The trail direction will be opposite to the player's direction
  if (u_PlayerDirection == 0)
  {
    trailDirection.y = 1;
  }
  else if (u_PlayerDirection == 1)
  {
    trailDirection.x = -1;
  }
  else if (u_PlayerDirection == 2)
  {
    trailDirection.y = -1;
  }
  else if (u_PlayerDirection == 3)
  {
    trailDirection.x = 1;
  }

  // Initialize the trails count to draw
  int trails = trailSize;

  // If player direction step duration is not zero, let's get a better trails count
  if (u_PlayerStepDuration > 0)
  {
    trails = int(clamp(750.0 * u_MapShaderTime / u_PlayerStepDuration, 0, trailSize));
  }

  // Iterate over all trail tiles to determine if it should be drawn now or not
  for (int i = 0; i < trails; ++i)
  {
    // Get the target trail tile
    ivec2 targetTile = middleTile + trailDirection * (i + 1);

    // If the target tile is the current tile being drawn
    if (tile == targetTile)
    {
      // Get dash pixel color
      vec4 sample = texture2D(u_Tex1, (vec2(u_PlayerDirection * tileSize, 1.0) + offset) / dashSize);

      // If it is visible, add transparency to it based on the distance from the player
      // The farther, the more transparent
      if (sample.a > 0.5)
      {
        float alpha = 1.0 - i * fade;

        gl_FragColor = vec4(mix(gl_FragColor.rgb, vec3(1.0, 0.0, 0.0), alpha), 1.0);
      }
    }
  }
}
